const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub const Rectangle = c.SDL_Rect; // = extern struct {
//     x: c_int,
//     y: c_int,
//     w: c_int,
//     h: c_int,
// };

pub const FRect = c.SDL_FRect;

pub const Point = extern struct {
    x: c_int,
    y: c_int,
};

pub const FPoint = extern struct {
    x: f32,
    y: f32,
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
