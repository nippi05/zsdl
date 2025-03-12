const std = @import("std");

const zsdl = @import("zsdl");
const gpu = zsdl.gpu;
const video = zsdl.video;
const pixels = zsdl.pixels;
const rect = zsdl.rect;

// Include embedded shader code
const vertex_shader_code = @embedFile("vert.spv");
const fragment_shader_code = @embedFile("frag.spv");

// Utility function to check if a device supports SPIRV shaders
fn deviceSupportsSPIRV(device: *const gpu.Device) bool {
    const shader_format = device.getShaderFormats();
    return shader_format.spirv;
}

// Test initialization and device creation
test "gpu initialization" {
    errdefer std.log.err("{s}", .{zsdl.@"error".getError()});
    // Setup: Init SDL with video subsystem
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    // 1. Check for GPU driver availability
    const num_drivers = gpu.Device.getNumDrivers();
    std.debug.print("Number of GPU drivers: {}\n", .{num_drivers});

    for (0..@intCast(num_drivers)) |i| {
        const driver_name = try gpu.Device.getDriver(@intCast(i));
        std.debug.print("Driver {}: {s}\n", .{ i, driver_name });
    }

    // 2. Create device with default settings
    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    const device_driver = try device.getDeviceDriver();
    std.debug.print("Using GPU device driver: {s}\n", .{device_driver});

    // 3. Create device with custom properties
    const custom_device_props = gpu.DeviceProperties{
        .debug_mode = true,
        .prefer_low_power = true,
        .shaders_spirv = true,
    };

    var custom_device = try gpu.Device.createWithProperties(custom_device_props);
    defer custom_device.destroy();

    // 4. Test shader format support
    const shader_formats = device.getShaderFormats();
    std.debug.print("Supported shader formats:\n", .{});
    std.debug.print("  SPIRV: {}\n", .{shader_formats.spirv});
    std.debug.print("  DXBC: {}\n", .{shader_formats.dxbc});
    std.debug.print("  DXIL: {}\n", .{shader_formats.dxil});
    std.debug.print("  MSL: {}\n", .{shader_formats.msl});
    std.debug.print("  Metallib: {}\n", .{shader_formats.metallib});
    std.debug.print("  Private: {}\n", .{shader_formats.private});
}

// Test window and swapchain creation
test "gpu window operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // 1. Create a window
    var window = try video.Window.create(
        "GPU Test Window",
        800,
        600,
        .{ .borderless = true },
    );
    defer window.destroy();

    // 2. Claim the window for GPU operations
    try device.claimWindow(window);
    defer device.releaseWindow(window);

    // 3. Test swapchain composition support
    const supports_sdr = device.windowSupportsSwapchainComposition(&window, .sdr);
    const supports_hdr = device.windowSupportsSwapchainComposition(&window, .hdr10_st2084);

    std.debug.print("Window supports SDR composition: {}\n", .{supports_sdr});
    std.debug.print("Window supports HDR10 composition: {}\n", .{supports_hdr});

    // 4. Test present mode support
    const supports_vsync = device.windowSupportsPresentMode(&window, .vsync);
    const supports_immediate = device.windowSupportsPresentMode(&window, .immediate);
    const supports_mailbox = device.windowSupportsPresentMode(&window, .mailbox);

    std.debug.print("Window supports VSync: {}\n", .{supports_vsync});
    std.debug.print("Window supports immediate present: {}\n", .{supports_immediate});
    std.debug.print("Window supports mailbox present: {}\n", .{supports_mailbox});

    // 5. Set swapchain parameters
    if (supports_sdr and supports_vsync) {
        try device.setSwapchainParameters(window, .sdr, .vsync);
    }

    // 6. Get swapchain texture format
    const swapchain_format = device.getSwapchainTextureFormat(window);
    std.debug.print("Swapchain texture format: {}\n", .{swapchain_format});

    // 7. Set max frames in flight
    try device.setAllowedFramesInFlight(2);
}

// Test buffer operations
test "gpu buffer operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // 1. Create a vertex buffer
    const vertex_buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .vertex = true,
        },
        .size = 1024,
    };

    const vertex_buffer = try device.createBuffer(vertex_buffer_info);
    defer device.releaseBuffer(vertex_buffer);
    device.setBufferName(vertex_buffer, "Vertex Buffer");

    // 2. Create an index buffer
    const index_buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .index = true,
        },
        .size = 512,
    };

    const index_buffer = try device.createBuffer(index_buffer_info);
    defer device.releaseBuffer(index_buffer);
    device.setBufferName(index_buffer, "Index Buffer");

    // 3. Create a storage buffer for compute
    const storage_buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .storage_compute_read = true,
            .storage_compute_write = true,
        },
        .size = 2048,
    };

    const storage_buffer = try device.createBuffer(storage_buffer_info);
    defer device.releaseBuffer(storage_buffer);
    device.setBufferName(storage_buffer, "Storage Buffer");

    // 4. Create an indirect buffer
    const indirect_buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .indirect = true,
        },
        .size = 256,
    };

    const indirect_buffer = try device.createBuffer(indirect_buffer_info);
    defer device.releaseBuffer(indirect_buffer);
    device.setBufferName(indirect_buffer, "Indirect Buffer");

    // 5. Create transfer buffers for upload and download
    const upload_buffer_info = gpu.TransferBufferCreateInfo{
        .usage = .upload,
        .size = 4096,
    };

    const upload_buffer = try device.createTransferBuffer(upload_buffer_info);
    defer device.releaseTransferBuffer(upload_buffer);

    const download_buffer_info = gpu.TransferBufferCreateInfo{
        .usage = .download,
        .size = 4096,
    };

    const download_buffer = try device.createTransferBuffer(download_buffer_info);
    defer device.releaseTransferBuffer(download_buffer);

    // 6. Map and write to upload buffer
    const upload_ptr = try device.mapTransferBuffer(upload_buffer, false);
    defer device.unmapTransferBuffer(upload_buffer);

    // Write some data to the buffer (e.g., triangle vertices)
    const vertices = @as([*]f32, @ptrCast(@alignCast(upload_ptr)))[0..18];

    // Triangle vertices (position xyz)
    vertices[0] = -0.5;
    vertices[1] = -0.5;
    vertices[2] = 0.0;

    vertices[3] = 0.5;
    vertices[4] = -0.5;
    vertices[5] = 0.0;

    vertices[6] = 0.0;
    vertices[7] = 0.5;
    vertices[8] = 0.0;

    // Triangle colors (rgb)
    vertices[9] = 1.0;
    vertices[10] = 0.0;
    vertices[11] = 0.0;

    vertices[12] = 0.0;
    vertices[13] = 1.0;
    vertices[14] = 0.0;

    vertices[15] = 0.0;
    vertices[16] = 0.0;
    vertices[17] = 1.0;

    // 7. Upload to vertex buffer using a command buffer and copy pass
    var cmd_buffer = try device.acquireCommandBuffer();
    var copy_pass = try cmd_buffer.beginCopyPass();

    const transfer_location = gpu.TransferBufferLocation{
        .transfer_buffer = upload_buffer,
        .offset = 0,
    };

    const buffer_region = gpu.BufferRegion{
        .buffer = vertex_buffer,
        .offset = 0,
        .size = 18 * @sizeOf(f32),
    };

    copy_pass.uploadToBuffer(&transfer_location, &buffer_region, false);
    copy_pass.end();

    try cmd_buffer.submit();
    try device.waitForIdle();
}

// Test texture operations
test "gpu texture operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // 1. Create a 2D texture
    const texture_2d_info = gpu.TextureCreateInfo{
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

    const texture_2d = try device.createTexture(texture_2d_info);
    defer device.releaseTexture(texture_2d);
    device.setTextureName(texture_2d, "2D Texture");

    // 2. Create a 2D array texture
    const texture_2d_array_info = gpu.TextureCreateInfo{
        .type = .@"2d_array",
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
        },
        .width = 128,
        .height = 128,
        .layer_count_or_depth = 4, // 4 layers
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const texture_2d_array = try device.createTexture(texture_2d_array_info);
    defer device.releaseTexture(texture_2d_array);
    device.setTextureName(texture_2d_array, "2D Array Texture");

    // 3. Create a 3D texture
    const texture_3d_info = gpu.TextureCreateInfo{
        .type = .@"3d",
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
        },
        .width = 64,
        .height = 64,
        .layer_count_or_depth = 64, // depth
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const texture_3d = try device.createTexture(texture_3d_info);
    defer device.releaseTexture(texture_3d);
    device.setTextureName(texture_3d, "3D Texture");

    // 4. Create a cube texture
    const texture_cube_info = gpu.TextureCreateInfo{
        .type = .cube,
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
        },
        .width = 256,
        .height = 256,
        .layer_count_or_depth = 6, // 6 faces
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const texture_cube = try device.createTexture(texture_cube_info);
    defer device.releaseTexture(texture_cube);
    device.setTextureName(texture_cube, "Cube Texture");

    // 5. Create a depth-stencil texture
    const depth_texture_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .d24_unorm_s8_uint,
        .usage = .{
            .depth_stencil_target = true,
        },
        .width = 800,
        .height = 600,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const depth_texture = try device.createTexture(depth_texture_info);
    defer device.releaseTexture(depth_texture);
    device.setTextureName(depth_texture, "Depth-Stencil Texture");

    // 6. Create a storage texture for compute
    const storage_texture_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r32g32b32a32_float,
        .usage = .{
            .compute_storage_read = true,
            .compute_storage_write = true,
        },
        .width = 256,
        .height = 256,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const storage_texture = try device.createTexture(storage_texture_info);
    defer device.releaseTexture(storage_texture);
    device.setTextureName(storage_texture, "Storage Texture");

    // 7. Create a texture with mipmaps
    const mipmap_texture_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
            .color_target = true,
        },
        .width = 512,
        .height = 512,
        .layer_count_or_depth = 1,
        .num_levels = 10, // Full mipmap chain
        .sample_count = .@"1",
    };

    const mipmap_texture = try device.createTexture(mipmap_texture_info);
    defer device.releaseTexture(mipmap_texture);
    device.setTextureName(mipmap_texture, "Mipmapped Texture");

    // 8. Test texture format utilities
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

// Test sampler operations
test "gpu sampler operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // 1. Create a basic linear sampler
    const linear_sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .repeat,
        .address_mode_v = .repeat,
        .address_mode_w = .repeat,
    };

    const linear_sampler = try device.createSampler(linear_sampler_info);
    defer device.releaseSampler(linear_sampler);

    // 2. Create a nearest sampler
    const nearest_sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .nearest,
        .mag_filter = .nearest,
        .mipmap_mode = .nearest,
        .address_mode_u = .repeat,
        .address_mode_v = .repeat,
        .address_mode_w = .repeat,
    };

    const nearest_sampler = try device.createSampler(nearest_sampler_info);
    defer device.releaseSampler(nearest_sampler);

    // 3. Create a clamping sampler
    const clamp_sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
    };

    const clamp_sampler = try device.createSampler(clamp_sampler_info);
    defer device.releaseSampler(clamp_sampler);

    // 4. Create a mirrored repeat sampler
    const mirror_sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .mirrored_repeat,
        .address_mode_v = .mirrored_repeat,
        .address_mode_w = .mirrored_repeat,
    };

    const mirror_sampler = try device.createSampler(mirror_sampler_info);
    defer device.releaseSampler(mirror_sampler);

    // 5. Create an anisotropic sampler
    const aniso_sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .repeat,
        .address_mode_v = .repeat,
        .address_mode_w = .repeat,
        .max_anisotropy = 16.0,
        .enable_anisotropy = true,
    };

    const aniso_sampler = try device.createSampler(aniso_sampler_info);
    defer device.releaseSampler(aniso_sampler);

    // 6. Create a sampler with explicit LOD control
    const lod_sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .repeat,
        .address_mode_v = .repeat,
        .address_mode_w = .repeat,
        .min_lod = 2.0,
        .max_lod = 8.0,
        .mip_lod_bias = 1.0,
    };

    const lod_sampler = try device.createSampler(lod_sampler_info);
    defer device.releaseSampler(lod_sampler);

    // 7. Create a sampler with comparison function
    const compare_sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .compare_op = .less,
        .enable_compare = true,
    };

    const compare_sampler = try device.createSampler(compare_sampler_info);
    defer device.releaseSampler(compare_sampler);
}

// Test shader and pipeline operations
test "gpu shader and pipeline operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // Skip shader creation if SPIRV is not supported
    if (!deviceSupportsSPIRV(&device)) {
        std.debug.print("Skipping shader tests as the device doesn't support SPIRV\n", .{});
        return;
    }

    // 1. Create vertex shader
    const vertex_shader_info = gpu.ShaderCreateInfo{
        .code = vertex_shader_code,
        .entrypoint = "VSMain",
        .format = .{
            .spirv = true,
        },
        .stage = .vertex,
        .num_samplers = 0,
        .num_uniform_buffers = 1,
    };

    const vertex_shader = try device.createShader(vertex_shader_info);
    defer device.releaseShader(vertex_shader);

    // 2. Create fragment shader
    const fragment_shader_info = gpu.ShaderCreateInfo{
        .code = fragment_shader_code,
        .entrypoint = "PSMain",
        .format = .{
            .spirv = true,
        },
        .stage = .fragment,
        .num_samplers = 1,
        .num_uniform_buffers = 1,
    };

    const fragment_shader = try device.createShader(fragment_shader_info);
    defer device.releaseShader(fragment_shader);

    // 3. Define vertex input state
    const vertex_buffer_desc = [_]gpu.VertexBufferDescription{
        .{
            .slot = 0,
            .pitch = 6 * @sizeOf(f32), // 3 position + 3 color
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
            .format = .float3,
            .offset = 3 * @sizeOf(f32),
        },
    };

    const vertex_input_state = gpu.VertexInputState{
        .vertex_buffer_descriptions = &vertex_buffer_desc,
        .vertex_attributes = &vertex_attrs,
    };

    // 4. Create a graphics pipeline
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

    const graphics_pipeline_info = gpu.GraphicsPipelineCreateInfo{
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

    const graphics_pipeline = try device.createGraphicsPipeline(graphics_pipeline_info);
    defer device.releaseGraphicsPipeline(graphics_pipeline);

    // 5. Create a compute pipeline
    // Note: We don't have a compute shader provided, so we'll comment this out

    // c const compute_pipeline_info = gpu.ComputePipelineCreateInfo{
    //      .code = compute_shader_code, // Would need a separate compute shader
    //      .entrypoint = "main",
    //      .format = .{
    //          .spirv = true,
    //      },
    //      .num_samplers = 1,
    //      .num_readonly_storage_textures = 1,
    //      .num_readonly_storage_buffers = 1,
    //      .num_readwrite_storage_textures = 1,
    //      .num_readwrite_storage_buffers = 1,
    //      .num_uniform_buffers = 1,
    //      .threadcount_x = 8,
    //      .threadcount_y = 8,
    //      .threadcount_z = 1,
    //      .props = 0,
    //  };

    // Commented out since we don't have real shader code
    // const compute_pipeline = try device.createComputePipeline(compute_pipeline_info);
    // defer device.releaseComputePipeline(compute_pipeline);
}

// Test render pass operations
test "gpu render pass operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // Create a window for testing
    var window = try video.Window.create(
        "GPU Render Pass Test",
        800,
        600,
        .{},
    );
    defer window.destroy();

    try device.claimWindow(window);
    defer device.releaseWindow(window);
    try device.setSwapchainParameters(window, .sdr, .vsync);

    // Skip the rest if SPIRV is not supported
    if (!deviceSupportsSPIRV(&device)) {
        std.debug.print("Skipping render pass test as the device doesn't support SPIRV\n", .{});
        return;
    }

    // 1. Create a render target texture
    const render_target_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
            .color_target = true,
        },
        .width = 512,
        .height = 512,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const render_target = try device.createTexture(render_target_info);
    defer device.releaseTexture(render_target);
    device.setTextureName(render_target, "Render Target");

    // 2. Create a depth target
    const depth_target_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .d24_unorm_s8_uint,
        .usage = .{
            .depth_stencil_target = true,
        },
        .width = 512,
        .height = 512,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };

    const depth_target = try device.createTexture(depth_target_info);
    defer device.releaseTexture(depth_target);
    device.setTextureName(depth_target, "Depth Target");

    // 3. Create a vertex buffer
    const vertex_buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .vertex = true,
        },
        .size = 1024,
    };
    const vertex_buffer = try device.createBuffer(vertex_buffer_info);
    defer device.releaseBuffer(vertex_buffer);

    // 4. Create shaders and pipeline (simplified - assuming shaders would work)
    // At this point we'd normally create shaders and pipeline but we'll skip that
    // for brevity since we don't have real shader code

    // 5. Acquire command buffer
    var cmd_buffer = try device.acquireCommandBuffer();

    // 6. Acquire swapchain texture to render to
    var width: u32 = undefined;
    var height: u32 = undefined;
    const swapchain_texture = try cmd_buffer.acquireSwapchainTexture(&window, &width, &height);

    // 7. Setup color and depth target info for render pass
    const color_target_info = [_]gpu.ColorTargetInfo{
        .{
            .texture = swapchain_texture,
            .clear_color = .{ .r = 0.1, .g = 0.2, .b = 0.3, .a = 1.0 },
            .load_op = .clear,
            .store_op = .store,
        },
    };

    const depth_stencil_info = gpu.DepthStencilTargetInfo{
        .texture = depth_target,
        .clear_depth = 1.0,
        .clear_stencil = 0,
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .clear,
        .stencil_store_op = .dont_care,
    };

    // 8. Begin render pass
    var render_pass = try cmd_buffer.beginRenderPass(&color_target_info, &depth_stencil_info);

    // 9. Setup viewport and scissor
    const viewport = gpu.Viewport{
        .x = 0.0,
        .y = 0.0,
        .w = @floatFromInt(width),
        .h = @floatFromInt(height),
        .min_depth = 0.0,
        .max_depth = 1.0,
    };
    render_pass.setViewport(viewport);

    const scissor = rect.Rect{
        .x = 0,
        .y = 0,
        .w = @intCast(width),
        .h = @intCast(height),
    };
    render_pass.setScissor(scissor);

    // 10. Set blend constants and stencil reference
    render_pass.setBlendConstants(.{ .r = 1.0, .g = 1.0, .b = 1.0, .a = 1.0 });
    render_pass.setStencilReference(0);

    // 11. Bind pipeline and resources
    // Skipped since we don't have real pipeline

    // 12. Bind vertex buffer
    const buffer_binding = [_]gpu.BufferBinding{
        .{
            .buffer = vertex_buffer,
            .offset = 0,
        },
    };
    render_pass.bindVertexBuffers(0, &buffer_binding);

    // 13. Draw primitives
    // Commented since we don't have a real pipeline bound
    // render_pass.drawPrimitives(3, 1, 0, 0);

    // 14. End render pass
    render_pass.end();

    // 15. Submit command buffer
    try cmd_buffer.submit();

    // 16. Wait for GPU to finish
    try device.waitForIdle();
}

// Test copy pass operations
test "gpu copy pass operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // 1. Create source and destination buffers
    const buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .vertex = true,
        },
        .size = 1024,
    };
    const source_buffer = try device.createBuffer(buffer_info);
    defer device.releaseBuffer(source_buffer);
    device.setBufferName(source_buffer, "Source Buffer");

    const dest_buffer = try device.createBuffer(buffer_info);
    defer device.releaseBuffer(dest_buffer);
    device.setBufferName(dest_buffer, "Destination Buffer");

    // 2. Create transfer buffers
    const upload_buffer_info = gpu.TransferBufferCreateInfo{
        .usage = .upload,
        .size = 1024,
    };
    const upload_buffer = try device.createTransferBuffer(upload_buffer_info);
    defer device.releaseTransferBuffer(upload_buffer);

    const download_buffer_info = gpu.TransferBufferCreateInfo{
        .usage = .download,
        .size = 1024,
    };
    const download_buffer = try device.createTransferBuffer(download_buffer_info);
    defer device.releaseTransferBuffer(download_buffer);

    // 3. Create textures
    const texture_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
            .color_target = true,
        },
        .width = 64,
        .height = 64,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };
    const source_texture = try device.createTexture(texture_info);
    defer device.releaseTexture(source_texture);
    device.setTextureName(source_texture, "Source Texture");

    const dest_texture = try device.createTexture(texture_info);
    defer device.releaseTexture(dest_texture);
    device.setTextureName(dest_texture, "Destination Texture");

    // 4. Map and write to upload buffer
    const upload_ptr = try device.mapTransferBuffer(upload_buffer, false);
    defer device.unmapTransferBuffer(upload_buffer);

    // Write some data (RGBA pixels)
    const pixels_data = @as([*]u8, @ptrCast(upload_ptr))[0 .. 64 * 64 * 4];
    for (0..64 * 64) |i| {
        pixels_data[i * 4 + 0] = 255; // R
        pixels_data[i * 4 + 1] = 0; // G
        pixels_data[i * 4 + 2] = 0; // B
        pixels_data[i * 4 + 3] = 255; // A
    }

    // 5. Acquire command buffer and begin copy pass
    var cmd_buffer = try device.acquireCommandBuffer();
    var copy_pass = try cmd_buffer.beginCopyPass();

    // 6. Upload buffer data
    const buffer_transfer_location = gpu.TransferBufferLocation{
        .transfer_buffer = upload_buffer,
        .offset = 0,
    };

    const buffer_region = gpu.BufferRegion{
        .buffer = source_buffer,
        .offset = 0,
        .size = 1024,
    };

    copy_pass.uploadToBuffer(&buffer_transfer_location, &buffer_region, false);

    // 7. Upload texture data
    const texture_transfer_info = gpu.TextureTransferInfo{
        .transfer_buffer = upload_buffer,
        .offset = 0,
        .pixels_per_row = 64 * 4, // 64 pixels * 4 bytes per pixel
        .rows_per_layer = 64 * 64 * 4, // row_pitch * height
    };

    const texture_region = gpu.TextureRegion{
        .texture = source_texture,
        .mip_level = 0,
        .layer = 0,
        .x = 0,
        .y = 0,
        .z = 0,
        .w = 64,
        .h = 64,
        .d = 1,
    };

    copy_pass.uploadToTexture(&texture_transfer_info, &texture_region, false);

    // 8. Copy buffer to buffer
    const source_buffer_location = gpu.BufferLocation{
        .buffer = source_buffer,
        .offset = 0,
    };

    const dest_buffer_location = gpu.BufferLocation{
        .buffer = dest_buffer,
        .offset = 0,
    };

    copy_pass.copyBufferToBuffer(&source_buffer_location, &dest_buffer_location, 1024, false);

    // 9. Copy texture to texture
    const source_texture_location = gpu.TextureLocation{
        .texture = source_texture,
        .mip_level = 0,
        .layer = 0,
        .x = 0,
        .y = 0,
        .z = 0,
    };

    const dest_texture_location = gpu.TextureLocation{
        .texture = dest_texture,
        .mip_level = 0,
        .x = 0,
        .y = 0,
        .z = 0,
    };

    copy_pass.copyTextureToTexture(&source_texture_location, &dest_texture_location, 64, 64, 1, false);

    // 10. Download buffer data
    const download_buffer_location = gpu.TransferBufferLocation{
        .transfer_buffer = download_buffer,
        .offset = 0,
    };

    const download_buffer_region = gpu.BufferRegion{
        .buffer = dest_buffer,
        .offset = 0,
        .size = 1024,
    };

    copy_pass.downloadFromBuffer(&download_buffer_region, &download_buffer_location);

    // 11. Download texture data
    const download_texture_region = gpu.TextureRegion{
        .texture = dest_texture,
        .mip_level = 0,
        .x = 0,
        .y = 0,
        .z = 0,
        .w = 64,
        .h = 64,
        .d = 1,
    };

    const download_texture_transfer_info = gpu.TextureTransferInfo{
        .transfer_buffer = download_buffer,
        .offset = 512, // Use a different offset than the buffer download
        .pixels_per_row = 64 * 4,
        .rows_per_layer = 64 * 64 * 4,
    };

    copy_pass.downloadFromTexture(&download_texture_region, &download_texture_transfer_info);

    // 12. End copy pass and submit
    copy_pass.end();
    try cmd_buffer.submit();

    // 13. Wait for GPU to finish
    try device.waitForIdle();

    // 14. Generate mipmaps
    cmd_buffer = try device.acquireCommandBuffer();
    cmd_buffer.generateMipmapsForTexture(dest_texture);
    try cmd_buffer.submit();
    try device.waitForIdle();
}

// Test compute pass operations
test "gpu compute pass operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // Skip the rest if SPIRV is not supported
    if (!deviceSupportsSPIRV(&device)) {
        std.debug.print("Skipping compute pass test as the device doesn't support SPIRV\n", .{});
        return;
    }

    // 1. Create storage buffer for compute
    const storage_buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .storage_compute_read = true,
            .storage_compute_write = true,
        },
        .size = 1024,
    };
    const storage_buffer = try device.createBuffer(storage_buffer_info);
    defer device.releaseBuffer(storage_buffer);
    device.setBufferName(storage_buffer, "Compute Storage Buffer");

    // 2. Create read-only storage buffer
    const readonly_buffer_info = gpu.BufferCreateInfo{
        .usage = .{
            .storage_compute_read = true,
        },
        .size = 1024,
    };
    const readonly_buffer = try device.createBuffer(readonly_buffer_info);
    defer device.releaseBuffer(readonly_buffer);
    device.setBufferName(readonly_buffer, "Read-Only Storage Buffer");

    // 3. Create storage texture
    const storage_texture_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r32g32b32a32_float,
        .usage = .{
            .compute_storage_read = true,
            .compute_storage_write = true,
        },
        .width = 32,
        .height = 32,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };
    const storage_texture = try device.createTexture(storage_texture_info);
    defer device.releaseTexture(storage_texture);
    device.setTextureName(storage_texture, "Compute Storage Texture");

    // 4. Create readonly storage texture
    const readonly_texture_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r32g32b32a32_float,
        .usage = .{
            .compute_storage_read = true,
        },
        .width = 32,
        .height = 32,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };
    const readonly_texture = try device.createTexture(readonly_texture_info);
    defer device.releaseTexture(readonly_texture);
    device.setTextureName(readonly_texture, "Read-Only Storage Texture");

    // 5. Create sampler for compute
    const sampler_info = gpu.SamplerCreateInfo{
        .min_filter = .linear,
        .mag_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
    };
    const sampler = try device.createSampler(sampler_info);
    defer device.releaseSampler(sampler);

    // 6. Create texture for sampling in compute
    const sample_texture_info = gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .usage = .{
            .sampler = true,
        },
        .width = 32,
        .height = 32,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    };
    const sample_texture = try device.createTexture(sample_texture_info);
    defer device.releaseTexture(sample_texture);
    device.setTextureName(sample_texture, "Compute Sample Texture");

    // 7. Create compute pipeline
    // Note: We don't have a compute shader provided, so we'll skip this part

    // const compute_pipeline_info = gpu.ComputePipelineCreateInfo{
    //     .code = compute_shader_code, // Would need a separate compute shader
    //     .entrypoint = "main",
    //     .format = .{
    //         .spirv = true,
    //     },
    //     .num_samplers = 1,
    //     .num_readonly_storage_textures = 1,
    //     .num_readonly_storage_buffers = 1,
    //     .num_readwrite_storage_textures = 1,
    //     .num_readwrite_storage_buffers = 1,
    //     .num_uniform_buffers = 0,
    //     .threadcount_x = 8,
    //     .threadcount_y = 8,
    //     .threadcount_z = 1,
    //     .props = 0,
    // };

    // Commented out since we don't have real shader code
    // const compute_pipeline = try device.createComputePipeline(compute_pipeline_info);
    // defer device.releaseComputePipeline(compute_pipeline);

    // 8. Prepare storage bindings
    const rw_storage_texture_binding = [_]gpu.StorageTextureReadWriteBinding{
        .{
            .texture = storage_texture,
        },
    };

    const rw_storage_buffer_binding = [_]gpu.StorageBufferReadWriteBinding{
        .{
            .buffer = storage_buffer,
        },
    };

    // 9. Acquire command buffer and begin compute pass
    var cmd_buffer = try device.acquireCommandBuffer();
    var compute_pass = try cmd_buffer.beginComputePass(&rw_storage_texture_binding, &rw_storage_buffer_binding);

    // 10. Bind compute pipeline
    // compute_pass.bindComputePipeline(compute_pipeline);

    // 11. Bind samplers
    const texture_sampler_binding = [_]gpu.TextureSamplerBinding{
        .{
            .texture = sample_texture,
            .sampler = sampler,
        },
    };
    compute_pass.bindComputeSamplers(0, &texture_sampler_binding);

    // 12. Bind readonly storage textures
    const readonly_storage_textures = [_]*gpu.Texture{
        readonly_texture,
    };
    compute_pass.bindComputeStorageTextures(0, &readonly_storage_textures);

    // 13. Bind readonly storage buffers
    const readonly_storage_buffers = [_]*gpu.Buffer{
        readonly_buffer,
    };
    compute_pass.bindComputeStorageBuffers(0, &readonly_storage_buffers);

    // 14. Dispatch compute work
    // compute_pass.dispatchCompute(4, 4, 1);

    // 15. End compute pass
    compute_pass.end();

    // 16. Submit command buffer
    try cmd_buffer.submit();

    // 17. Wait for GPU to finish
    try device.waitForIdle();
}

// Test fence operations
test "gpu fence operations" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    var device = try gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    // 1. Create and submit a command buffer, acquiring a fence
    var cmd_buffer = try device.acquireCommandBuffer();
    const fence = try cmd_buffer.submitAndAcquireFence();
    defer device.releaseFence(fence);

    // 2. Query the fence status
    const is_signaled = device.queryFence(fence);
    std.debug.print("Fence signaled immediately: {}\n", .{is_signaled});

    // 3. Wait for the fence to be signaled
    try device.waitForFences(true, &[_]*gpu.Fence{fence});

    // 4. Check the fence status again after waiting
    const is_signaled_after_wait = device.queryFence(fence);
    std.debug.print("Fence signaled after wait: {}\n", .{is_signaled_after_wait});

    // 5. Test multiple fences (if the first one is already signaled, create another)
    var cmd_buffer2 = try device.acquireCommandBuffer();
    const fence2 = try cmd_buffer2.submitAndAcquireFence();
    defer device.releaseFence(fence2);

    // 6. Wait for multiple fences
    try device.waitForFences(true, &[_]*gpu.Fence{ fence, fence2 });

    // 7. Alternative: wait for any fence (wait_all = false)
    var cmd_buffer3 = try device.acquireCommandBuffer();
    const fence3 = try cmd_buffer3.submitAndAcquireFence();
    defer device.releaseFence(fence3);

    try device.waitForFences(false, &[_]*gpu.Fence{fence3});

    // 8. Test device idle waiting
    try device.waitForIdle();
}
