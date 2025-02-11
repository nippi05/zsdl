const std = @import("std");

const c = @import("c.zig").c;
pub const Rectangle = c.SDL_Rect;
pub const FRect = c.SDL_FRect;
pub const FPoint = c.SDL_FPoint;

// = extern struct {
//     x: c_int,
//     y: c_int,
//     w: c_int,
//     h: c_int,
// };

pub const Point = extern struct {
    x: c_int,
    y: c_int,
};

pub const Dimension = extern struct {
    w: c_int,
    h: c_int,
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
