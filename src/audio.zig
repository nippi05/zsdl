const std = @import("std");

const c = @import("c.zig").c;
pub const AudioStreamCallback = c.SDL_AudioStreamCallback;
/// SDL Audio Device instance IDs
pub const AudioDeviceID = c.SDL_AudioDeviceID;
/// Default playback device
pub const audio_device_default_playback = c.SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK;
/// Default recording device
pub const audio_device_default_recording = c.SDL_AUDIO_DEVICE_DEFAULT_RECORDING;
const internal = @import("internal.zig");
const errify = internal.errify;
const errifyWithValue = internal.errifyWithValue;

pub const AudioSpec = extern struct {
    format: AudioFormat,
    channels: c_int,
    freq: c_int,
};

pub const AudioFormat = enum(u16) {
    unknown = c.SDL_AUDIO_UNKNOWN,
    u8 = c.SDL_AUDIO_U8,
    s8 = c.SDL_AUDIO_S8,
    s16 = c.SDL_AUDIO_S16,
    s32 = c.SDL_AUDIO_S32,
    f32 = c.SDL_AUDIO_F32,

    pub const mask_bitsize = c.SDL_AUDIO_MASK_BITSIZE;
    pub const mask_float = c.SDL_AUDIO_MASK_FLOAT;
    pub const mask_big_endian = c.SDL_AUDIO_MASK_BIG_ENDIAN;
    pub const mask_signed = c.SDL_AUDIO_MASK_SIGNED;
};

/// Calculate the size of each audio frame in bytes
pub inline fn audioFrameSize(spec: AudioSpec) usize {
    const byte_size = @as(usize, @intCast(c.SDL_AUDIO_BYTESIZE(@intFromEnum(spec.format))));
    const channels = @as(usize, @intCast(spec.channels));
    return byte_size * channels;
}

pub const AudioStream = struct {
    ptr: *c.SDL_AudioStream,

    /// Create a new audio stream
    pub inline fn create(src_spec: *const AudioSpec, dst_spec: *const AudioSpec) !AudioStream {
        return AudioStream{ .ptr = try errify(c.SDL_CreateAudioStream(@ptrCast(src_spec), @ptrCast(dst_spec))) };
    }

    /// Get the properties associated with an audio stream
    pub inline fn getProperties(self: *const AudioStream) !c.SDL_PropertiesID {
        return try errify(c.SDL_GetAudioStreamProperties(self.ptr));
    }

    /// Query the current format of an audio stream
    pub inline fn getFormat(self: *const AudioStream, src_spec: ?*AudioSpec, dst_spec: ?*AudioSpec) !void {
        return try errify(c.SDL_GetAudioStreamFormat(self.ptr, if (src_spec) |s| @ptrCast(s) else null, if (dst_spec) |s| @ptrCast(s) else null));
    }

    /// Change the input and output formats of an audio stream
    pub inline fn setFormat(self: *const AudioStream, src_spec: ?*const AudioSpec, dst_spec: ?*const AudioSpec) !void {
        return try errify(c.SDL_SetAudioStreamFormat(self.ptr, if (src_spec) |s| @ptrCast(s) else null, if (dst_spec) |s| @ptrCast(s) else null));
    }

    /// Get the frequency ratio of an audio stream
    pub inline fn getFrequencyRatio(self: *const AudioStream) !f32 {
        try errify(c.SDL_GetAudioStreamFrequencyRatio(self.ptr));
    }

    /// Change the frequency ratio of an audio stream
    pub inline fn setFrequencyRatio(self: *const AudioStream, ratio: f32) !void {
        return try errify(c.SDL_SetAudioStreamFrequencyRatio(self.ptr, ratio));
    }

    /// Get the gain of an audio stream
    pub inline fn getGain(self: *const AudioStream) !f32 {
        try errifyWithValue(c.SDL_GetAudioStreamGain(self.ptr), -1.0);
    }

    /// Change the gain of an audio stream
    pub inline fn setGain(self: *const AudioStream, gain: f32) !void {
        return try errify(c.SDL_SetAudioStreamGain(self.ptr, gain));
    }

    /// Get the current input channel map of an audio stream
    pub inline fn getInputChannelMap(self: *const AudioStream) ![]i32 {
        var count: c_int = undefined;
        const maps = try errify(c.SDL_GetAudioStreamInputChannelMap(self.ptr, &count));
        return maps[0..@intCast(count)];
    }

    /// Get the current output channel map of an audio stream
    pub inline fn getOutputChannelMap(self: *const AudioStream) ![]i32 {
        var count: c_int = undefined;
        const ptr = c.SDL_GetAudioStreamOutputChannelMap(self.ptr, &count);
        return if (ptr != null) ptr.?[0..@intCast(count)] else error.SdlError;
    }

    /// Set the current input channel map of an audio stream
    pub inline fn setInputChannelMap(self: *const AudioStream, chmap: ?[]const i32) !void {
        if (chmap) |map| {
            return try errify(c.SDL_SetAudioStreamInputChannelMap(self.ptr, map.ptr, @intCast(map.len)));
        } else {
            return try errify(c.SDL_SetAudioStreamInputChannelMap(self.ptr, null, 0));
        }
    }

    /// Set the current output channel map of an audio stream
    pub inline fn setOutputChannelMap(self: *const AudioStream, chmap: ?[]const i32) !void {
        if (chmap) |map| {
            return try errify(c.SDL_SetAudioStreamOutputChannelMap(self.ptr, map.ptr, @intCast(map.len)));
        } else {
            return try errify(c.SDL_SetAudioStreamOutputChannelMap(self.ptr, null, 0));
        }
    }

    /// Add data to the stream
    pub inline fn putData(self: *const AudioStream, buf: []const u8) !void {
        return try errify(c.SDL_PutAudioStreamData(self.ptr, buf.ptr, @intCast(buf.len)));
    }

    /// Get converted/resampled data from the stream
    pub inline fn getData(self: *const AudioStream, buf: []u8) !i32 {
        const result = c.SDL_GetAudioStreamData(self.ptr, buf.ptr, @intCast(buf.len));
        return if (result < 0) error.SdlError else result;
    }

    /// Get the number of converted/resampled bytes available
    pub inline fn getAvailable(self: *const AudioStream) !i32 {
        const result = c.SDL_GetAudioStreamAvailable(self.ptr);
        return if (result < 0) error.SdlError else result;
    }

    /// Get the number of bytes currently queued
    pub inline fn getQueued(self: *const AudioStream) !i32 {
        const result = c.SDL_GetAudioStreamQueued(self.ptr);
        return if (result < 0) error.SdlError else result;
    }

    /// Tell the stream that you're done sending data, and anything being buffered should be converted/resampled and made available immediately
    pub inline fn flush(self: *const AudioStream) !void {
        return try errify(c.SDL_FlushAudioStream(self.ptr));
    }

    /// Clear any pending data in the stream
    pub inline fn clear(self: *const AudioStream) !void {
        return try errify(c.SDL_ClearAudioStream(self.ptr));
    }

    /// Use this function to pause audio playback on the audio device associated with an audio stream
    pub inline fn pauseDevice(self: *const AudioStream) !void {
        return try errify(c.SDL_PauseAudioStreamDevice(self.ptr));
    }

    /// Use this function to unpause audio playback on the audio device associated with an audio stream
    pub inline fn resumeDevice(self: *const AudioStream) !void {
        return try errify(c.SDL_ResumeAudioStreamDevice(self.ptr));
    }

    /// Use this function to query if an audio device associated with a stream is paused
    pub inline fn devicePaused(self: *const AudioStream) bool {
        return c.SDL_AudioStreamDevicePaused(self.ptr);
    }

    /// Lock an audio stream for serialized access
    pub inline fn lock(self: *const AudioStream) !void {
        return try errify(c.SDL_LockAudioStream(self.ptr));
    }

    /// Unlock an audio stream for serialized access
    pub inline fn unlock(self: *const AudioStream) !void {
        return try errify(c.SDL_UnlockAudioStream(self.ptr));
    }

    /// Set a callback that runs when data is requested from an audio stream
    pub inline fn setGetCallback(self: *const AudioStream, callback: AudioStreamCallback, userdata: ?*anyopaque) !void {
        return try errify(c.SDL_SetAudioStreamGetCallback(self.ptr, callback, userdata));
    }

    /// Set a callback that runs when data is added to an audio stream
    pub inline fn setPutCallback(self: *const AudioStream, callback: AudioStreamCallback, userdata: ?*anyopaque) !void {
        return try errify(c.SDL_SetAudioStreamPutCallback(self.ptr, callback, userdata));
    }

    /// Query an audio stream for its currently-bound device
    pub inline fn getDevice(self: *const AudioStream) AudioDeviceID {
        return c.SDL_GetAudioStreamDevice(self.ptr);
    }

    /// Free an audio stream
    pub inline fn destroy(self: *const AudioStream) void {
        c.SDL_DestroyAudioStream(self.ptr);
    }
};

/// Use this function to get the number of built-in audio drivers
pub inline fn getNumAudioDrivers() i32 {
    return c.SDL_GetNumAudioDrivers();
}

/// Use this function to get the name of a built in audio driver
pub inline fn getAudioDriver(index: i32) ?[]const u8 {
    return if (c.SDL_GetAudioDriver(index)) |name| std.mem.span(name) else null;
}

/// Get the name of the current audio driver
pub inline fn getCurrentAudioDriver() ?[]const u8 {
    return if (c.SDL_GetCurrentAudioDriver()) |name| std.mem.span(name) else null;
}

/// Get a list of currently-connected audio playback devices
pub inline fn getAudioPlaybackDevices() ![]AudioDeviceID {
    var count: c_int = undefined;
    const devices = try errify(c.SDL_GetAudioPlaybackDevices(&count));
    return devices[0..@intCast(count)];
}

/// Get a list of currently-connected audio recording devices
pub inline fn getAudioRecordingDevices() ![]AudioDeviceID {
    var count: c_int = undefined;
    const devices = try errify(c.SDL_GetAudioRecordingDevices(&count));
    return devices[0..@intCast(count)];
}

/// Get the human-readable name of a specific audio device
pub inline fn getAudioDeviceName(devid: AudioDeviceID) ?[]const u8 {
    return if (c.SDL_GetAudioDeviceName(devid)) |name| std.mem.span(name) else null;
}

/// Get the current audio format of a specific audio device
pub inline fn getAudioDeviceFormat(devid: AudioDeviceID, spec: *AudioSpec, sample_frames: ?*c_int) !void {
    return try errify(c.SDL_GetAudioDeviceFormat(devid, @ptrCast(spec), sample_frames));
}

/// Get the current channel map of an audio device
pub inline fn getAudioDeviceChannelMap(devid: AudioDeviceID) ![]i32 {
    var count: c_int = undefined;
    const ptr = c.SDL_GetAudioDeviceChannelMap(devid, &count);
    return if (ptr != null) ptr.?[0..@intCast(count)] else error.SdlError;
}

/// Open a specific audio device
pub inline fn openAudioDevice(devid: AudioDeviceID, spec: ?*const AudioSpec) !AudioDeviceID {
    return try errify(c.SDL_OpenAudioDevice(devid, if (spec) |s| @ptrCast(s) else null));
}

/// Determine if an audio device is physical (instead of logical)
pub inline fn isAudioDevicePhysical(devid: AudioDeviceID) bool {
    return c.SDL_IsAudioDevicePhysical(devid);
}

/// Determine if an audio device is a playback device (instead of recording)
pub inline fn isAudioDevicePlayback(devid: AudioDeviceID) bool {
    return c.SDL_IsAudioDevicePlayback(devid);
}

/// Use this function to pause audio playback on a specified device
pub inline fn pauseAudioDevice(devid: AudioDeviceID) !void {
    return try errify(c.SDL_PauseAudioDevice(devid));
}

/// Use this function to unpause audio playback on a specified device
pub inline fn resumeAudioDevice(devid: AudioDeviceID) !void {
    return try errify(c.SDL_ResumeAudioDevice(devid));
}

/// Use this function to query if an audio device is paused
pub inline fn audioDevicePaused(devid: AudioDeviceID) bool {
    return c.SDL_AudioDevicePaused(devid);
}

/// Get the gain of an audio device
pub inline fn getAudioDeviceGain(devid: AudioDeviceID) !f32 {
    const gain = c.SDL_GetAudioDeviceGain(devid);
    return if (gain < 0.0) error.SdlError else gain;
}

/// Change the gain of an audio device
pub inline fn setAudioDeviceGain(devid: AudioDeviceID, gain: f32) !void {
    return try errify(c.SDL_SetAudioDeviceGain(devid, gain));
}

/// Close a previously-opened audio device
pub inline fn closeAudioDevice(devid: AudioDeviceID) void {
    c.SDL_CloseAudioDevice(devid);
}

/// Bind a list of audio streams to an audio device
pub inline fn bindAudioStreams(devid: AudioDeviceID, streams: []const *c.SDL_AudioStream) !void {
    return try errify(c.SDL_BindAudioStreams(devid, streams.ptr, @intCast(streams.len)));
}

/// Bind a single audio stream to an audio device
pub inline fn bindAudioStream(devid: AudioDeviceID, stream: *c.SDL_AudioStream) !void {
    return try errify(c.SDL_BindAudioStream(devid, stream));
}

/// Unbind a list of audio streams from their audio devices
pub inline fn unbindAudioStreams(streams: []const *c.SDL_AudioStream) void {
    c.SDL_UnbindAudioStreams(streams.ptr, @intCast(streams.len));
}

/// Unbind a single audio stream from its audio device
pub inline fn unbindAudioStream(stream: *c.SDL_AudioStream) void {
    c.SDL_UnbindAudioStream(stream);
}

/// Convenience function for straightforward audio init for the common case
pub inline fn openAudioDeviceStream(devid: AudioDeviceID, spec: ?*const AudioSpec, callback: AudioStreamCallback, userdata: ?*anyopaque) !AudioStream {
    return .{
        .ptr = try errify(c.SDL_OpenAudioDeviceStream(devid, if (spec) |s| @ptrCast(s) else null, callback, userdata)),
    };
}

/// Set a callback that fires when data is about to be fed to an audio device
pub inline fn setAudioPostmixCallback(devid: AudioDeviceID, callback: c.SDL_AudioPostmixCallback, userdata: ?*anyopaque) !void {
    return try errify(c.SDL_SetAudioPostmixCallback(devid, callback, userdata));
}

/// Load the audio data of a WAVE file into memory
pub inline fn loadWAV_IO(src: *c.SDL_IOStream, closeio: bool, spec: *AudioSpec, audio_buf: *[*]u8, audio_len: *u32) !void {
    return try errify(c.SDL_LoadWAV_IO(src, closeio, @ptrCast(spec), audio_buf, audio_len));
}

/// Loads a WAV from a file path
pub inline fn loadWAV(path: [*:0]const u8, spec: *AudioSpec, audio_buf: [*c][*c]u8, audio_len: *u32) !void {
    return try errify(c.SDL_LoadWAV(path, @ptrCast(spec), audio_buf, audio_len));
}

/// Mix audio data in a specified format
pub inline fn mixAudio(dst: []u8, src: []const u8, format: AudioFormat, volume: f32) !void {
    return try errify(c.SDL_MixAudio(dst.ptr, src.ptr, @intFromEnum(format), @intCast(dst.len), volume));
}

/// Convert some audio data of one format to another format
pub inline fn convertAudioSamples(
    src_spec: *const AudioSpec,
    src_data: []const u8,
    dst_spec: *const AudioSpec,
    dst_data: [*c][*c]u8,
    dst_len: *i32,
) !void {
    return try errify(c.SDL_ConvertAudioSamples(
        @ptrCast(src_spec),
        src_data.ptr,
        @intCast(src_data.len),
        @ptrCast(dst_spec),
        dst_data,
        dst_len,
    ));
}

/// Get the human readable name of an audio format
pub inline fn getAudioFormatName(format: AudioFormat) []const u8 {
    return std.mem.span(c.SDL_GetAudioFormatName(@intFromEnum(format)));
}

/// Get the appropriate memset value for silencing an audio format
pub inline fn getSilenceValueForFormat(format: AudioFormat) i32 {
    return c.SDL_GetSilenceValueForFormat(@intFromEnum(format));
}

// Utility functions for handling audio format flags
pub inline fn audioBitSize(x: u16) u16 {
    return x & AudioFormat.mask_bitsize;
}
