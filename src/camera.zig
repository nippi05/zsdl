const std = @import("std");

const c = @import("c.zig").c;
pub const CameraID = c.SDL_CameraID;
const internal = @import("internal.zig");
const errify = internal.errify;
const pixels = @import("pixels.zig");
const PixelFormat = pixels.PixelFormat;
const Colorspace = pixels.Colorspace;
const surface = @import("surface.zig");
pub const Surface = surface.Surface;

pub const CameraSpec = extern struct {
    format: PixelFormat = std.mem.zeroes(PixelFormat),
    colorspace: Colorspace = std.mem.zeroes(Colorspace),
    width: usize = std.mem.zeroes(usize),
    height: usize = std.mem.zeroes(usize),
    framerate_numerator: usize = std.mem.zeroes(usize),
    framerate_denominator: usize = std.mem.zeroes(usize),
};

pub const CameraPosition = enum(u32) {
    unknown = c.SDL_CAMERA_POSITION_UNKNOWN,
    front_facing = c.SDL_CAMERA_POSITION_FRONT_FACING,
    back_facing = c.SDL_CAMERA_POSITION_BACK_FACING,
};

/// Use this function to get the number of built-in camera drivers.
pub inline fn getNumCameraDrivers() !c_int {
    return try errify(c.SDL_GetNumCameraDrivers());
}

/// Use this function to get the name of a built in camera driver.
pub inline fn getCameraDriver(index: c_int) ![]const u8 {
    return std.mem.span(try errify(c.SDL_GetCameraDriver(index)));
}

/// Get the name of the current camera driver.
pub inline fn getCurrentCameraDriver() ![]const u8 {
    return std.mem.span(try errify(c.SDL_GetCurrentCameraDriver()));
}

/// Get a list of currently connected camera devices.
pub inline fn getCameras() ![]CameraID {
    var count: c_int = undefined;
    var camera_ids = try errify(c.SDL_GetCameras(&count));
    return @ptrCast(camera_ids[0..@intCast(count)]);
}

pub const Camera = struct {
    ptr: *c.SDL_Camera,
    id: CameraID,

    /// Open a video recording device (a "camera").
    pub inline fn open(instance_id: CameraID, spec: ?CameraSpec) !Camera {
        return Camera{
            .ptr = try errify(c.SDL_OpenCamera(instance_id, @ptrCast(&spec))),
            .id = instance_id,
        };
    }

    /// Get the list of native formats/sizes a camera supports.
    pub inline fn getSupportedFormats(self: *const Camera) ![]CameraSpec {
        var count: c_int = undefined;
        const formats = try errify(c.SDL_GetCameraSupportedFormats(self.id, &count));
        return @as([*]CameraSpec, @ptrCast(formats))[0..@intCast(count)];
    }

    /// Get the human-readable device name for a camera.
    pub inline fn getName(self: *const Camera) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetCameraName(self.id)));
    }

    /// Get the position of the camera in relation to the system.
    pub inline fn getPosition(self: *const Camera) CameraPosition {
        return @enumFromInt(c.SDL_GetCameraPosition(self.id));
    }

    /// Query if camera access has been approved by the user.
    pub inline fn getPermissionState(self: *const Camera) !c_int {
        return try errify(c.SDL_GetCameraPermissionState(self.ptr));
    }

    /// Get the instance ID of an opened camera.
    pub inline fn getID(self: *const Camera) CameraID {
        return c.SDL_GetCameraID(self.ptr);
    }

    /// Get the properties associated with an opened camera.
    pub inline fn getProperties(self: *const Camera) c.SDL_PropertiesID {
        return c.SDL_GetCameraProperties(self.ptr);
    }

    /// Get the spec that a camera is using when generating images.
    pub inline fn getFormat(self: *const Camera) !CameraSpec {
        var spec: CameraSpec = undefined;
        try errify(c.SDL_GetCameraFormat(self.ptr, @ptrCast(&spec)));
        return spec;
    }

    /// Acquire a frame.
    pub inline fn acquireFrame(self: *const Camera, timestamp_ns: ?*u64) !Surface {
        return .{
            .ptr = try errify(c.SDL_AcquireCameraFrame(self.ptr, timestamp_ns)),
        };
    }

    /// Release a frame of video acquired from a camera.
    pub inline fn releaseFrame(self: *const Camera, frame: Surface) void {
        c.SDL_ReleaseCameraFrame(self.ptr, frame.ptr);
    }

    /// Use this function to shut down camera processing and close the camera device.
    pub inline fn close(self: *const Camera) void {
        c.SDL_CloseCamera(self.ptr);
    }
};

/// Get the list of native formats/sizes a camera supports.
pub inline fn getCameraSupportedFormats(instance_id: CameraID) ![]CameraSpec {
    var count: c_int = undefined;
    const formats = try errify(c.SDL_GetCameraSupportedFormats(instance_id, &count));
    return @as([*]CameraSpec, @ptrCast(formats))[0..@intCast(count)];
}

/// Get the human-readable device name for a camera.
pub inline fn getCameraName(instance_id: CameraID) ![]const u8 {
    return std.mem.span(try errify(c.SDL_GetCameraName(instance_id)));
}

/// Get the position of the camera in relation to the system.
pub inline fn getCameraPosition(instance_id: CameraID) CameraPosition {
    return @enumFromInt(c.SDL_GetCameraPosition(instance_id));
}
