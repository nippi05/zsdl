pub inline fn errify(value: anytype) error{SdlError}!switch (@typeInfo(@TypeOf(value))) {
    .bool => void,
    .pointer, .optional => @TypeOf(value.?),
    .int, .float => @TypeOf(value),
    else => @compileError("unerrifiable type: " ++ @typeName(@TypeOf(value))),
} {
    return switch (@typeInfo(@TypeOf(value))) {
        .bool => if (!value) error.SdlError,
        .pointer, .optional => value orelse error.SdlError,
        .int, .float => if (value == 0) return error.SdlError else value,
        else => comptime unreachable,
    };
}

pub inline fn errifyWithValue(value: anytype, err_value: @TypeOf(value)) error{SdlError}!@TypeOf(value) {
    if (value == err_value) {
        return error.SdlError;
    }
    return value;
}
