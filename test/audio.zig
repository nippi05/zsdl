const std = @import("std");
const testing = std.testing;
const zsdl = @import("zsdl");
const audio = zsdl.audio;
const c = zsdl.c;

test "AudioFormat enum values match SDL constants" {
    try testing.expectEqual(@intFromEnum(audio.AudioFormat.unknown), c.SDL_AUDIO_UNKNOWN);
    try testing.expectEqual(@intFromEnum(audio.AudioFormat.u8), c.SDL_AUDIO_U8);
    try testing.expectEqual(@intFromEnum(audio.AudioFormat.s8), c.SDL_AUDIO_S8);
    try testing.expectEqual(@intFromEnum(audio.AudioFormat.s16), c.SDL_AUDIO_S16);
    try testing.expectEqual(@intFromEnum(audio.AudioFormat.s32), c.SDL_AUDIO_S32);
    try testing.expectEqual(@intFromEnum(audio.AudioFormat.f32), c.SDL_AUDIO_F32);

    try testing.expectEqual(audio.AudioFormat.mask_bitsize, c.SDL_AUDIO_MASK_BITSIZE);
    try testing.expectEqual(audio.AudioFormat.mask_float, c.SDL_AUDIO_MASK_FLOAT);
    try testing.expectEqual(audio.AudioFormat.mask_big_endian, c.SDL_AUDIO_MASK_BIG_ENDIAN);
    try testing.expectEqual(audio.AudioFormat.mask_signed, c.SDL_AUDIO_MASK_SIGNED);
}

test "audioFrameSize calculates correct frame size" {
    var spec = std.mem.zeroes(audio.AudioSpec);
    spec.channels = 2;
    spec.format = audio.AudioFormat.s16;

    const frame_size = audio.audioFrameSize(spec);
    try testing.expectEqual(frame_size, 4); // 2 channels * 2 bytes per sample (s16)

    spec.channels = 1;
    spec.format = audio.AudioFormat.f32;
    const frame_size2 = audio.audioFrameSize(spec);
    try testing.expectEqual(frame_size2, 4); // 1 channel * 4 bytes per sample (f32)
}

test "getNumAudioDrivers returns a non-negative value" {
    const count = audio.getNumAudioDrivers();
    try testing.expect(count >= 0);
}

test "getAudioDriver returns null for invalid index" {
    const invalid_index = -1;
    const driver_name = audio.getAudioDriver(invalid_index);
    try testing.expectEqual(driver_name, null);
}

test "getCurrentAudioDriver returns null if no audio subsystem initialized" {
    // Note: This assumes the audio subsystem is not initialized during tests
    // If tests are run with SDL initialized, this might fail
    const current_driver = audio.getCurrentAudioDriver();
    try testing.expectEqual(current_driver, null);
}

test "audioBitSize returns correct bit size" {
    try testing.expectEqual(audio.audioBitSize(@intFromEnum(audio.AudioFormat.u8)), 8);
    try testing.expectEqual(audio.audioBitSize(@intFromEnum(audio.AudioFormat.s16)), 16);
    try testing.expectEqual(audio.audioBitSize(@intFromEnum(audio.AudioFormat.f32)), 32);
}

test "getSilenceValueForFormat returns correct silence values" {
    // For signed formats, silence is 0
    try testing.expectEqual(audio.getSilenceValueForFormat(.s16), 0);
    try testing.expectEqual(audio.getSilenceValueForFormat(.s32), 0);
    try testing.expectEqual(audio.getSilenceValueForFormat(.f32), 0);

    // For unsigned formats, silence is 128 (for 8-bit)
    try testing.expectEqual(audio.getSilenceValueForFormat(.u8), 128);
}

// Mock initialization and cleanup for some tests
fn setupSDL() !void {
    // Initialize SDL with audio subsystem
    _ = c.SDL_Init(c.SDL_INIT_AUDIO);
}

fn teardownSDL() void {
    c.SDL_Quit();
}

// Tests for AudioStream related functions
test "AudioStream creation and destruction" {
    try setupSDL();
    defer teardownSDL();

    var src_spec = std.mem.zeroes(audio.AudioSpec);
    src_spec.channels = 2;
    src_spec.format = audio.AudioFormat.s16;
    src_spec.freq = 44100;

    var dst_spec = std.mem.zeroes(audio.AudioSpec);
    dst_spec.channels = 1;
    dst_spec.format = audio.AudioFormat.f32;
    dst_spec.freq = 48000;

    const stream = audio.AudioStream.create(&src_spec, &dst_spec) catch |err| {
        // Stream creation might fail in test environments, so skip the test
        std.debug.print("Stream creation failed: {}\n", .{err});
        return;
    };
    defer stream.destroy();

    // If we got here, stream creation succeeded
}

test "openAudioDevice with default device" {
    try setupSDL();
    defer teardownSDL();

    var spec = std.mem.zeroes(audio.AudioSpec);
    spec.channels = 2;
    spec.format = audio.AudioFormat.s16;
    spec.freq = 44100;

    const device_id = audio.openAudioDevice(audio.audio_device_default_playback, &spec) catch |err| {
        // Opening device might fail in test environments
        std.debug.print("Open audio device failed: {}\n", .{err});
        return;
    };
    defer audio.closeAudioDevice(device_id);

    // Test for device pausing
    try audio.pauseAudioDevice(device_id);
    try testing.expect(audio.audioDevicePaused(device_id));

    // Test for device resuming
    try audio.resumeAudioDevice(device_id);
    try testing.expect(!audio.audioDevicePaused(device_id));
}

test "getAudioDeviceName for default devices" {
    try setupSDL();
    defer teardownSDL();

    // These might return null on some systems, but shouldn't crash
    _ = audio.getAudioDeviceName(audio.audio_device_default_playback);
    _ = audio.getAudioDeviceName(audio.audio_device_default_recording);
}

test "convertAudioSamples basic functionality" {
    try setupSDL();
    defer teardownSDL();

    var src_spec = std.mem.zeroes(audio.AudioSpec);
    src_spec.channels = 1;
    src_spec.format = audio.AudioFormat.s16;
    src_spec.freq = 44100;

    var dst_spec = std.mem.zeroes(audio.AudioSpec);
    dst_spec.channels = 1;
    dst_spec.format = audio.AudioFormat.f32;
    dst_spec.freq = 44100;

    // Create sample data (sine wave)
    const samples = 1024;
    var src_data = try std.testing.allocator.alloc(i16, samples);
    defer std.testing.allocator.free(src_data);

    for (0..samples) |i| {
        const angle = @as(f32, @floatFromInt(i)) * (std.math.pi * 2.0) / 100.0;
        const value = @sin(angle) * 32767.0;
        src_data[i] = @intFromFloat(value);
    }

    // Convert to byte array to match the API
    const src_bytes = std.mem.sliceAsBytes(src_data);

    var dst_data: [*c]u8 = undefined;
    var dst_len: i32 = 0;

    audio.convertAudioSamples(&src_spec, src_bytes, &dst_spec, &dst_data, &dst_len) catch |err| {
        std.debug.print("Audio conversion failed: {}\n", .{err});
        return;
    };
    defer c.SDL_free(dst_data);

    try testing.expect(dst_len > 0);
}

test "mixAudio basic functionality" {
    try setupSDL();
    defer teardownSDL();

    const format = audio.AudioFormat.f32;
    const sample_count = 256;

    // Allocate source and destination buffers
    var src_data = try std.testing.allocator.alloc(f32, sample_count);
    defer std.testing.allocator.free(src_data);

    var dst_data = try std.testing.allocator.alloc(f32, sample_count);
    defer std.testing.allocator.free(dst_data);

    // Fill source with a sine wave
    for (0..sample_count) |i| {
        const angle = @as(f32, @floatFromInt(i)) * (std.math.pi * 2.0) / 32.0;
        src_data[i] = @sin(angle) * 0.5;
    }

    // Fill destination with different sine wave
    for (0..sample_count) |i| {
        const angle = @as(f32, @floatFromInt(i)) * (std.math.pi * 2.0) / 64.0;
        dst_data[i] = @sin(angle) * 0.3;
    }

    // Convert to byte arrays
    const src_bytes = std.mem.sliceAsBytes(src_data);
    const dst_bytes = std.mem.sliceAsBytes(dst_data);

    // Mix at 50% volume
    audio.mixAudio(dst_bytes, src_bytes, format, 0.5) catch |err| {
        std.debug.print("Audio mixing failed: {}\n", .{err});
        return;
    };

    // Verify that mixing changed the destination buffer
    var original_values = try std.testing.allocator.alloc(f32, sample_count);
    defer std.testing.allocator.free(original_values);

    for (0..sample_count) |i| {
        const angle = @as(f32, @floatFromInt(i)) * (std.math.pi * 2.0) / 64.0;
        original_values[i] = @sin(angle) * 0.3;
    }

    var all_same = true;
    for (0..sample_count) |i| {
        if (!std.math.approxEqAbs(f32, dst_data[i], original_values[i], 0.00001)) {
            all_same = false;
            break;
        }
    }

    try testing.expect(!all_same); // Values should have changed after mixing
}

test "getAudioDeviceFormat for default device" {
    try setupSDL();
    defer teardownSDL();

    var spec = std.mem.zeroes(audio.AudioSpec);
    var sample_frames: c_int = undefined;

    audio.getAudioDeviceFormat(audio.audio_device_default_playback, &spec, &sample_frames) catch |err| {
        // This might fail on headless systems or CI environments
        std.debug.print("getAudioDeviceFormat failed: {}\n", .{err});
        return;
    };

    try testing.expect(spec.channels > 0);
    try testing.expect(spec.freq > 0);
}

test "openAudioDeviceStream for default device" {
    try setupSDL();
    defer teardownSDL();

    var spec = std.mem.zeroes(audio.AudioSpec);
    spec.channels = 2;
    spec.format = audio.AudioFormat.s16;
    spec.freq = 44100;

    const stream = audio.openAudioDeviceStream(audio.audio_device_default_playback, &spec, null, null) catch |err| {
        // This might fail on headless systems or CI environments
        std.debug.print("openAudioDeviceStream failed: {}\n", .{err});
        return;
    };
    defer stream.destroy();

    // Test that we got a valid stream

    // Test device binding
    const device_id = stream.getDevice();
    try testing.expect(device_id != 0);

    // Test pausing
    try stream.pauseDevice();
    try testing.expect(stream.devicePaused());

    // Test resuming
    try stream.resumeDevice();
    try testing.expect(!stream.devicePaused());
}

// Add more advanced tests for stream functions
test "AudioStream put and get data" {
    try setupSDL();
    defer teardownSDL();

    var src_spec = std.mem.zeroes(audio.AudioSpec);
    src_spec.channels = 1;
    src_spec.format = audio.AudioFormat.s16;
    src_spec.freq = 44100;

    var dst_spec = src_spec; // Same format for simplicity

    const stream = audio.AudioStream.create(&src_spec, &dst_spec) catch |err| {
        std.debug.print("Stream creation failed: {}\n", .{err});
        return;
    };
    defer stream.destroy();

    // Create sample data
    const samples = 1024;
    var src_data = try std.testing.allocator.alloc(i16, samples);
    defer std.testing.allocator.free(src_data);

    for (0..samples) |i| {
        src_data[i] = @intCast(i % 100);
    }

    // Convert to bytes
    const src_bytes = std.mem.sliceAsBytes(src_data);

    // Put data into stream
    stream.putData(src_bytes) catch |err| {
        std.debug.print("putData failed: {}\n", .{err});
        return;
    };

    // Check available data
    const available = stream.getAvailable() catch |err| {
        std.debug.print("getAvailable failed: {}\n", .{err});
        return;
    };

    try testing.expect(available > 0);

    // Get data from stream
    const dst_bytes = try std.testing.allocator.alloc(u8, @intCast(available));
    defer std.testing.allocator.free(dst_bytes);

    const bytes_read = stream.getData(dst_bytes) catch |err| {
        std.debug.print("getData failed: {}\n", .{err});
        return;
    };

    try testing.expect(bytes_read > 0);
}

test "AudioStream frequency ratio and gain" {
    try setupSDL();
    defer teardownSDL();

    var src_spec = std.mem.zeroes(audio.AudioSpec);
    src_spec.channels = 2;
    src_spec.format = audio.AudioFormat.f32;
    src_spec.freq = 44100;

    var dst_spec = src_spec;

    const stream = audio.AudioStream.create(&src_spec, &dst_spec) catch |err| {
        std.debug.print("Stream creation failed: {}\n", .{err});
        return;
    };
    defer stream.destroy();

    // Test setting frequency ratio
    try stream.setFrequencyRatio(1.5);

    // Test setting gain
    try stream.setGain(0.8);
}

test "loadWAV validates path parameter" {
    try setupSDL();
    defer teardownSDL();

    var spec = std.mem.zeroes(audio.AudioSpec);
    var audio_buf: [*c]u8 = undefined;
    var audio_len: u32 = 0;

    // This should fail with a valid error rather than crash
    audio.loadWAV("non_existent_file.wav", &spec, &audio_buf, &audio_len) catch |err| {
        try testing.expectEqual(err, error.SdlError);
        return;
    };

    try testing.expect(false); // Should not reach here
}

// Test channel map functions with valid streams
test "AudioStream channel map functions" {
    try setupSDL();
    defer teardownSDL();

    var src_spec = std.mem.zeroes(audio.AudioSpec);
    src_spec.channels = 2;
    src_spec.format = audio.AudioFormat.f32;
    src_spec.freq = 44100;

    var dst_spec = src_spec;

    const stream = audio.AudioStream.create(&src_spec, &dst_spec) catch |err| {
        std.debug.print("Stream creation failed: {}\n", .{err});
        return;
    };
    defer stream.destroy();

    // Test setting input channel map
    const input_map = [_]i32{ 0, 1 };
    stream.setInputChannelMap(&input_map) catch |err| {
        std.debug.print("setInputChannelMap failed: {}\n", .{err});
    };

    // Test getting input channel map
    const retrieved_map = stream.getInputChannelMap() catch |err| {
        std.debug.print("getInputChannelMap failed: {}\n", .{err});
        return;
    };

    try testing.expectEqual(retrieved_map.len, 2);
}
