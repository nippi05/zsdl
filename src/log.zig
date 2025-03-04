const c = @import("c.zig").c;
pub const LogOutputFunction = c.SDL_LogOutputFunction;

const Priority = enum(c.SDL_LogPriority) {
    invalid = c.SDL_LOG_PRIORITY_INVALID,
    trace = c.SDL_LOG_PRIORITY_TRACE,
    verbose = c.SDL_LOG_PRIORITY_VERBOSE,
    debug = c.SDL_LOG_PRIORITY_DEBUG,
    info = c.SDL_LOG_PRIORITY_INFO,
    warn = c.SDL_LOG_PRIORITY_WARN,
    @"error" = c.SDL_LOG_PRIORITY_ERROR,
    critical = c.SDL_LOG_PRIORITY_CRITICAL,
    count = c.SDL_LOG_PRIORITY_COUNT,
};

const Category = enum(c.SDL_LogCategory) {
    application = c.SDL_LOG_CATEGORY_APPLICATION,
    @"error" = c.SDL_LOG_CATEGORY_ERROR,
    assert = c.SDL_LOG_CATEGORY_ASSERT,
    system = c.SDL_LOG_CATEGORY_SYSTEM,
    audio = c.SDL_LOG_CATEGORY_AUDIO,
    video = c.SDL_LOG_CATEGORY_VIDEO,
    render = c.SDL_LOG_CATEGORY_RENDER,
    input = c.SDL_LOG_CATEGORY_INPUT,
    @"test" = c.SDL_LOG_CATEGORY_TEST,
    gpu = c.SDL_LOG_CATEGORY_GPU,

    reserved2 = c.SDL_LOG_CATEGORY_RESERVED2,
    reserved3 = c.SDL_LOG_CATEGORY_RESERVED3,
    reserved4 = c.SDL_LOG_CATEGORY_RESERVED4,
    reserved5 = c.SDL_LOG_CATEGORY_RESERVED5,
    reserved6 = c.SDL_LOG_CATEGORY_RESERVED6,
    reserved7 = c.SDL_LOG_CATEGORY_RESERVED7,
    reserved8 = c.SDL_LOG_CATEGORY_RESERVED8,
    reserved9 = c.SDL_LOG_CATEGORY_RESERVED9,
    reserved10 = c.SDL_LOG_CATEGORY_RESERVED10,
    custom = c.SDL_LOG_CATEGORY_CUSTOM,
};

/// Set the priority of all log categories.
pub inline fn setLogPriorities(priority: Priority) void {
    c.SDL_SetLogPriorities(@intFromEnum(priority));
}

/// Set the priority of a particular log category.
pub inline fn setLogPriority(category: Category, priority: Priority) void {
    c.SDL_SetLogPriority(@intFromEnum(category), @intFromEnum(priority));
}

/// Get the priority of a particular log category.
pub inline fn getLogPriority(category: Category) Priority {
    return @enumFromInt(c.SDL_GetLogPriority(@intFromEnum(category)));
}

/// Reset all priorities to default.
pub inline fn resetLogPriorities() void {
    c.SDL_ResetLogPriorities();
}

/// Set the text prepended to log messages of a given priority.
pub inline fn setLogPriorityPrefix(priority: Priority, prefix: [:0]const u8) !void {
    c.SDL_SetLogPriorityPrefix(@intFromEnum(priority), prefix);
}

/// Log a message with SDL_LOG_CATEGORY_APPLICATION and SDL_LOG_PRIORITY_INFO.
pub inline fn log(fmt: [:0]const u8, args: anytype) void {
    c.SDL_Log(fmt, args);
}

/// Log a message with SDL_LOG_PRIORITY_TRACE.
pub inline fn logTrace(category: Category, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogTrace(@intFromEnum(category), fmt, args);
}

/// Log a message with SDL_LOG_PRIORITY_VERBOSE.
pub inline fn logVerbose(category: Category, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogVerbose(@intFromEnum(category), fmt, args);
}

/// Log a message with SDL_LOG_PRIORITY_DEBUG.
pub inline fn logDebug(category: Category, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogDebug(@intFromEnum(category), fmt, args);
}

/// Log a message with SDL_LOG_PRIORITY_INFO.
pub inline fn logInfo(category: Category, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogInfo(@intFromEnum(category), fmt, args);
}

/// Log a message with SDL_LOG_PRIORITY_WARN.
pub inline fn logWarn(category: Category, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogWarn(@intFromEnum(category), fmt, args);
}

/// Log a message with SDL_LOG_PRIORITY_ERROR.
pub inline fn logError(category: Category, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogError(@intFromEnum(category), fmt, args);
}

/// Log a message with SDL_LOG_PRIORITY_CRITICAL.
pub inline fn logCritical(category: Category, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogCritical(@intFromEnum(category), fmt, args);
}

/// Log a message with the specified category and priority.
pub inline fn logMessage(category: Category, priority: Priority, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogMessage(@intFromEnum(category), @intFromEnum(priority), fmt, args);
}

/// Log a message with the specified category and priority.
pub inline fn logMessageV(category: Category, priority: Priority, fmt: [:0]const u8, args: anytype) void {
    c.SDL_LogMessageV(@intFromEnum(category), @intFromEnum(priority), fmt, args);
}

/// Get the default log output function.
pub inline fn getDefaultLogOutputFunction() LogOutputFunction {
    return c.SDL_GetDefaultLogOutputFunction();
}

/// Get the current log output function.
pub inline fn getLogOutputFunction(userdata: *anyopaque) *LogOutputFunction {
    const callback: LogOutputFunction = undefined;
    c.SDL_GetLogOutputFunction(&callback, &userdata);
    return *callback;
}

/// Replace the default log output function with one of your own.
pub inline fn setLogOutputFunction(callback: LogOutputFunction, userdata: *anyopaque) void {
    c.SDL_SetLogOutputFunction(callback, userdata);
}
