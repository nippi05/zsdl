const std = @import("std");
const testing = std.testing;

const zsdl = @import("zsdl");
const power = zsdl.power;
const c = zsdl.c;

test "PowerState enum values match SDL constants" {
    try testing.expectEqual(@intFromEnum(power.PowerState.@"error"), c.SDL_POWERSTATE_ERROR);
    try testing.expectEqual(@intFromEnum(power.PowerState.unknown), c.SDL_POWERSTATE_UNKNOWN);
    try testing.expectEqual(@intFromEnum(power.PowerState.on_battery), c.SDL_POWERSTATE_ON_BATTERY);
    try testing.expectEqual(@intFromEnum(power.PowerState.no_battery), c.SDL_POWERSTATE_NO_BATTERY);
    try testing.expectEqual(@intFromEnum(power.PowerState.charging), c.SDL_POWERSTATE_CHARGING);
    try testing.expectEqual(@intFromEnum(power.PowerState.charged), c.SDL_POWERSTATE_CHARGED);
}

test "getPowerInfo returns valid state and values" {
    var seconds: i32 = undefined;
    var percent: i32 = undefined;

    const state = try power.getPowerInfo(&seconds, &percent);

    switch (state) {
        .@"error" => try testing.expect(false),
        .unknown, .on_battery, .no_battery, .charging, .charged => {},
    }

    try testing.expect(seconds == -1 or seconds >= 0);
    try testing.expect(percent == -1 or (percent >= 0 and percent <= 100));
}
