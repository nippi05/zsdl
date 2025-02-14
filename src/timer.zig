const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;

pub const TimerID = c.SDL_TimerID;
pub const TimerCallback = c.SDL_TimerCallback;
pub const NSTimerCallback = c.SDL_NSTimerCallback;

/// Get the number of milliseconds since SDL library initialization.
pub fn getTicks() u64 {
    return c.SDL_GetTicks();
}

/// Get the number of nanoseconds since SDL library initialization.
pub fn getTicksNS() u64 {
    return c.SDL_GetTicksNS();
}

/// Get the current value of the high resolution counter.
pub fn getPerformanceCounter() u64 {
    return c.SDL_GetPerformanceCounter();
}

/// Get the count per second of the high resolution counter.
pub fn getPerformanceFrequency() u64 {
    return c.SDL_GetPerformanceFrequency();
}

/// Wait a specified number of milliseconds before returning.
pub fn delay(ms: u32) void {
    c.SDL_Delay(ms);
}

/// Wait a specified number of nanoseconds before returning.
pub fn delayNS(ns: u64) void {
    c.SDL_DelayNS(ns);
}

/// Wait a specified number of nanoseconds before returning.
pub fn delayPrecise(ns: u64) void {
    c.SDL_DelayPrecise(ns);
}

/// Call a callback function at a future time.
pub fn addTimer(interval: u32, callback: TimerCallback, userdata: ?*anyopaque) !TimerID {
    return try errify(c.SDL_AddTimer(interval, callback, userdata));
}

/// Call a callback function at a future time.
pub fn addTimerNS(interval: u64, callback: NSTimerCallback, userdata: ?*anyopaque) !TimerID {
    return try errify(c.SDL_AddTimerNS(interval, callback, userdata));
}

/// Remove a timer created with SDL_AddTimer().
pub fn removeTimer(id: TimerID) !void {
    try errify(c.SDL_RemoveTimer(id));
}
