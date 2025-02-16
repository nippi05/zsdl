const zsdl = @import("zsdl");
const std = @import("std");

test "graphics pipeline" {
    try zsdl.init(.{ .video = true });
    defer zsdl.quit();

    const window = try zsdl.video.Window.create("lol", 300, 300, .{ .resizable = true });
    defer window.destroy();

    const device = try zsdl.gpu.Device.create(.{ .spirv = true }, true, null);
    defer device.destroy();

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
