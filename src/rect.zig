const std = @import("std");

const c = @import("c.zig").c;
pub const Rectangle = c.SDL_Rect;
pub const FRect = c.SDL_FRect;
pub const FPoint = c.SDL_FPoint;
pub const Point = c.SDL_Point;

pub const Size = extern struct {
    width: c_int,
    height: c_int,
};

pub const AspectRatio = packed struct {
    min_aspect: f32,
    max_aspect: f32,
};

pub const BordersSize = extern struct {
    left: c_int,
    right: c_int,
    top: c_int,
    bottom: c_int,
};
