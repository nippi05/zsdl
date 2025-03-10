const std = @import("std");
const zsdl = @import("zsdl");
const haptic = zsdl.haptic;
const Haptic = haptic.Haptic;

test "SDL haptic enumeration" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    const haptic_devices = haptic.getHaptics() catch |err| {
        std.debug.print("Error getting haptics: {}\n", .{err});
        return;
    };

    std.debug.print("Found {} haptic device(s)\n", .{haptic_devices.len});

    if (haptic_devices.len > 0) {
        for (haptic_devices, 0..) |id, i| {
            if (haptic.getHapticNameForID(id)) |name| {
                std.debug.print("Haptic device {}: {s}\n", .{ i, name });
            } else {
                std.debug.print("Haptic device {} (unnamed)\n", .{i});
            }
        }
    }

    std.debug.print("Mouse haptic: {}\n", .{haptic.isMouseHaptic()});
}

test "SDL haptic device capabilities" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    const haptic_devices = haptic.getHaptics() catch |err| {
        std.debug.print("Error getting haptics: {}\n", .{err});
        return;
    };

    if (haptic_devices.len == 0) {
        std.debug.print("No haptic devices found, skipping capability test\n", .{});
        return;
    }

    // Open the first haptic device
    var device = haptic.openHaptic(haptic_devices[0]) catch |err| {
        std.debug.print("Error opening haptic device: {}\n", .{err});
        return;
    };
    defer device.close();

    // Test device capabilities
    std.debug.print("Device ID: {}\n", .{device.getID()});

    if (device.getName()) |name| {
        std.debug.print("Device name: {s}\n", .{name});
    }

    const features = device.getFeatures();
    std.debug.print("Device features: 0x{X:0>8}\n", .{features});

    const num_axes = device.getNumAxes() catch |err| {
        std.debug.print("Error getting axes: {}\n", .{err});
        return;
    };
    std.debug.print("Number of axes: {}\n", .{num_axes});

    const max_effects = device.getMaxEffects() catch |err| {
        std.debug.print("Error getting max effects: {}\n", .{err});
        return;
    };
    std.debug.print("Max effects: {}\n", .{max_effects});

    const max_playing = device.getMaxEffectsPlaying() catch |err| {
        std.debug.print("Error getting max playing effects: {}\n", .{err});
        return;
    };
    std.debug.print("Max playing effects: {}\n", .{max_playing});
}

test "SDL haptic rumble" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    const haptic_devices = haptic.getHaptics() catch |err| {
        std.debug.print("Error getting haptics: {}\n", .{err});
        return;
    };

    if (haptic_devices.len == 0) {
        std.debug.print("No haptic devices found, skipping rumble test\n", .{});
        return;
    }

    // Open the first haptic device
    var device = haptic.openHaptic(haptic_devices[0]) catch |err| {
        std.debug.print("Error opening haptic device: {}\n", .{err});
        return;
    };
    defer device.close();

    // Test rumble capability
    const rumble_supported = device.rumbleSupported();
    std.debug.print("Rumble supported: {}\n", .{rumble_supported});

    if (rumble_supported) {
        // Initialize rumble
        device.initRumble() catch |err| {
            std.debug.print("Error initializing rumble: {}\n", .{err});
            return;
        };

        // Play a short rumble effect
        std.debug.print("Playing rumble effect...\n", .{});
        device.playRumble(0.5, 500) catch |err| {
            std.debug.print("Error playing rumble: {}\n", .{err});
            return;
        };

        // Wait for the effect to complete
        std.time.sleep(std.time.ns_per_ms * 600);

        // Stop the rumble if it's still going
        device.stopRumble() catch |err| {
            std.debug.print("Error stopping rumble: {}\n", .{err});
        };
    }
}

test "SDL haptic effects" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    const haptic_devices = haptic.getHaptics() catch |err| {
        std.debug.print("Error getting haptics: {}\n", .{err});
        return;
    };

    if (haptic_devices.len == 0) {
        std.debug.print("No haptic devices found, skipping effects test\n", .{});
        return;
    }

    // Open the first haptic device
    var device = haptic.openHaptic(haptic_devices[0]) catch |err| {
        std.debug.print("Error opening haptic device: {}\n", .{err});
        return;
    };
    defer device.close();

    // Create a simple constant effect
    var effect: haptic.HapticEffect = .{
        .constant = .{
            .type = .constant,
            .direction = .{
                .type = .polar,
            },
            .length = 1000,
            .delay = 0,
            .button = 0,
            .interval = 0,
            .level = 5000,
            .attack_length = 100,
            .attack_level = 0,
            .fade_length = 100,
            .fade_level = 0,
        },
    };

    // Check if the effect is supported
    const supported = device.effectSupported(&effect);
    std.debug.print("Constant effect supported: {}\n", .{supported});

    if (supported) {
        // Create the effect
        const effect_id = device.createEffect(&effect) catch |err| {
            std.debug.print("Error creating effect: {}\n", .{err});
            return;
        };
        defer device.destroyEffect(effect_id);

        // Run the effect
        std.debug.print("Running constant effect...\n", .{});
        device.runEffect(effect_id, 1) catch |err| {
            std.debug.print("Error running effect: {}\n", .{err});
            return;
        };

        // Wait for the effect to complete
        std.time.sleep(std.time.ns_per_ms * 1100);

        // Stop the effect if it's still running
        device.stopEffect(effect_id) catch |err| {
            std.debug.print("Error stopping effect: {}\n", .{err});
        };
    }
}

test "SDL haptic mouse" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    if (haptic.isMouseHaptic()) {
        std.debug.print("Mouse has haptic capabilities\n", .{});

        var mouse_haptic = haptic.openHapticFromMouse() catch |err| {
            std.debug.print("Error opening mouse haptic: {}\n", .{err});
            return;
        };
        defer mouse_haptic.close();

        std.debug.print("Mouse haptic opened successfully\n", .{});

        if (mouse_haptic.rumbleSupported()) {
            mouse_haptic.initRumble() catch |err| {
                std.debug.print("Error initializing mouse rumble: {}\n", .{err});
                return;
            };

            std.debug.print("Playing mouse rumble...\n", .{});
            mouse_haptic.playRumble(0.3, 300) catch |err| {
                std.debug.print("Error playing mouse rumble: {}\n", .{err});
            };

            std.time.sleep(std.time.ns_per_ms * 400);
        } else {
            std.debug.print("Mouse does not support rumble\n", .{});
        }
    } else {
        std.debug.print("Mouse does not have haptic capabilities\n", .{});
    }
}

test "SDL haptic getHapticFromID" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    const haptic_devices = haptic.getHaptics() catch |err| {
        std.debug.print("Error getting haptics: {}\n", .{err});
        return;
    };

    if (haptic_devices.len == 0) {
        std.debug.print("No haptic devices found, skipping getHapticFromID test\n", .{});
        return;
    }

    // Open the first haptic device
    var device = haptic.openHaptic(haptic_devices[0]) catch |err| {
        std.debug.print("Error opening haptic device: {}\n", .{err});
        return;
    };
    defer device.close();

    // Get the device ID
    const id = device.getID();
    std.debug.print("Device ID: {}\n", .{id});

    // Test getHapticFromID
    if (haptic.getHapticFromID(id)) |obtained_device| {
        std.debug.print("Successfully retrieved device via getHapticFromID\n", .{});

        // Compare pointers
        if (obtained_device.ptr == device.ptr) {
            std.debug.print("Device pointers match\n", .{});
        } else {
            std.debug.print("Device pointers don't match (unexpected)\n", .{});
        }
    } else {
        std.debug.print("Failed to retrieve device via getHapticFromID (unexpected)\n", .{});
    }
}

test "SDL haptic controls" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    const haptic_devices = haptic.getHaptics() catch |err| {
        std.debug.print("Error getting haptics: {}\n", .{err});
        return;
    };

    if (haptic_devices.len == 0) {
        std.debug.print("No haptic devices found, skipping controls test\n", .{});
        return;
    }

    // Open the first haptic device
    var device = haptic.openHaptic(haptic_devices[0]) catch |err| {
        std.debug.print("Error opening haptic device: {}\n", .{err});
        return;
    };
    defer device.close();

    // Test gain control if supported
    const features = device.getFeatures();
    if ((features & zsdl.c.SDL_HAPTIC_GAIN) != 0) {
        std.debug.print("Setting gain to 50%...\n", .{});
        device.setGain(50) catch |err| {
            std.debug.print("Error setting gain: {}\n", .{err});
        };
    } else {
        std.debug.print("Device does not support gain control\n", .{});
    }

    // Test autocenter control if supported
    if ((features & zsdl.c.SDL_HAPTIC_AUTOCENTER) != 0) {
        std.debug.print("Setting autocenter to 0...\n", .{});
        device.setAutocenter(0) catch |err| {
            std.debug.print("Error setting autocenter: {}\n", .{err});
        };
    } else {
        std.debug.print("Device does not support autocenter control\n", .{});
    }

    // Test pause/resume if supported
    if ((features & zsdl.c.SDL_HAPTIC_PAUSE) != 0) {
        std.debug.print("Testing pause/resume...\n", .{});
        device.pause() catch |err| {
            std.debug.print("Error pausing device: {}\n", .{err});
        };

        std.time.sleep(std.time.ns_per_ms * 100);

        device.@"resume"() catch |err| {
            std.debug.print("Error resuming device: {}\n", .{err});
        };
    } else {
        std.debug.print("Device does not support pause/resume\n", .{});
    }
}

test "SDL haptic stopEffects" {
    try zsdl.init(.{
        .haptic = true,
        .joystick = true,
    });
    defer zsdl.quit();

    const haptic_devices = haptic.getHaptics() catch |err| {
        std.debug.print("Error getting haptics: {}\n", .{err});
        return;
    };

    if (haptic_devices.len == 0) {
        std.debug.print("No haptic devices found, skipping stopEffects test\n", .{});
        return;
    }

    // Open the first haptic device
    var device = haptic.openHaptic(haptic_devices[0]) catch |err| {
        std.debug.print("Error opening haptic device: {}\n", .{err});
        return;
    };
    defer device.close();

    // Test stopEffects function
    std.debug.print("Testing stopEffects...\n", .{});
    device.stopEffects() catch |err| {
        std.debug.print("Error stopping effects: {}\n", .{err});
    };
    std.debug.print("All effects stopped\n", .{});
}
