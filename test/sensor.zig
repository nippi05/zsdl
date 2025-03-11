const std = @import("std");
const testing = std.testing;

const zsdl = @import("zsdl");
const sensor = zsdl.sensor;
const c = zsdl.c;

// Test enum values
test "SensorType enum values match SDL constants" {
    try testing.expectEqual(@intFromEnum(sensor.SensorType.invalid), c.SDL_SENSOR_INVALID);
    try testing.expectEqual(@intFromEnum(sensor.SensorType.unknown), c.SDL_SENSOR_UNKNOWN);
    try testing.expectEqual(@intFromEnum(sensor.SensorType.accel), c.SDL_SENSOR_ACCEL);
    try testing.expectEqual(@intFromEnum(sensor.SensorType.gyro), c.SDL_SENSOR_GYRO);
    try testing.expectEqual(@intFromEnum(sensor.SensorType.accel_l), c.SDL_SENSOR_ACCEL_L);
    try testing.expectEqual(@intFromEnum(sensor.SensorType.gyro_l), c.SDL_SENSOR_GYRO_L);
    try testing.expectEqual(@intFromEnum(sensor.SensorType.accel_r), c.SDL_SENSOR_ACCEL_R);
    try testing.expectEqual(@intFromEnum(sensor.SensorType.gyro_r), c.SDL_SENSOR_GYRO_R);
}

// Test constants
test "STANDARD_GRAVITY constant matches SDL constant" {
    try testing.expectEqual(sensor.STANDARD_GRAVITY, c.SDL_STANDARD_GRAVITY);
}

// Basic function tests that don't require real sensors
test "Update sensors function" {
    // Test that we can call the update function without errors
    sensor.updateSensors();
}

// Tests that require actual sensors
test "getSensors returns valid sensor IDs if available" {
    const sensors = try sensor.getSensors();

    // Test getting type of the first sensor
    if (sensors.len == 0) return;
    const id = sensors[0];
    const type_val = sensor.getTypeForID(id);

    // Should be a valid type
    try testing.expect(type_val != .invalid);

    // Test getting non-portable type
    _ = sensor.getNonPortableTypeForID(id);

    // Test getting name (may be null on some systems)
    _ = sensor.getNameForID(id);
}
