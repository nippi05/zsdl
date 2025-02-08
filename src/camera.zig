const std = @import("std");
const internal = @import("internal.zig");
const c = internal.c;
const errify = internal.errify;

pub const CameraID = c.SDL_CameraID;
pub const CameraSpec = c.SDL_CameraSpec;
pub const CameraPosition = enum(u32) {
    unknown = c.SDL_CAMERA_POSITION_UNKNOWN,
    front_facing = c.SDL_CAMERA_POSITION_FRONT_FACING,
    back_facing = c.SDL_CAMERA_POSITION_BACK_FACING,
};
pub const Surface = c.SDL_Surface;
pub const PropertiesID = c.SDL_PropertiesID;

/// Get the number of built-in camera drivers
pub fn getNumCameraDrivers() !c_int {
    return try errify(c.SDL_GetNumCameraDrivers());
}

/// Get the name of a built-in camera driver
pub fn getCameraDriver(index: c_int) ![:0]const u8 {
    return try errify(c.SDL_GetCameraDriver(index));
}

/// Get the name of the current camera driver
pub fn getCurrentCameraDriver() ![:0]const u8 {
    return try errify(c.SDL_GetCurrentCameraDriver());
}

/// Get a list of currently connected camera devices
pub fn getCameras() ![]CameraID {
    var count: c_int = undefined;
    var camera_ids = try errify(c.SDL_GetCameras(&count));
    return @ptrCast(camera_ids[0..@intCast(count)]);
}

/// Get the list of native formats/sizes a camera supports
pub fn getCameraSupportedFormats(instance_id: CameraID) ![]CameraSpec {
    var count: c_int = undefined;
    var formats = try errify(c.SDL_GetCameraSupportedFormats(instance_id, &count));
    return @ptrCast(formats[0..@intCast(count)]);
}

/// Get the human-readable device name for a camera
pub fn getCameraName(instance_id: CameraID) ![:0]const u8 {
    return try errify(c.SDL_GetCameraName(instance_id));
}

/// Get the position of the camera in relation to the system
pub fn getCameraPosition(instance_id: CameraID) !CameraPosition {
    return @enumFromInt(c.SDL_GetCameraPosition(instance_id));
}

pub const Camera = struct {
    ptr: *c.SDL_Camera,

    /// Open a video recording device
    pub fn open(instance_id: CameraID, spec: *const CameraSpec) !Camera {
        return Camera{
            .ptr = try errify(c.SDL_OpenCamera(instance_id, spec)),
        };
    }

    /// Query if camera access has been approved by the user
    pub fn getPermissionState(self: *const Camera) !c_int {
        return try errify(c.SDL_GetCameraPermissionState(self.ptr));
    }

    /// Get the instance ID of an opened camera
    pub fn getID(self: *const Camera) CameraID {
        return c.SDL_GetCameraID(self.ptr);
    }

    /// Get the properties associated with an opened camera
    pub fn getProperties(self: *const Camera) PropertiesID {
        return c.SDL_GetCameraProperties(self.ptr);
    }

    /// Get the spec that a camera is using when generating images
    pub fn getFormat(self: *const Camera, spec: *CameraSpec) bool {
        return c.SDL_GetCameraFormat(self.ptr, spec);
    }

    /// Acquire a frame
    pub fn acquireFrame(self: *const Camera, timestamp_ns: *u64) !*Surface {
        return try errify(c.SDL_AcquireCameraFrame(self.ptr, timestamp_ns));
    }

    /// Release a frame of video acquired from a camera
    pub fn releaseFrame(self: *const Camera, frame: *Surface) void {
        c.SDL_ReleaseCameraFrame(self.ptr, frame);
    }

    /// Shut down camera processing and close the camera device
    pub fn close(self: *const Camera) void {
        c.SDL_CloseCamera(self.ptr);
    }
};
