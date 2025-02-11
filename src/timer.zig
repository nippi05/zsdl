const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;

pub const MS_PER_SECOND = c.SDL_MS_PER_SECOND;
pub const US_PER_SECOND = c.SDL_US_PER_SECOND;
pub const NS_PER_SECOND = c.SDL_NS_PER_SECOND;
pub const NS_PER_MS = c.SDL_NS_PER_MS;
pub const NS_PER_US = c.SDL_NS_PER_US;

pub const TimerID = c.SDL_TimerID;
pub const TimerCallback = c.SDL_TimerCallback;
pub const NSTimerCallback = c.SDL_NSTimerCallback;

pub fn getTicks() u64 {
    return c.SDL_GetTicks();
}

pub fn getTicksNS() u64 {
    return c.SDL_GetTicksNS();
}

pub fn getPerformanceCounter() u64 {
    return c.SDL_GetPerformanceCounter();
}

pub fn getPerformanceFrequency() u64 {
    return c.SDL_GetPerformanceFrequency();
}

pub fn delay(ms: u32) void {
    c.SDL_Delay(ms);
}

pub fn delayNS(ns: u64) void {
    c.SDL_DelayNS(ns);
}

pub fn delayPrecise(ns: u64) void {
    c.SDL_DelayPrecise(ns);
}

pub fn addTimer(interval: u32, callback: TimerCallback, userdata: ?*anyopaque) !TimerID {
    return try errify(c.SDL_AddTimer(interval, callback, userdata));
}

pub fn addTimerNS(interval: u64, callback: NSTimerCallback, userdata: ?*anyopaque) !TimerID {
    return try errify(c.SDL_AddTimerNS(interval, callback, userdata));
}

pub fn removeTimer(id: TimerID) !void {
    try errify(c.SDL_RemoveTimer(id));
}
