const std = @import("std");

const zsdl = @import("zsdl");
const gpu = zsdl.gpu;
const video = zsdl.video;
const pixels = zsdl.pixels;

test "gpu comprehensive test" {
    errdefer std.log.err("{s}", .{zsdl.@"error".getError()});
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    // 1. First check for GPU support
    const num_drivers = gpu.Device.getNumDrivers();
    std.debug.print("Number of GPU drivers: {}\n", .{num_drivers});

    for (0..@intCast(num_drivers)) |i| {
        const driver_name = try gpu.Device.getDriver(@intCast(i));
        std.debug.print("Driver {}: {s}\n", .{ i, driver_name });
    }

    // 2. Create a device
    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    const device_driver = try device.getDeviceDriver();
    std.debug.print("Using GPU device driver: {s}\n", .{device_driver});

    // 3. Create a window for testing
    var window = try video.Window.create(
        "GPU Test Window",
        800,
        600,
        .{},
    );
    defer window.destroy();

    // 4. Claim the window for GPU operations
    try device.claimWindow(window);
    defer device.releaseWindow(window);

    // 5. Set swapchain parameters
    try device.setSwapchainParameters(window, .sdr, .vsync);

    // 6. Create a texture
    const texture_create_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
            .color_target = true,
        },
        .width = 256,
        .height = 256,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const texture = try device.createTexture(texture_create_info);
    defer device.releaseTexture(texture);

    device.setTextureName(texture, "Test Texture");

    // 7. Create a buffer
    const buffer_create_info = gpu.BufferCreateInfo{
        .usage = .{
            .vertex = true,
        },
        .size = 1024,
    };

    const buffer = try device.createBuffer(buffer_create_info);
    defer device.releaseBuffer(buffer);

    device.setBufferName(buffer, "Test Buffer");

    // 8. Create a transfer buffer
    const transfer_buffer_create_info = gpu.TransferBufferCreateInfo{
        .usage = .upload,
        .size = 1024,
    };

    const transfer_buffer = try device.createTransferBuffer(transfer_buffer_create_info);
    defer device.releaseTransferBuffer(transfer_buffer);

    // 9. Create a sampler
    const sampler_create_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
    };

    const sampler = try device.createSampler(sampler_create_info);
    defer device.releaseSampler(sampler);

    // 10. Create shader for graphics pipeline
    const vertex_shader_code = @embedFile("vert.spv");

    const fragment_shader_code = @embedFile("frag.spv");

    const vertex_shader_create_info = gpu.ShaderCreateInfo{
        .code = vertex_shader_code,
        .entrypoint = "VSMain",
        .format = .{
            .spirv = true,
        },
        .stage = .vertex,
        .num_samplers = 0,
    };

    const shader_format = device.getShaderFormats();
    std.debug.print("Supported shader formats: spirv={}, msl={}, metallib={}\n", .{ shader_format.spirv, shader_format.msl, shader_format.metallib });

    // Only try to create shaders if the device supports the format
    if (shader_format.spirv) {
        const vertex_shader = try device.createShader(vertex_shader_create_info);
        defer device.releaseShader(vertex_shader);

        const fragment_shader_create_info = gpu.ShaderCreateInfo{
            .code = fragment_shader_code,
            .entrypoint = "PSMain",
            .format = .{
                .spirv = true,
            },
            .stage = .fragment,
            .num_samplers = 1,
        };

        const fragment_shader = try device.createShader(fragment_shader_create_info);
        defer device.releaseShader(fragment_shader);

        // 11. Set up vertex input state
        const vertex_buffer_desc = [_]gpu.VertexBufferDescription{
            .{
                .slot = 0,
                .pitch = 5 * @sizeOf(f32), // 3 position + 2 texcoord
                .input_rate = .vertex,
                .instance_step_rate = 0,
            },
        };

        const vertex_attrs = [_]gpu.VertexAttribute{
            .{
                .location = 0,
                .buffer_slot = 0,
                .format = .float3,
                .offset = 0,
            },
            .{
                .location = 1,
                .buffer_slot = 0,
                .format = .float2,
                .offset = 3 * @sizeOf(f32),
            },
        };

        const vertex_input_state = gpu.VertexInputState{
            .vertex_buffer_descriptions = &vertex_buffer_desc,
            .vertex_attributes = &vertex_attrs,
        };

        // 12. Create graphics pipeline
        const color_targets = [_]gpu.ColorTargetDescription{
            .{
                .format = .r8g8b8a8_unorm,
                .blend_state = .{
                    .src_color_blendfactor = .src_alpha,
                    .dst_color_blendfactor = .one_minus_src_alpha,
                    .color_blend_op = .add,
                    .src_alpha_blendfactor = .one,
                    .dst_alpha_blendfactor = .one_minus_src_alpha,
                    .alpha_blend_op = .add,
                    .color_write_mask = .{
                        .r = true,
                        .g = true,
                        .b = true,
                        .a = true,
                    },
                    .enable_blend = true,
                    .enable_color_write_mask = true,
                },
            },
        };

        const graphics_pipeline_create_info = gpu.GraphicsPipelineCreateInfo{
            .vertex_shader = vertex_shader,
            .fragment_shader = fragment_shader,
            .vertex_input_state = vertex_input_state,
            .primitive_type = .triangle_list,
            .rasterizer_state = .{
                .fill_mode = .fill,
                .cull_mode = .back,
                .front_face = .clockwise,
                .enable_depth_clip = true,
            },
            .multisample_state = .{
                .sample_count = .@"1",
                .sample_mask = 0x0,
            },
            .depth_stencil_state = .{
                .compare_op = .less,
                .enable_depth_test = true,
                .enable_depth_write = true,
            },
            .target_info = .{
                .color_target_descriptions = &color_targets,
                .has_depth_stencil_target = false,
            },
        };

        const graphics_pipeline = try device.createGraphicsPipeline(graphics_pipeline_create_info);
        defer device.releaseGraphicsPipeline(graphics_pipeline);

        // 13. Acquire command buffer and perform rendering
        var cmd_buffer = try device.acquireCommandBuffer();

        // 14. Map transfer buffer and write vertex data
        const ptr = try device.mapTransferBuffer(transfer_buffer, false);
        defer device.unmapTransferBuffer(transfer_buffer);

        const vertices = @as([*]f32, @ptrCast(@alignCast(ptr)))[0..20];

        // Triangle vertices (position + texcoord)
        vertices[0] = -0.5;
        vertices[1] = -0.5;
        vertices[2] = 0.0;
        vertices[3] = 0.0;
        vertices[4] = 0.0;
        vertices[5] = 0.5;
        vertices[6] = -0.5;
        vertices[7] = 0.0;
        vertices[8] = 1.0;
        vertices[9] = 0.0;
        vertices[10] = 0.0;
        vertices[11] = 0.5;
        vertices[12] = 0.0;
        vertices[13] = 0.5;
        vertices[14] = 1.0;

        // 15. Begin copy pass to upload data to GPU buffer
        var copy_pass = try cmd_buffer.beginCopyPass();

        const transfer_location = gpu.TransferBufferLocation{
            .transfer_buffer = transfer_buffer,
            .offset = 0,
        };

        const buffer_region = gpu.BufferRegion{
            .buffer = buffer,
            .offset = 0,
            .size = 15 * @sizeOf(f32),
        };

        copy_pass.uploadToBuffer(&transfer_location, &buffer_region, false);
        copy_pass.end();

        // 16. Acquire swapchain texture
        var width: u32 = undefined;
        var height: u32 = undefined;

        const swapchain_texture = try cmd_buffer.acquireSwapchainTexture(&window, &width, &height);

        // 17. Begin render pass
        const color_target_info = [_]gpu.ColorTargetInfo{
            .{
                .texture = swapchain_texture,
                .clear_color = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
                .load_op = .clear,
                .store_op = .store,
            },
        };

        var render_pass = try cmd_buffer.beginRenderPass(&color_target_info, null);

        // 18. Set up rendering state
        render_pass.bindGraphicsPipeline(graphics_pipeline);

        const viewport = gpu.Viewport{
            .x = 0,
            .y = 0,
            .w = @floatFromInt(width),
            .h = @floatFromInt(height),
            .min_depth = 0.0,
            .max_depth = 1.0,
        };

        render_pass.setViewport(viewport);

        const scissor = zsdl.rect.Rect{
            .x = 0,
            .y = 0,
            .w = @intCast(width),
            .h = @intCast(height),
        };

        render_pass.setScissor(scissor);

        // 19. Bind vertex buffer
        const buffer_binding = [_]gpu.BufferBinding{
            .{
                .buffer = buffer,
                .offset = 0,
            },
        };

        render_pass.bindVertexBuffers(0, &buffer_binding);

        // 20. Set up texture sampler binding
        const texture_sampler_binding = [_]gpu.TextureSamplerBinding{
            .{
                .texture = texture,
                .sampler = sampler,
            },
        };

        render_pass.bindFragmentSamplers(0, &texture_sampler_binding);

        // 21. Draw primitives
        render_pass.drawPrimitives(3, 1, 0, 0);

        // 22. End render pass
        render_pass.end();

        // 23. Submit command buffer
        try cmd_buffer.submit();

        // 24. Wait for GPU to finish
        try device.waitForIdle();
    } else {
        std.debug.print("Skipping shader creation as the device doesn't support SPIRV\n", .{});
    }

    // 25. Test texture format utilities
    const format_size = gpu.Device.textureFormatTexelBlockSize(.r8g8b8a8_unorm);
    std.debug.print("Texel block size for R8G8B8A8_UNORM: {} bytes\n", .{format_size});

    const supports_format = device.textureSupportsFormat(.r8g8b8a8_unorm, .@"2d", .{
        .sampler = true,
        .color_target = true,
    });
    std.debug.print("Device supports R8G8B8A8_UNORM for 2D textures: {}\n", .{supports_format});

    const supports_msaa = device.textureSupportsSampleCount(.r8g8b8a8_unorm, .@"4");
    std.debug.print("Device supports 4x MSAA for R8G8B8A8_UNORM: {}\n", .{supports_msaa});

    const texture_size = gpu.Device.calculateTextureFormatSize(.r8g8b8a8_unorm, 256, 256, 1);
    std.debug.print("Size of 256x256 R8G8B8A8_UNORM texture: {} bytes\n", .{texture_size});
}
