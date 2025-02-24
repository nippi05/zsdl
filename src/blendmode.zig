const c = @import("c.zig").c;

pub const BlendMode = enum(u32) {
    none = c.SDL_BLENDMODE_NONE,
    blend = c.SDL_BLENDMODE_BLEND,
    blend_premultiplied = c.SDL_BLENDMODE_BLEND_PREMULTIPLIED,
    add = c.SDL_BLENDMODE_ADD,
    add_premultiplied = c.SDL_BLENDMODE_ADD_PREMULTIPLIED,
    mod = c.SDL_BLENDMODE_MOD,
    mul = c.SDL_BLENDMODE_MUL,
    invalid = c.SDL_BLENDMODE_INVALID,
};

pub const BlendOperation = enum(u32) {
    add = c.SDL_BLENDOPERATION_ADD,
    subtract = c.SDL_BLENDOPERATION_SUBTRACT,
    rev_subtract = c.SDL_BLENDOPERATION_REV_SUBTRACT,
    minimum = c.SDL_BLENDOPERATION_MINIMUM,
    maximum = c.SDL_BLENDOPERATION_MAXIMUM,
};

pub const BlendFactor = enum(c_uint) {
    zero = c.SDL_BLENDFACTOR_ZERO,
    one = c.SDL_BLENDFACTOR_ONE,
    src_color = c.SDL_BLENDFACTOR_SRC_COLOR,
    one_minus_src_color = c.SDL_BLENDFACTOR_ONE_MINUS_SRC_COLOR,
    src_alpha = c.SDL_BLENDFACTOR_SRC_ALPHA,
    one_minus_src_alpha = c.SDL_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
    dst_color = c.SDL_BLENDFACTOR_DST_COLOR,
    one_minus_dst_color = c.SDL_BLENDFACTOR_ONE_MINUS_DST_COLOR,
    dst_alpha = c.SDL_BLENDFACTOR_DST_ALPHA,
    one_minus_dst_alpha = c.SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA,
};

pub inline fn composeCustomBlendMode(
    srcColorFactor: BlendFactor,
    dstColorFactor: BlendFactor,
    colorOperation: BlendOperation,
    srcAlphaFactor: BlendFactor,
    dstAlphaFactor: BlendFactor,
    alphaOperation: BlendOperation,
) BlendMode {
    return @enumFromInt(c.SDL_ComposeCustomBlendMode(
        @intFromEnum(srcColorFactor),
        @intFromEnum(dstColorFactor),
        @intFromEnum(colorOperation),
        @intFromEnum(srcAlphaFactor),
        @intFromEnum(dstAlphaFactor),
        @intFromEnum(alphaOperation),
    ));
}
