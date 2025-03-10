const std = @import("std");

const c = @import("c.zig").c;
const errify = @import("internal.zig").errify;

pub const Rect = extern struct {
    x: c_int,
    y: c_int,
    w: c_int,
    h: c_int,

    /// Convert an SDL_Rect to SDL_FRect.
    pub fn toFRect(self: *const Rect) FRect {
        var frect: FRect = undefined;
        c.SDL_RectToFRect(@ptrCast(self), @ptrCast(&frect));
        return frect;
    }

    /// Determine whether a rectangle has no area.
    pub fn empty(self: *const Rect) bool {
        return c.SDL_RectEmpty(@ptrCast(self));
    }

    /// Determine whether two rectangles are equal.
    pub fn equals(self: *const Rect, b: *const Rect) bool {
        return c.SDL_RectsEqual(@ptrCast(self), @ptrCast(b));
    }

    /// Determine whether two rectangles intersect.
    pub fn hasIntersection(self: *const Rect, b: *const Rect) bool {
        return c.SDL_HasRectIntersection(@ptrCast(self), @ptrCast(b));
    }

    /// Calculate the intersection of two rectangles.
    pub fn getIntersection(self: *const Rect, b: *const Rect) ?Rect {
        var result: ?Rect = null;
        _ = c.SDL_GetRectIntersection(@ptrCast(self), @ptrCast(b), @ptrCast(&result));
        return result;
    }

    /// Calculate the union of two rectangles.
    pub fn getUnion(self: *const Rect, b: *const Rect) !Rect {
        var result: Rect = undefined;
        try errify(c.SDL_GetRectUnion(@ptrCast(self), @ptrCast(b), @ptrCast(&result)));
        return result;
    }

    /// Calculate the intersection of a rectangle and line segment.
    pub fn getLineIntersection(self: *const Rect, x1: *c_int, y1: *c_int, x2: *c_int, y2: *c_int) bool {
        return c.SDL_GetRectAndLineIntersection(@ptrCast(self), x1, y1, x2, y2);
    }
};

pub const FRect = extern struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    /// Determine whether a floating point rectangle can contain any point.
    pub fn empty(self: *const FRect) bool {
        return c.SDL_RectEmptyFloat(@ptrCast(self));
    }

    /// Determine whether two floating point rectangles are equal, within some given epsilon.
    pub fn equalsEpsilon(self: *const FRect, b: *const FRect, epsilon: f32) bool {
        return c.SDL_RectsEqualEpsilon(@ptrCast(self), @ptrCast(b), epsilon);
    }

    /// Determine whether two floating point rectangles are equal, within a default epsilon.
    pub fn equals(self: *const FRect, b: *const FRect) bool {
        return c.SDL_RectsEqualFloat(@ptrCast(self), @ptrCast(b));
    }

    /// Determine whether two rectangles intersect with float precision.
    pub fn hasIntersection(self: *const FRect, b: *const FRect) bool {
        return c.SDL_HasRectIntersectionFloat(@ptrCast(self), @ptrCast(b));
    }

    /// Calculate the intersection of two rectangles with float precision.
    pub fn getIntersection(self: *const FRect, b: *const FRect) ?FRect {
        var result: ?FRect = null;
        _ = c.SDL_GetRectIntersectionFloat(@ptrCast(self), @ptrCast(b), @ptrCast(&result));
        return result;
    }

    /// Calculate the union of two rectangles with float precision.
    pub fn getUnion(self: *const FRect, b: *const FRect) !FRect {
        var result: FRect = undefined;
        try errify(c.SDL_GetRectUnionFloat(@ptrCast(self), @ptrCast(b), @ptrCast(&result)));
        return result;
    }

    /// Calculate the intersection of a rectangle and line segment with float precision.
    pub fn getLineIntersection(self: *const FRect, x1: *f32, y1: *f32, x2: *f32, y2: *f32) bool {
        return c.SDL_GetRectAndLineIntersectionFloat(@ptrCast(self), x1, y1, x2, y2);
    }
};

pub const Point = extern struct {
    x: c_int,
    y: c_int,

    /// Determine whether a point resides inside a rectangle.
    pub fn inRect(self: *const Point, r: *const Rect) bool {
        return c.SDL_PointInRect(@ptrCast(self), @ptrCast(r));
    }
};

pub const FPoint = extern struct {
    x: f32,
    y: f32,

    /// Determine whether a point resides inside a floating point rectangle.
    pub fn inRect(self: *const FPoint, r: *const FRect) bool {
        return c.SDL_PointInRectFloat(@ptrCast(self), @ptrCast(r));
    }
};

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

/// Calculate a minimal rectangle enclosing a set of points.
pub fn getRectEnclosingPoints(points: []const Point, clip: ?*const Rect) !Rect {
    var result: Rect = undefined;
    try errify(c.SDL_GetRectEnclosingPoints(@ptrCast(points.ptr), @intCast(points.len), @ptrCast(clip), @ptrCast(&result)));
    return result;
}

/// Calculate a minimal rectangle enclosing a set of points with float precision.
pub fn getRectEnclosingPointsFloat(points: []const FPoint, clip: ?*const FRect) !FRect {
    var result: FRect = undefined;
    try errify(c.SDL_GetRectEnclosingPointsFloat(@ptrCast(points.ptr), @intCast(points.len), @ptrCast(clip), @ptrCast(&result)));
    return result;
}
