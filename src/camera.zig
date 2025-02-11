const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;

pub const CameraID = c.SDL_CameraID;
pub const CameraSpec = c.SDL_CameraSpec;
pub const CameraPosition = enum(u32) {
    unknown = c.SDL_CAMERA_POSITION_UNKNOWN,
    front_facing = c.SDL_CAMERA_POSITION_FRONT_FACING,
    back_facing = c.SDL_CAMERA_POSITION_BACK_FACING,
};
pub const Surface = c.SDL_Surface;
pub const CameraProperties = struct {
    name: ?[*:0]const u8 = null,
    device_name: ?[*:0]const u8 = null,
    position: ?CameraPosition = null,
    format: ?*CameraSpec = null,
    frame_format: ?c.SDL_PixelFormat = null,
    frame_width: ?c_int = null,
    frame_height: ?c_int = null,
    frame_rate_numerator: ?c_int = null,
    frame_rate_denominator: ?c_int = null,
    colorspace: ?c.SDL_Colorspace = null,
    permission_state: ?c_int = null,

    fn apply(self: CameraProperties, props: c.SDL_PropertiesID) void {
        if (self.name) |n| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_CAMERA_NAME_STRING, n);
        if (self.device_name) |dn| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_CAMERA_DEVICE_NAME_STRING, dn);
        if (self.position) |p| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_POSITION_NUMBER, @intFromEnum(p));
        if (self.format) |f| _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_CAMERA_FORMAT_POINTER, f);
        if (self.frame_format) |ff| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_FRAME_FORMAT_NUMBER, @intFromEnum(ff));
        if (self.frame_width) |fw| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_FRAME_WIDTH_NUMBER, fw);
        if (self.frame_height) |fh| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_FRAME_HEIGHT_NUMBER, fh);
        if (self.frame_rate_numerator) |frn| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_FRAME_RATE_NUMERATOR_NUMBER, frn);
        if (self.frame_rate_denominator) |frd| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_FRAME_RATE_DENOMINATOR_NUMBER, frd);
        if (self.colorspace) |cs| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_COLORSPACE_NUMBER, @intFromEnum(cs));
        if (self.permission_state) |ps| _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_CAMERA_PERMISSION_STATE_NUMBER, ps);
    }
};

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
    pub fn getProperties(self: *const Camera) c.SDL_PropertiesID {
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
