const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;

pub const SensorID = c.SDL_SensorID;

pub const SensorType = enum(i32) {
    invalid = c.SDL_SENSOR_INVALID,
    unknown = c.SDL_SENSOR_UNKNOWN,
    accel = c.SDL_SENSOR_ACCEL,
    gyro = c.SDL_SENSOR_GYRO,
    accel_l = c.SDL_SENSOR_ACCEL_L,
    gyro_l = c.SDL_SENSOR_GYRO_L,
    accel_r = c.SDL_SENSOR_ACCEL_R,
    gyro_r = c.SDL_SENSOR_GYRO_R,
};

/// A constant to represent standard gravity for accelerometer sensors.
pub const STANDARD_GRAVITY = c.SDL_STANDARD_GRAVITY;

/// Get a list of currently connected sensors.
pub inline fn getSensors() ![]SensorID {
    var count: c_int = undefined;
    const sensors = try errify(c.SDL_GetSensors(&count));
    return sensors[0..@intCast(count)];
}

/// Get the implementation dependent name of a sensor.
pub inline fn getNameForID(instance_id: SensorID) ?[]const u8 {
    return if (c.SDL_GetSensorNameForID(instance_id)) |name| std.mem.span(name) else null;
}

/// Get the type of a sensor.
pub inline fn getTypeForID(instance_id: SensorID) SensorType {
    return @enumFromInt(c.SDL_GetSensorTypeForID(instance_id));
}

/// Get the platform dependent type of a sensor.
pub inline fn getNonPortableTypeForID(instance_id: SensorID) i32 {
    return c.SDL_GetSensorNonPortableTypeForID(instance_id);
}

pub const Sensor = struct {
    ptr: *c.SDL_Sensor,

    /// Open a sensor for use.
    pub inline fn open(instance_id: SensorID) !Sensor {
        return Sensor{ .ptr = try errify(c.SDL_OpenSensor(instance_id)) };
    }

    /// Return the SDL_Sensor associated with an instance ID.
    pub inline fn getFromID(instance_id: SensorID) !Sensor {
        return Sensor{ .ptr = try errify(c.SDL_GetSensorFromID(instance_id)) };
    }

    /// Get the properties associated with a sensor.
    pub inline fn getProperties(self: *const Sensor) !c.SDL_PropertiesID {
        return try errify(c.SDL_GetSensorProperties(self.ptr));
    }

    /// Get the implementation dependent name of a sensor.
    pub inline fn getName(self: *const Sensor) ?[]const u8 {
        return if (c.SDL_GetSensorName(self.ptr)) |name| std.mem.span(name) else null;
    }

    /// Get the type of a sensor.
    pub inline fn getType(self: *const Sensor) SensorType {
        return @enumFromInt(c.SDL_GetSensorType(self.ptr));
    }

    /// Get the platform dependent type of a sensor.
    pub inline fn getNonPortableType(self: *const Sensor) i32 {
        return c.SDL_GetSensorNonPortableType(self.ptr);
    }

    /// Get the instance ID of a sensor.
    pub inline fn getID(self: *const Sensor) !SensorID {
        return try errify(c.SDL_GetSensorID(self.ptr));
    }

    /// Get the current state of an opened sensor.
    pub inline fn getData(self: *const Sensor, data: [*]f32, num_values: i32) !bool {
        return c.SDL_GetSensorData(self.ptr, data, num_values);
    }

    /// Close a sensor previously opened with SDL_OpenSensor().
    pub inline fn close(self: *const Sensor) void {
        c.SDL_CloseSensor(self.ptr);
    }
};

/// Update the current state of the open sensors.
pub inline fn updateSensors() void {
    c.SDL_UpdateSensors();
}
