const zsdl = @import("zsdl");
const std = @import("std");

test "graphics pipeline" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try zsdl.video.Window.create("lol", 300, 300, .{ .resizable = true });
    defer window.destroy();

    const device = try zsdl.gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

    const lol = try device.acquireCommandBuffer();
    try lol.cancel();

    const Vertex = extern struct {
        pos: [3]f32,
        tex_coords: [2]f32,
        color: [3]f32,
    };

    const vertices = [_]Vertex{
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 1.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 1.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 0.0 } },
        .{ .pos = .{ -0.5, 0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 1.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 1.0, 0.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 1.0 } },
        .{ .pos = .{ -0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 1.0, 0.0 } },
        .{ .pos = .{ 0.5, -0.5, -0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 0.0, 0.0, 1.0 } },
        .{ .pos = .{ 0.5, -0.5, 0.5 }, .tex_coords = .{ 0, 0 }, .color = .{ 1.0, 0.0, 1.0 } },
    };
    const texture = try device.createTexture(.{
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .width = 256,
        .height = 256,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .sampler = true },
        .props = 0,
    });
    defer device.releaseTexture(texture);
    const sampler = try device.createSampler(.{
        .min_filter = .nearest,
        .mag_filter = .nearest,
        .mipmap_mode = .nearest,
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .mip_lod_bias = 0,
        .max_anisotropy = 1,
        .min_lod = 0,
        .max_lod = 0,
        .compare_op = .equal,
        .enable_anisotropy = true,
        .enable_compare = false,
    });
    defer device.releaseSampler(sampler);

    const vertices_size = @sizeOf(@TypeOf(vertices));
    const vertex_buffer = try device.createBuffer(.{
        .usage = .{ .vertex = true },
        .size = vertices_size,
    });
    const vertex_transfer_buffer = try device.createTransferBuffer(.{
        .usage = .upload,
        .size = vertices_size,
    });
    const transfer_data_ptr = try device.mapTransferBuffer(
        vertex_transfer_buffer,
        false,
    );
    _ = zsdl.c.SDL_memcpy(transfer_data_ptr, @ptrCast(&vertices), vertices_size);
    device.unmapTransferBuffer(vertex_transfer_buffer);

    const cmdbuf = try device.acquireCommandBuffer();
    const copy_pass = try cmdbuf.beginCopyPass();
    copy_pass.uploadToBuffer(
        &.{
            .transfer_buffer = vertex_transfer_buffer,
            .offset = 0,
        },
        &.{
            .buffer = vertex_buffer,
            .offset = 0,
            .size = vertices_size,
        },
        false,
    );
    copy_pass.end();
    errdefer {
        cmdbuf.cancel() catch {};
    }
    const swaptex = try cmdbuf.waitAndAcquireSwapchainTexture(
        window,
        null,
        null,
    );
    const color_target_info = [_]zsdl.gpu.ColorTargetInfo{.{
        .texture = swaptex,
        .mip_level = 0,
        .layer_or_depth_plane = 0,
        .clear_color = .{
            .r = @as(f32, 0x18) / @as(f32, 0xFF),
            .g = @as(f32, 0x18) / @as(f32, 0xFF),
            .b = @as(f32, 0x18) / @as(f32, 0xFF),
            .a = 1,
        },
        .load_op = .clear,
        .store_op = .store,
        .resolve_texture = undefined, // You'll need to provide a valid texture or null if not using resolve
        .resolve_mip_level = 0,
        .resolve_layer = 0,
        .cycle = false,
        .cycle_resolve_texture = false,
        .padding1 = 0,
        .padding2 = 0,
    }};

    const depth_stencil_info = zsdl.gpu.DepthStencilTargetInfo{
        .texture = undefined, // You'll need to provide a valid depth/stencil texture
        .clear_depth = 1.0,
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .clear,
        .stencil_store_op = .store,
        .cycle = false,
        .clear_stencil = 0,
        .padding1 = 0,
        .padding2 = 0,
    };

    const render_pass = try cmdbuf.beginRenderPass(&color_target_info, depth_stencil_info);
    render_pass.end();
    try cmdbuf.submit();

    const shader1 = try device.createShader(.{
        .code = "lol",
        .entry_point = "main",
        .format = .spirv,
        .stage = .vertex,
        .num_samplers = 1,
        .num_storage_textures = 1,
        .num_storage_buffers = 0,
        .num_uniform_buffers = 0,
    });

    const pipeline = try device.createGraphicsPipeline(.{
        .multisample_state = .{
            .sample_count = .@"4",
            .sample_mask = 0,
            .enable_mask = false,
        },
        .depth_stencil_state = .{
            .compare_op = .less,
            .back_stencil_state = .{
                .fail_op = .keep,
                .pass_op = .invalid,
                .depth_fail_op = .invalid,
                .compare_op = .invalid,
            },
            .front_stencil_state = .{
                .fail_op = .invalid,
                .pass_op = .invalid,
                .depth_fail_op = .invalid,
                .compare_op = .invalid,
            },
            .compare_mask = 0,
            .write_mask = 0,
            .enable_depth_test = true,
            .enable_depth_write = true,
            .enable_stencil_test = true,
        },
        .target_info = .{
            .depth_stencil_format = .r8g8b8a8_unorm,
            .has_depth_stencil_target = true,
            .color_target_descriptions = &[_]zsdl.gpu.ColorTargetDescription{.{
                .format = .r8g8b8a8_unorm,
                .blend_state = .{
                    .src_color_blendfactor = .zero,
                    .dst_color_blendfactor = .zero,
                    .color_blend_op = .add,
                    .src_alpha_blendfactor = .zero,
                    .dst_alpha_blendfactor = .zero,
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
            }},
        },
        .rasterizer_state = .{
            .cull_mode = .front,
            .fill_mode = .fill,
            .front_face = .counter_clockwise,
            .depth_bias_constant_factor = 0,
            .depth_bias_clamp = 0,
            .depth_bias_slope_factor = 0,
            .enable_depth_bias = true,
            .enable_depth_clip = true,
        },
        .vertex_input_state = .{
            .vertex_buffer_descriptions = &[_]zsdl.gpu.VertexBufferDescription{
                .{
                    .slot = 0,
                    .input_rate = .vertex,
                    .instance_step_rate = 0,
                    .pitch = @sizeOf(@TypeOf(u32)),
                },
            },
            .vertex_attributes = &[_]zsdl.gpu.VertexAttribute{
                .{ // Position
                    .buffer_slot = 0,
                    .format = .float3,
                    .location = 0,
                    .offset = 0,
                },
            },
        },
        .primitive_type = .triangle_list,
        .vertex_shader = shader1,
        .fragment_shader = shader1,
    });
    defer device.releaseGraphicsPipeline(pipeline);
}
