const std = @import("std");

const c = @import("c.zig").c;
pub const PropertiesID = c.SDL_PropertiesID;
const internal = @import("internal.zig");
const errify = internal.errify;

pub const PropertyType = enum(u32) {
    invalid = c.SDL_PROPERTY_TYPE_INVALID,
    pointer = c.SDL_PROPERTY_TYPE_POINTER,
    string = c.SDL_PROPERTY_TYPE_STRING,
    number = c.SDL_PROPERTY_TYPE_NUMBER,
    float = c.SDL_PROPERTY_TYPE_FLOAT,
    boolean = c.SDL_PROPERTY_TYPE_BOOLEAN,
};

pub const Properties = struct {
    id: PropertiesID,

    /// Create a new group of properties.
    pub inline fn create() !Properties {
        return .{
            .id = try c.SDL_CreateProperties(),
        };
    }

    /// Get the global properties
    pub inline fn global() !Properties {
        return .{
            .id = try errify(c.SDL_GetGlobalProperties()),
        };
    }

    /// Copy a group of properties.
    pub inline fn copy(self: *const Properties, dst: Properties) !bool {
        return try errify(c.SDL_CopyProperties(self.id, dst.id));
    }

    /// Lock a group of properties.
    pub inline fn lock(self: *const Properties) !bool {
        return try errify(c.SDL_LockProperties(self.id));
    }

    /// Unlock a group of properties.
    pub inline fn unlock(self: *const Properties) void {
        c.SDL_UnlockProperties(self.id);
    }

    /// Set a pointer property in a group of properties with a cleanup function that is called when the property is deleted.
    pub inline fn setPointerWithCleanup(self: *const Properties, name: [:0]const u8, value: ?*anyopaque, cleanup: ?fn (userdata: ?*anyopaque, value: ?*anyopaque) callconv(.C) void, userdata: ?*anyopaque) !bool {
        return try errify(c.SDL_SetPointerPropertyWithCleanup(self.id, name.ptr, value, cleanup, userdata));
    }

    /// Set a pointer property in a group of properties.
    pub inline fn setPointer(self: *const Properties, name: [:0]const u8, value: ?*anyopaque) !bool {
        return try errify(c.SDL_SetPointerProperty(self.id, name.ptr, value));
    }

    /// Set a string property in a group of properties.
    pub inline fn setString(self: *const Properties, name: [:0]const u8, value: ?[:0]const u8) !bool {
        return try errify(c.SDL_SetStringProperty(self.id, name.ptr, if (value) |v| v.ptr else null));
    }

    /// Set an integer property in a group of properties.
    pub inline fn setNumber(self: *const Properties, name: [:0]const u8, value: i64) !bool {
        return try errify(c.SDL_SetNumberProperty(self.id, name.ptr, value));
    }

    /// Set a floating point property in a group of properties.
    pub inline fn setFloat(self: *const Properties, name: [:0]const u8, value: f32) !bool {
        return try errify(c.SDL_SetFloatProperty(self.id, name.ptr, value));
    }

    /// Set a boolean property in a group of properties.
    pub inline fn setBoolean(self: *const Properties, name: [:0]const u8, value: bool) !bool {
        return try errify(c.SDL_SetBooleanProperty(self.id, name.ptr, value));
    }

    /// Return whether a property exists in a group of properties.
    pub inline fn has(self: *const Properties, name: [:0]const u8) bool {
        return c.SDL_HasProperty(self.id, name.ptr);
    }

    /// Get the type of a property in a group of properties.
    pub inline fn getType(self: *const Properties, name: [:0]const u8) PropertyType {
        return @enumFromInt(c.SDL_GetPropertyType(self.id, name.ptr));
    }

    /// Get a pointer property from a group of properties.
    pub inline fn getPointer(self: *const Properties, name: [:0]const u8, default_value: ?*anyopaque) ?*anyopaque {
        return c.SDL_GetPointerProperty(self.id, name.ptr, default_value);
    }

    /// Get a string property from a group of properties.
    pub inline fn getString(self: *const Properties, name: [:0]const u8, default_value: ?[:0]const u8) ?[]const u8 {
        return if (c.SDL_GetStringProperty(self.id, name.ptr, default_value)) |prop| std.mem.span(prop) else null;
    }

    /// Get a number property from a group of properties.
    pub inline fn getNumber(self: *const Properties, name: [:0]const u8, default_value: i64) i64 {
        return c.SDL_GetNumberProperty(self.id, name.ptr, default_value);
    }

    /// Get a floating point property from a group of properties.
    pub inline fn getFloat(self: *const Properties, name: [:0]const u8, default_value: f32) f32 {
        return c.SDL_GetFloatProperty(self.id, name.ptr, default_value);
    }

    /// Get a boolean property from a group of properties.
    pub inline fn getBoolean(self: *const Properties, name: [:0]const u8, default_value: bool) bool {
        return c.SDL_GetBooleanProperty(self.id, name.ptr, default_value);
    }

    /// Clear a property from a group of properties.
    pub inline fn clear(self: *const Properties, name: [:0]const u8) !bool {
        return try errify(c.SDL_ClearProperty(self.id, name.ptr));
    }

    /// Enumerate the properties contained in a group of properties.
    pub inline fn enumerate(self: *const Properties, callback: ?fn (userdata: ?*anyopaque, props: PropertiesID, name: [*:0]const u8) callconv(.C) void, userdata: ?*anyopaque) !bool {
        return try errify(c.SDL_EnumerateProperties(self.id, callback, userdata));
    }

    /// Destroy a group of properties.
    pub inline fn destroy(self: *const Properties) void {
        c.SDL_DestroyProperties(self.id);
    }
};
