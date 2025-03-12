const std = @import("std");

const @"error" = @import("error.zig");
const c = @import("c.zig").c;
pub const Fence = c.SDL_GPUFence;
pub const Buffer = c.SDL_GPUBuffer;
pub const Texture = c.SDL_GPUTexture;
pub const TransferBuffer = c.SDL_GPUTransferBuffer;
pub const Sampler = c.SDL_GPUSampler;
pub const Shader = c.SDL_GPUShader;
pub const ComputePipeline = c.SDL_GPUComputePipeline;
pub const GraphicsPipeline = c.SDL_GPUGraphicsPipeline;
pub const Viewport = c.SDL_GPUViewport;
pub const BufferBinding = c.SDL_GPUBufferBinding;
pub const BufferLocation = c.SDL_GPUBufferLocation;
pub const BufferRegion = c.SDL_GPUBufferRegion;
pub const TextureSamplerBinding = c.SDL_GPUTextureSamplerBinding;
pub const TextureLocation = c.SDL_GPUTextureLocation;
pub const TextureRegion = c.SDL_GPUTextureRegion;
pub const TextureTransferInfo = c.SDL_GPUTextureTransferInfo;
pub const TransferBufferLocation = c.SDL_GPUTransferBufferLocation;
pub const StorageTextureReadWriteBinding = c.SDL_GPUStorageTextureReadWriteBinding;
pub const StorageBufferReadWriteBinding = c.SDL_GPUStorageBufferReadWriteBinding;
pub const BlitRegion = c.SDL_GPUBlitRegion;
const FColor = @import("pixels.zig").FColor;
const FlipMode = @import("surface.zig").FlipMode;
const internal = @import("internal.zig");
const errify = internal.errify;
const Rect = @import("rect.zig").Rect;
const Window = @import("video.zig").Window;
const Properties = @import("properties.zig").Properties;

pub const TransferBufferUsage = enum(u32) {
    upload = c.SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
    download = c.SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD,
};

pub const CommandBuffer = struct {
    ptr: *c.SDL_GPUCommandBuffer,

    /// Push data to a vertex uniform slot on the command buffer.
    pub inline fn pushVertexUniformData(self: *const CommandBuffer, slot_index: u32, data: *const anyopaque, length: u32) void {
        c.SDL_PushGPUVertexUniformData(self.ptr, slot_index, data, length);
    }

    /// Push data to a fragment uniform slot on the command buffer.
    pub inline fn pushFragmentUniformData(self: *const CommandBuffer, slot_index: u32, data: *const anyopaque, length: u32) void {
        c.SDL_PushGPUFragmentUniformData(self.ptr, slot_index, data, length);
    }

    /// Push data to a uniform slot on the command buffer.
    pub inline fn pushComputeUniformData(self: *const CommandBuffer, slot_index: u32, data: *const anyopaque, length: u32) void {
        c.SDL_PushGPUComputeUniformData(self.ptr, slot_index, data, length);
    }

    /// Insert an arbitrary string label into the command buffer callstream.
    pub inline fn insertDebugLabel(self: *const CommandBuffer, text: [:0]const u8) void {
        c.SDL_InsertGPUDebugLabel(self.ptr, text);
    }

    /// Begin a debug group with an arbitrary name.
    pub inline fn pushDebugGroup(self: *const CommandBuffer, name: [:0]const u8) void {
        c.SDL_PushGPUDebugGroup(self.ptr, name);
    }

    /// End the most-recently pushed debug group.
    pub inline fn popDebugGroup(self: *const CommandBuffer) void {
        c.SDL_PopGPUDebugGroup(self.ptr);
    }

    /// Submit command buffer for GPU processing.
    pub inline fn submit(self: *const CommandBuffer) !void {
        try errify(c.SDL_SubmitGPUCommandBuffer(self.ptr));
    }

    /// Submit command buffer and acquire a fence.
    pub inline fn submitAndAcquireFence(self: *const CommandBuffer) !*Fence {
        return try errify(c.SDL_SubmitGPUCommandBufferAndAcquireFence(self.ptr));
    }

    /// Cancel command buffer execution.
    pub inline fn cancel(self: *const CommandBuffer) !void {
        try errify(c.SDL_CancelGPUCommandBuffer(self.ptr));
    }

    /// Begin a render pass on a command buffer.
    pub inline fn beginRenderPass(
        self: *const CommandBuffer,
        color_target_infos: []const ColorTargetInfo,
        depth_stencil_target_info: ?*const DepthStencilTargetInfo,
    ) !RenderPass {
        return .{
            .ptr = try errify(c.SDL_BeginGPURenderPass(
                self.ptr,
                @ptrCast(color_target_infos.ptr),
                @intCast(color_target_infos.len),
                @ptrCast(depth_stencil_target_info),
            )),
        };
    }

    /// Begin a compute pass on a command buffer.
    pub inline fn beginComputePass(
        self: *const CommandBuffer,
        storage_texture_bindings: []const StorageTextureReadWriteBinding,
        storage_buffer_bindings: []const StorageBufferReadWriteBinding,
    ) !ComputePass {
        return .{
            .ptr = try errify(c.SDL_BeginGPUComputePass(
                self.ptr,
                @ptrCast(storage_texture_bindings.ptr),
                @intCast(storage_texture_bindings.len),
                @ptrCast(storage_buffer_bindings.ptr),
                @intCast(storage_buffer_bindings.len),
            )),
        };
    }

    /// Begin a copy pass on a command buffer.
    pub inline fn beginCopyPass(self: *const CommandBuffer) !CopyPass {
        return .{
            .ptr = try errify(c.SDL_BeginGPUCopyPass(self.ptr)),
        };
    }

    /// Generate mipmaps for the given texture.
    pub inline fn generateMipmapsForTexture(self: *const CommandBuffer, texture: *Texture) void {
        c.SDL_GenerateMipmapsForGPUTexture(self.ptr, texture);
    }

    /// Blit from a source texture region to a destination texture region.
    pub inline fn blitTexture(self: *const CommandBuffer, info: *const BlitInfo) void {
        c.SDL_BlitGPUTexture(self.ptr, info);
    }

    /// Acquire a texture to use in presentation.
    pub inline fn acquireSwapchainTexture(
        self: *const CommandBuffer,
        window: *const Window,
        swapchain_texture_width: ?*u32,
        swapchain_texture_height: ?*u32,
    ) !*Texture {
        var texture: *Texture = undefined;
        try errify(c.SDL_AcquireGPUSwapchainTexture(self.ptr, window.ptr, @ptrCast(&texture), swapchain_texture_width, swapchain_texture_height));
        return texture;
    }

    /// Wait and acquire a swapchain texture.
    pub inline fn waitAndAcquireSwapchainTexture(
        self: *const CommandBuffer,
        window: Window,
        swapchain_texture_width: ?*u32,
        swapchain_texture_height: ?*u32,
    ) !*Texture {
        var texture: *Texture = undefined;
        try errify(c.SDL_WaitAndAcquireGPUSwapchainTexture(self.ptr, window.ptr, @ptrCast(&texture), swapchain_texture_width, swapchain_texture_height));
        return texture;
    }
};

pub const RenderPass = struct {
    ptr: *c.SDL_GPURenderPass,

    /// Bind a graphics pipeline for use in rendering.
    pub inline fn bindGraphicsPipeline(self: *const RenderPass, graphics_pipeline: *GraphicsPipeline) void {
        c.SDL_BindGPUGraphicsPipeline(self.ptr, graphics_pipeline);
    }

    /// Set the current viewport state.
    pub inline fn setViewport(self: *const RenderPass, viewport: Viewport) void {
        c.SDL_SetGPUViewport(self.ptr, @ptrCast(&viewport));
    }

    /// Set the current scissor state.
    pub inline fn setScissor(self: *const RenderPass, scissor: Rect) void {
        c.SDL_SetGPUScissor(self.ptr, @ptrCast(&scissor));
    }

    /// Set the current blend constants.
    pub inline fn setBlendConstants(self: *const RenderPass, blend_constants: FColor) void {
        c.SDL_SetGPUBlendConstants(self.ptr, @bitCast(blend_constants));
    }

    /// Set the current stencil reference value.
    pub inline fn setStencilReference(self: *const RenderPass, reference: u8) void {
        c.SDL_SetGPUStencilReference(self.ptr, reference);
    }

    /// Bind vertex buffers for use with subsequent draw calls.
    pub inline fn bindVertexBuffers(self: *const RenderPass, first_slot: u32, bindings: []const BufferBinding) void {
        c.SDL_BindGPUVertexBuffers(self.ptr, first_slot, @ptrCast(bindings.ptr), @intCast(bindings.len));
    }

    /// Bind an index buffer for use with subsequent draw calls.
    pub inline fn bindIndexBuffer(self: *const RenderPass, binding: *const BufferBinding, index_element_size: IndexElementSize) void {
        c.SDL_BindGPUIndexBuffer(self.ptr, @ptrCast(binding), @intFromEnum(index_element_size));
    }

    /// Bind texture-sampler pairs for use on the vertex shader.
    pub inline fn bindVertexSamplers(self: *const RenderPass, first_slot: u32, texture_sampler_bindings: []const TextureSamplerBinding) void {
        c.SDL_BindGPUVertexSamplers(self.ptr, first_slot, @ptrCast(texture_sampler_bindings.ptr), @intCast(texture_sampler_bindings.len));
    }

    /// Bind storage textures for use on the vertex shader.
    pub inline fn bindVertexStorageTextures(self: *const RenderPass, first_slot: u32, storage_textures: []const *Texture) void {
        c.SDL_BindGPUVertexStorageTextures(self.ptr, first_slot, @ptrCast(storage_textures.ptr), @intCast(storage_textures.len));
    }

    /// Bind storage buffers for use on the vertex shader.
    pub inline fn bindVertexStorageBuffers(self: *const RenderPass, first_slot: u32, storage_buffers: []const *Buffer) void {
        c.SDL_BindGPUVertexStorageBuffers(self.ptr, first_slot, @ptrCast(storage_buffers.ptr), @intCast(storage_buffers.len));
    }

    /// Bind texture-sampler pairs for use on the fragment shader.
    pub inline fn bindFragmentSamplers(self: *const RenderPass, first_slot: u32, texture_sampler_bindings: []const TextureSamplerBinding) void {
        c.SDL_BindGPUFragmentSamplers(self.ptr, first_slot, @ptrCast(texture_sampler_bindings.ptr), @intCast(texture_sampler_bindings.len));
    }

    /// Bind storage textures for use on the fragment shader.
    pub inline fn bindFragmentStorageTextures(self: *const RenderPass, first_slot: u32, storage_textures: []const *Texture) void {
        c.SDL_BindGPUFragmentStorageTextures(self.ptr, first_slot, @ptrCast(storage_textures.ptr), @intCast(storage_textures.len));
    }

    /// Bind storage buffers for use on the fragment shader.
    pub inline fn bindFragmentStorageBuffers(self: *const RenderPass, first_slot: u32, storage_buffers: []const *Buffer) void {
        c.SDL_BindGPUFragmentStorageBuffers(self.ptr, first_slot, @ptrCast(storage_buffers.ptr), @intCast(storage_buffers.len));
    }

    /// Draw using bound graphics state with an index buffer and instancing enabled.
    pub inline fn drawIndexedPrimitives(self: *const RenderPass, num_indices: u32, num_instances: u32, first_index: u32, vertex_offset: i32, first_instance: u32) void {
        c.SDL_DrawGPUIndexedPrimitives(self.ptr, num_indices, num_instances, first_index, vertex_offset, first_instance);
    }

    /// Draw using bound graphics state.
    pub inline fn drawPrimitives(self: *const RenderPass, num_vertices: u32, num_instances: u32, first_vertex: u32, first_instance: u32) void {
        c.SDL_DrawGPUPrimitives(self.ptr, num_vertices, num_instances, first_vertex, first_instance);
    }

    /// Draw using bound graphics state and with draw parameters set from a buffer.
    pub inline fn drawPrimitivesIndirect(self: *const RenderPass, buffer: *Buffer, offset: u32, draw_count: u32) void {
        c.SDL_DrawGPUPrimitivesIndirect(self.ptr, buffer, offset, draw_count);
    }

    /// Draw using bound graphics state with an index buffer enabled and with draw parameters set from a buffer.
    pub inline fn drawIndexedPrimitivesIndirect(self: *const RenderPass, buffer: *Buffer, offset: u32, draw_count: u32) void {
        c.SDL_DrawGPUIndexedPrimitivesIndirect(self.ptr, buffer, offset, draw_count);
    }

    /// End the current render pass.
    pub inline fn end(self: *const RenderPass) void {
        c.SDL_EndGPURenderPass(self.ptr);
    }
};

pub const ComputePass = struct {
    ptr: *c.SDL_GPUComputePass,

    /// Bind a compute pipeline for use in dispatch.
    pub inline fn bindComputePipeline(self: *const ComputePass, compute_pipeline: *ComputePipeline) void {
        c.SDL_BindGPUComputePipeline(self.ptr, compute_pipeline);
    }

    /// Bind texture-sampler pairs for use on the compute shader.
    pub inline fn bindComputeSamplers(self: *const ComputePass, first_slot: u32, texture_sampler_bindings: []const TextureSamplerBinding) void {
        c.SDL_BindGPUComputeSamplers(self.ptr, first_slot, @ptrCast(texture_sampler_bindings.ptr), @intCast(texture_sampler_bindings.len));
    }

    /// Bind storage textures as readonly for use on the compute pipeline.
    pub inline fn bindComputeStorageTextures(self: *const ComputePass, first_slot: u32, storage_textures: []const *Texture) void {
        c.SDL_BindGPUComputeStorageTextures(self.ptr, first_slot, @ptrCast(storage_textures.ptr), @intCast(storage_textures.len));
    }

    /// Bind storage buffers as readonly for use on the compute pipeline.
    pub inline fn bindComputeStorageBuffers(self: *const ComputePass, first_slot: u32, storage_buffers: []const *Buffer) void {
        c.SDL_BindGPUComputeStorageBuffers(self.ptr, first_slot, @ptrCast(storage_buffers.ptr), @intCast(storage_buffers.len));
    }

    /// Dispatch compute work.
    pub inline fn dispatchCompute(self: *const ComputePass, groupcount_x: u32, groupcount_y: u32, groupcount_z: u32) void {
        c.SDL_DispatchGPUCompute(self.ptr, groupcount_x, groupcount_y, groupcount_z);
    }

    /// Dispatch compute work with parameters set from a buffer.
    pub inline fn dispatchComputeIndirect(self: *const ComputePass, buffer: *Buffer, offset: u32) void {
        c.SDL_DispatchGPUComputeIndirect(self.ptr, buffer, offset);
    }

    /// End the current compute pass.
    pub inline fn end(self: *const ComputePass) void {
        c.SDL_EndGPUComputePass(self.ptr);
    }
};

pub const CopyPass = struct {
    ptr: *c.SDL_GPUCopyPass,

    /// Upload data from a transfer buffer to a texture.
    pub inline fn uploadToTexture(self: *const CopyPass, source: *const TextureTransferInfo, destination: *const TextureRegion, cycle: bool) void {
        c.SDL_UploadToGPUTexture(self.ptr, @ptrCast(source), @ptrCast(destination), cycle);
    }

    /// Upload data from a transfer buffer to a buffer.
    pub inline fn uploadToBuffer(self: *const CopyPass, source: *const TransferBufferLocation, destination: *const BufferRegion, cycle: bool) void {
        c.SDL_UploadToGPUBuffer(self.ptr, @ptrCast(source), @ptrCast(destination), cycle);
    }

    /// Perform a texture-to-texture copy.
    pub inline fn copyTextureToTexture(self: *const CopyPass, source: *const TextureLocation, destination: *const TextureLocation, w: u32, h: u32, d: u32, cycle: bool) void {
        c.SDL_CopyGPUTextureToTexture(self.ptr, @ptrCast(source), @ptrCast(destination), w, h, d, cycle);
    }

    /// Perform a buffer-to-buffer copy.
    pub inline fn copyBufferToBuffer(self: *const CopyPass, source: *const BufferLocation, destination: *const BufferLocation, size: u32, cycle: bool) void {
        c.SDL_CopyGPUBufferToBuffer(self.ptr, @ptrCast(source), @ptrCast(destination), size, cycle);
    }

    /// Copy data from a texture to a transfer buffer on the GPU timeline.
    pub inline fn downloadFromTexture(self: *const CopyPass, source: *const TextureRegion, destination: *const TextureTransferInfo) void {
        c.SDL_DownloadFromGPUTexture(self.ptr, @ptrCast(source), @ptrCast(destination));
    }

    /// Copy data from a buffer to a transfer buffer on the GPU timeline.
    pub inline fn downloadFromBuffer(self: *const CopyPass, source: *const BufferRegion, destination: *const TransferBufferLocation) void {
        c.SDL_DownloadFromGPUBuffer(self.ptr, @ptrCast(source), @ptrCast(destination));
    }

    /// End the current copy pass.
    pub inline fn end(self: *const CopyPass) void {
        c.SDL_EndGPUCopyPass(self.ptr);
    }
};

pub const ColorTargetInfo = extern struct {
    texture: *allowzero Texture = std.mem.zeroes(*allowzero Texture),
    mip_level: u32 = std.mem.zeroes(u32),
    layer_or_depth_plane: u32 = std.mem.zeroes(u32),
    clear_color: FColor = std.mem.zeroes(FColor),
    load_op: LoadOp = std.mem.zeroes(LoadOp),
    store_op: StoreOp = std.mem.zeroes(StoreOp),
    resolve_texture: *allowzero Texture = std.mem.zeroes(*allowzero Texture),
    resolve_mip_level: u32 = std.mem.zeroes(u32),
    resolve_layer: u32 = std.mem.zeroes(u32),
    cycle: bool = std.mem.zeroes(bool),
    cycle_resolve_texture: bool = std.mem.zeroes(bool),
    _padding1: u8 = std.mem.zeroes(u8),
    _padding2: u8 = std.mem.zeroes(u8),
};

pub const DepthStencilTargetInfo = extern struct {
    texture: *allowzero Texture = std.mem.zeroes(*allowzero Texture),
    clear_depth: f32 = std.mem.zeroes(f32),
    load_op: LoadOp = std.mem.zeroes(LoadOp),
    store_op: StoreOp = std.mem.zeroes(StoreOp),
    stencil_load_op: LoadOp = std.mem.zeroes(LoadOp),
    stencil_store_op: StoreOp = std.mem.zeroes(StoreOp),
    cycle: bool = std.mem.zeroes(bool),
    clear_stencil: u8 = std.mem.zeroes(u8),
    _padding1: u8 = std.mem.zeroes(u8),
    _padding2: u8 = std.mem.zeroes(u8),
};

pub const BlitInfo = extern struct {
    source: BlitRegion = std.mem.zeroes(BlitRegion),
    destination: BlitRegion = std.mem.zeroes(BlitRegion),
    load_op: LoadOp = std.mem.zeroes(LoadOp),
    clear_color: FColor = std.mem.zeroes(FColor),
    flip_mode: FlipMode = std.mem.zeroes(FlipMode),
    filter: Filter = std.mem.zeroes(Filter),
    cycle: bool = std.mem.zeroes(bool),
    _padding1: u8 = std.mem.zeroes(u8),
    _padding2: u8 = std.mem.zeroes(u8),
    _padding3: u8 = std.mem.zeroes(u8),
};

pub const StencilOpState = extern struct {
    fail_op: StencilOp = std.mem.zeroes(StencilOp),
    pass_op: StencilOp = std.mem.zeroes(StencilOp),
    depth_fail_op: StencilOp = std.mem.zeroes(StencilOp),
    compare_op: CompareOp = std.mem.zeroes(CompareOp),
};

pub const ShaderStage = enum(u32) {
    vertex = c.SDL_GPU_SHADERSTAGE_VERTEX,
    fragment = c.SDL_GPU_SHADERSTAGE_FRAGMENT,
};

pub const DepthStencilState = extern struct {
    compare_op: CompareOp = std.mem.zeroes(CompareOp),
    back_stencil_state: StencilOpState = std.mem.zeroes(StencilOpState),
    front_stencil_state: StencilOpState = std.mem.zeroes(StencilOpState),
    compare_mask: u8 = std.mem.zeroes(u8),
    write_mask: u8 = std.mem.zeroes(u8),
    enable_depth_test: bool = std.mem.zeroes(bool),
    enable_depth_write: bool = std.mem.zeroes(bool),
    enable_stencil_test: bool = std.mem.zeroes(bool),
};

pub const ColorTargetBlendState = extern struct {
    src_color_blendfactor: BlendFactor = std.mem.zeroes(BlendFactor),
    dst_color_blendfactor: BlendFactor = std.mem.zeroes(BlendFactor),
    color_blend_op: BlendOp = std.mem.zeroes(BlendOp),
    src_alpha_blendfactor: BlendFactor = std.mem.zeroes(BlendFactor),
    dst_alpha_blendfactor: BlendFactor = std.mem.zeroes(BlendFactor),
    alpha_blend_op: BlendOp = std.mem.zeroes(BlendOp),
    color_write_mask: ColorComponentFlags = std.mem.zeroes(ColorComponentFlags),
    enable_blend: bool = std.mem.zeroes(bool),
    enable_color_write_mask: bool = std.mem.zeroes(bool),

    pub inline fn toNative(self: *const ColorTargetBlendState) c.SDL_GPUColorTargetBlendState {
        return .{
            .src_color_blendfactor = @intFromEnum(self.src_color_blendfactor),
            .dst_color_blendfactor = @intFromEnum(self.dst_color_blendfactor),
            .color_blend_op = @intFromEnum(self.color_blend_op),
            .src_alpha_blendfactor = @intFromEnum(self.src_alpha_blendfactor),
            .dst_alpha_blendfactor = @intFromEnum(self.dst_alpha_blendfactor),
            .alpha_blend_op = @intFromEnum(self.alpha_blend_op),
            .color_write_mask = self.color_write_mask.toInt(),
            .enable_blend = self.enable_blend,
            .enable_color_write_mask = self.enable_color_write_mask,
        };
    }
};

pub const ColorTargetDescription = extern struct {
    format: TextureFormat = std.mem.zeroes(TextureFormat),
    blend_state: ColorTargetBlendState = std.mem.zeroes(ColorTargetBlendState),
};

pub const MultisampleState = extern struct {
    sample_count: SampleCount = std.mem.zeroes(SampleCount),
    sample_mask: u32 = std.mem.zeroes(u32),
    enable_mask: bool = std.mem.zeroes(bool),
};

pub const RasterizerState = extern struct {
    fill_mode: FillMode = std.mem.zeroes(FillMode),
    cull_mode: CullMode = std.mem.zeroes(CullMode),
    front_face: FrontFace = std.mem.zeroes(FrontFace),
    depth_bias_constant_factor: f32 = std.mem.zeroes(f32),
    depth_bias_clamp: f32 = std.mem.zeroes(f32),
    depth_bias_slope_factor: f32 = std.mem.zeroes(f32),
    enable_depth_bias: bool = std.mem.zeroes(bool),
    enable_depth_clip: bool = std.mem.zeroes(bool),
};

pub const GraphicsPipelineTargetInfo = struct {
    color_target_descriptions: []const ColorTargetDescription = &.{},
    depth_stencil_format: TextureFormat = std.mem.zeroes(TextureFormat),
    has_depth_stencil_target: bool = std.mem.zeroes(bool),

    pub inline fn toNative(self: *const GraphicsPipelineTargetInfo) c.SDL_GPUGraphicsPipelineTargetInfo {
        return .{
            .color_target_descriptions = @ptrCast(self.color_target_descriptions.ptr),
            .num_color_targets = @intCast(self.color_target_descriptions.len),
            .depth_stencil_format = @intFromEnum(self.depth_stencil_format),
            .has_depth_stencil_target = self.has_depth_stencil_target,
        };
    }
};

pub const BlendOp = enum(u32) {
    invalid = c.SDL_GPU_BLENDOP_INVALID,
    add = c.SDL_GPU_BLENDOP_ADD,
    subtract = c.SDL_GPU_BLENDOP_SUBTRACT,
    reverse_subtract = c.SDL_GPU_BLENDOP_REVERSE_SUBTRACT,
    min = c.SDL_GPU_BLENDOP_MIN,
    max = c.SDL_GPU_BLENDOP_MAX,
};

pub const BlendFactor = enum(u32) {
    invalid = c.SDL_GPU_BLENDFACTOR_INVALID,
    zero = c.SDL_GPU_BLENDFACTOR_ZERO,
    one = c.SDL_GPU_BLENDFACTOR_ONE,
    src_color = c.SDL_GPU_BLENDFACTOR_SRC_COLOR,
    one_minus_src_color = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR,
    dst_color = c.SDL_GPU_BLENDFACTOR_DST_COLOR,
    one_minus_dst_color = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR,
    src_alpha = c.SDL_GPU_BLENDFACTOR_SRC_ALPHA,
    one_minus_src_alpha = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,
    dst_alpha = c.SDL_GPU_BLENDFACTOR_DST_ALPHA,
    one_minus_dst_alpha = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA,
    constant_color = c.SDL_GPU_BLENDFACTOR_CONSTANT_COLOR,
    one_minus_constant_color = c.SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR,
    src_alpha_saturate = c.SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE,
};

pub const VertexElementFormat = enum(u32) {
    invalid = c.SDL_GPU_VERTEXELEMENTFORMAT_INVALID,
    int = c.SDL_GPU_VERTEXELEMENTFORMAT_INT,
    int2 = c.SDL_GPU_VERTEXELEMENTFORMAT_INT2,
    int3 = c.SDL_GPU_VERTEXELEMENTFORMAT_INT3,
    int4 = c.SDL_GPU_VERTEXELEMENTFORMAT_INT4,
    uint = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT,
    uint2 = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT2,
    uint3 = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT3,
    uint4 = c.SDL_GPU_VERTEXELEMENTFORMAT_UINT4,
    float = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT,
    float2 = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2,
    float3 = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3,
    float4 = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4,
    byte2 = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE2,
    byte4 = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE4,
    ubyte2 = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2,
    ubyte4 = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4,
    byte2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM,
    byte4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM,
    ubyte2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM,
    ubyte4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM,
    short2 = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT2,
    short4 = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT4,
    ushort2 = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT2,
    ushort4 = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT4,
    short2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM,
    short4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM,
    ushort2_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM,
    ushort4_norm = c.SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM,
    half2 = c.SDL_GPU_VERTEXELEMENTFORMAT_HALF2,
    half4 = c.SDL_GPU_VERTEXELEMENTFORMAT_HALF4,
};

pub const ColorComponentFlags = extern struct {
    r: bool = std.mem.zeroes(bool),
    g: bool = std.mem.zeroes(bool),
    b: bool = std.mem.zeroes(bool),
    a: bool = std.mem.zeroes(bool),

    pub inline fn toInt(self: ColorComponentFlags) c.SDL_GPUColorComponentFlags {
        return (if (self.r) c.SDL_GPU_COLORCOMPONENT_R else 0) |
            (if (self.g) c.SDL_GPU_COLORCOMPONENT_G else 0) |
            (if (self.b) c.SDL_GPU_COLORCOMPONENT_B else 0) |
            (if (self.a) c.SDL_GPU_COLORCOMPONENT_A else 0);
    }

    pub inline fn fromInt(flags: c.SDL_GPUColorComponentFlags) ColorComponentFlags {
        return .{
            .r = (flags & c.SDL_GPU_COLORCOMPONENT_R) != 0,
            .g = (flags & c.SDL_GPU_COLORCOMPONENT_G) != 0,
            .b = (flags & c.SDL_GPU_COLORCOMPONENT_B) != 0,
            .a = (flags & c.SDL_GPU_COLORCOMPONENT_A) != 0,
        };
    }
};

pub const BufferUsageFlags = extern struct {
    vertex: bool = std.mem.zeroes(bool),
    index: bool = std.mem.zeroes(bool),
    indirect: bool = std.mem.zeroes(bool),
    storage_graphics_read: bool = std.mem.zeroes(bool),
    storage_compute_read: bool = std.mem.zeroes(bool),
    storage_compute_write: bool = std.mem.zeroes(bool),

    pub inline fn toInt(self: BufferUsageFlags) c.SDL_GPUBufferUsageFlags {
        return (if (self.vertex) c.SDL_GPU_BUFFERUSAGE_VERTEX else 0) |
            (if (self.index) c.SDL_GPU_BUFFERUSAGE_INDEX else 0) |
            (if (self.indirect) c.SDL_GPU_BUFFERUSAGE_INDIRECT else 0) |
            (if (self.storage_graphics_read) c.SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ else 0) |
            (if (self.storage_compute_read) c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ else 0) |
            (if (self.storage_compute_write) c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE else 0);
    }

    pub inline fn fromInt(flags: c.SDL_GPUBufferUsageFlags) BufferUsageFlags {
        return .{
            .vertex = (flags & c.SDL_GPU_BUFFERUSAGE_VERTEX) != 0,
            .index = (flags & c.SDL_GPU_BUFFERUSAGE_INDEX) != 0,
            .indirect = (flags & c.SDL_GPU_BUFFERUSAGE_INDIRECT) != 0,
            .storage_graphics_read = (flags & c.SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ) != 0,
            .storage_compute_read = (flags & c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ) != 0,
            .storage_compute_write = (flags & c.SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE) != 0,
        };
    }
};

pub const VertexBufferDescription = extern struct {
    slot: u32,
    pitch: u32,
    input_rate: VertexInputRate,
    instance_step_rate: u32,
};

pub const VertexAttribute = extern struct {
    location: u32,
    buffer_slot: u32,
    format: VertexElementFormat,
    offset: u32,
};

pub const VertexInputState = struct {
    vertex_buffer_descriptions: []const VertexBufferDescription,
    vertex_attributes: []const VertexAttribute,

    pub inline fn toNative(self: *const VertexInputState) c.SDL_GPUVertexInputState {
        return .{
            .vertex_buffer_descriptions = @ptrCast(self.vertex_buffer_descriptions.ptr),
            .num_vertex_buffers = @intCast(self.vertex_buffer_descriptions.len),
            .vertex_attributes = @ptrCast(self.vertex_attributes.ptr),
            .num_vertex_attributes = @intCast(self.vertex_attributes.len),
        };
    }
};

pub const ComputePipelineCreateInfo = struct {
    code: []const u8,
    entrypoint: []const u8,
    format: ShaderFormat,
    num_samplers: u32,
    num_readonly_storage_textures: u32,
    num_readonly_storage_buffers: u32,
    num_readwrite_storage_textures: u32,
    num_readwrite_storage_buffers: u32,
    num_uniform_buffers: u32,
    threadcount_x: u32,
    threadcount_y: u32,
    threadcount_z: u32,
    props: c.SDL_PropertiesID,

    pub inline fn toNative(self: *const ComputePipelineCreateInfo) c.SDL_GPUComputePipelineCreateInfo {
        return .{
            .code_size = @intCast(self.code.len),
            .code = self.code.ptr,
            .entrypoint = self.entrypoint,
            .format = self.format.toInt(),
            .num_samplers = self.num_samplers,
            .num_readonly_storage_textures = self.num_readonly_storage_textures,
            .num_readonly_storage_buffers = self.num_readonly_storage_buffers,
            .num_readwrite_storage_textures = self.num_readwrite_storage_textures,
            .num_readwrite_storage_buffers = self.num_readwrite_storage_buffers,
            .num_uniform_buffers = self.num_uniform_buffers,
            .threadcount_x = self.threadcount_x,
            .threadcount_y = self.threadcount_y,
            .threadcount_z = self.threadcount_z,
            .props = self.props,
        };
    }
};

pub const GraphicsPipelineCreateInfo = struct {
    vertex_shader: *allowzero Shader = std.mem.zeroes(*allowzero Shader),
    fragment_shader: *allowzero Shader = std.mem.zeroes(*allowzero Shader),
    vertex_input_state: VertexInputState = std.mem.zeroes(VertexInputState),
    primitive_type: PrimitiveType = std.mem.zeroes(PrimitiveType),
    rasterizer_state: RasterizerState = std.mem.zeroes(RasterizerState),
    multisample_state: MultisampleState = std.mem.zeroes(MultisampleState),
    depth_stencil_state: DepthStencilState = std.mem.zeroes(DepthStencilState),
    target_info: GraphicsPipelineTargetInfo = std.mem.zeroes(GraphicsPipelineTargetInfo),
    props: c.SDL_PropertiesID = 0,

    pub inline fn toNative(self: *const GraphicsPipelineCreateInfo) c.SDL_GPUGraphicsPipelineCreateInfo {
        return .{
            .vertex_shader = self.vertex_shader,
            .fragment_shader = self.fragment_shader,
            .vertex_input_state = self.vertex_input_state.toNative(),
            .primitive_type = @intFromEnum(self.primitive_type),
            .rasterizer_state = @bitCast(self.rasterizer_state),
            .multisample_state = @bitCast(self.multisample_state),
            .depth_stencil_state = @bitCast(self.depth_stencil_state),
            .target_info = self.target_info.toNative(),
            .props = self.props,
        };
    }
};

pub const Filter = enum(u32) {
    nearest = c.SDL_GPU_FILTER_NEAREST,
    linear = c.SDL_GPU_FILTER_LINEAR,
};

pub const SamplerMipmapMode = enum(u32) {
    nearest = c.SDL_GPU_SAMPLERMIPMAPMODE_NEAREST,
    linear = c.SDL_GPU_SAMPLERMIPMAPMODE_LINEAR,
};

pub const SamplerAddressMode = enum(u32) {
    repeat = c.SDL_GPU_SAMPLERADDRESSMODE_REPEAT,
    mirrored_repeat = c.SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT,
    clamp_to_edge = c.SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE,
};

pub const SamplerCreateInfo = extern struct {
    min_filter: Filter = std.mem.zeroes(Filter),
    mag_filter: Filter = std.mem.zeroes(Filter),
    mipmap_mode: SamplerMipmapMode = std.mem.zeroes(SamplerMipmapMode),
    address_mode_u: SamplerAddressMode = std.mem.zeroes(SamplerAddressMode),
    address_mode_v: SamplerAddressMode = std.mem.zeroes(SamplerAddressMode),
    address_mode_w: SamplerAddressMode = std.mem.zeroes(SamplerAddressMode),
    mip_lod_bias: f32 = std.mem.zeroes(f32),
    max_anisotropy: f32 = std.mem.zeroes(f32),
    compare_op: CompareOp = std.mem.zeroes(CompareOp),
    min_lod: f32 = std.mem.zeroes(f32),
    max_lod: f32 = std.mem.zeroes(f32),
    enable_anisotropy: bool = std.mem.zeroes(bool),
    enable_compare: bool = std.mem.zeroes(bool),
    props: c.SDL_PropertiesID = 0,
};

pub const ShaderCreateInfo = struct {
    code: []const u8 = &.{},
    entrypoint: []const u8 = &.{},
    format: ShaderFormat = std.mem.zeroes(ShaderFormat),
    stage: ShaderStage = std.mem.zeroes(ShaderStage),
    num_samplers: u32 = std.mem.zeroes(u32),
    num_storage_textures: u32 = std.mem.zeroes(u32),
    num_storage_buffers: u32 = std.mem.zeroes(u32),
    num_uniform_buffers: u32 = std.mem.zeroes(u32),
    props: c.SDL_PropertiesID = 0,

    pub inline fn toNative(self: *const ShaderCreateInfo) c.SDL_GPUShaderCreateInfo {
        return .{
            .code = self.code.ptr,
            .code_size = self.code.len,
            .entrypoint = self.entrypoint.ptr,
            .format = self.format.toInt(),
            .stage = @intFromEnum(self.stage),
            .num_samplers = self.num_samplers,
            .num_storage_textures = self.num_storage_textures,
            .num_storage_buffers = self.num_storage_buffers,
            .num_uniform_buffers = self.num_uniform_buffers,
            .props = self.props,
        };
    }
};

pub const TextureCreateInfo = extern struct {
    type: TextureType = std.mem.zeroes(TextureType),
    format: TextureFormat = std.mem.zeroes(TextureFormat),
    usage: TextureUsageFlags = std.mem.zeroes(TextureUsageFlags),
    width: usize = std.mem.zeroes(usize),
    height: usize = std.mem.zeroes(usize),
    layer_count_or_depth: u32 = std.mem.zeroes(u32),
    num_levels: u32 = std.mem.zeroes(u32),
    sample_count: SampleCount = std.mem.zeroes(SampleCount),
    props: c.SDL_PropertiesID = 0,

    pub inline fn toNative(self: *const TextureCreateInfo) c.SDL_GPUTextureCreateInfo {
        return .{
            .type = @intFromEnum(self.type),
            .format = @intFromEnum(self.format),
            .usage = self.usage.toInt(),
            .width = @intCast(self.width),
            .height = @intCast(self.height),
            .layer_count_or_depth = self.layer_count_or_depth,
            .num_levels = self.num_levels,
            .sample_count = @intFromEnum(self.sample_count),
            .props = self.props,
        };
    }
};

pub const BufferCreateInfo = extern struct {
    usage: BufferUsageFlags = std.mem.zeroes(BufferUsageFlags),
    size: u32 = std.mem.zeroes(u32),
    props: c.SDL_PropertiesID = 0,

    pub inline fn toNative(self: *const BufferCreateInfo) c.SDL_GPUBufferCreateInfo {
        return .{
            .usage = self.usage.toInt(),
            .size = self.size,
            .props = self.props,
        };
    }
};

pub const TransferBufferCreateInfo = extern struct {
    usage: TransferBufferUsage = std.mem.zeroes(TransferBufferUsage),
    size: u32 = std.mem.zeroes(u32),
    props: c.SDL_PropertiesID = 0,
};

pub const DeviceProperties = struct {
    debug_mode: ?bool = null,
    prefer_low_power: ?bool = null,
    name: ?[:0]const u8 = null,
    shaders_private: ?bool = null,
    shaders_spirv: ?bool = null,
    shaders_dxbc: ?bool = null,
    shaders_dxil: ?bool = null,
    shaders_msl: ?bool = null,
    shaders_metallib: ?bool = null,
    d3d12_semantic_name: ?[:0]const u8 = null,

    /// Apply the device properties to the given properties object.
    inline fn apply(self: DeviceProperties, props: c.SDL_PropertiesID) void {
        if (self.debug_mode) |dm| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN, dm);
        if (self.prefer_low_power) |plp| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN, plp);
        if (self.name) |n| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING, n);
        if (self.shaders_private) |sp| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN, sp);
        if (self.shaders_spirv) |ss| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN, ss);
        if (self.shaders_dxbc) |sd| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN, sd);
        if (self.shaders_dxil) |sdx| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN, sdx);
        if (self.shaders_msl) |sm| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN, sm);
        if (self.shaders_metallib) |sml| _ = c.SDL_SetBooleanProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN, sml);
        if (self.d3d12_semantic_name) |dsn| _ = c.SDL_SetStringProperty(props, c.SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING, dsn);
    }
};

pub const ShaderFormat = extern struct {
    private: bool = std.mem.zeroes(bool),
    spirv: bool = std.mem.zeroes(bool),
    dxbc: bool = std.mem.zeroes(bool),
    dxil: bool = std.mem.zeroes(bool),
    msl: bool = std.mem.zeroes(bool),
    metallib: bool = std.mem.zeroes(bool),

    pub inline fn toInt(self: *const ShaderFormat) c.SDL_GPUShaderFormat {
        return (if (self.private) c.SDL_GPU_SHADERFORMAT_PRIVATE else 0) |
            (if (self.spirv) c.SDL_GPU_SHADERFORMAT_SPIRV else 0) |
            (if (self.dxbc) c.SDL_GPU_SHADERFORMAT_DXBC else 0) |
            (if (self.dxil) c.SDL_GPU_SHADERFORMAT_DXIL else 0) |
            (if (self.msl) c.SDL_GPU_SHADERFORMAT_MSL else 0) |
            (if (self.metallib) c.SDL_GPU_SHADERFORMAT_METALLIB else 0);
    }

    pub inline fn fromInt(flags: c.SDL_GPUShaderFormat) ShaderFormat {
        return .{
            .private = flags & c.SDL_GPU_SHADERFORMAT_PRIVATE != 0,
            .spirv = flags & c.SDL_GPU_SHADERFORMAT_SPIRV != 0,
            .dxbc = flags & c.SDL_GPU_SHADERFORMAT_DXBC != 0,
            .dxil = flags & c.SDL_GPU_SHADERFORMAT_DXIL != 0,
            .msl = flags & c.SDL_GPU_SHADERFORMAT_MSL != 0,
            .metallib = flags & c.SDL_GPU_SHADERFORMAT_METALLIB != 0,
        };
    }
};

pub const TextureFormat = enum(u32) {
    invalid = c.SDL_GPU_TEXTUREFORMAT_INVALID,
    a8_unorm = c.SDL_GPU_TEXTUREFORMAT_A8_UNORM,
    r8_unorm = c.SDL_GPU_TEXTUREFORMAT_R8_UNORM,
    r8g8_unorm = c.SDL_GPU_TEXTUREFORMAT_R8G8_UNORM,
    r8g8b8a8_unorm = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    r16_unorm = c.SDL_GPU_TEXTUREFORMAT_R16_UNORM,
    r16g16_unorm = c.SDL_GPU_TEXTUREFORMAT_R16G16_UNORM,
    r16g16b16a16_unorm = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UNORM,
    r10g10b10a2_unorm = c.SDL_GPU_TEXTUREFORMAT_R10G10B10A2_UNORM,
    b5g6r5_unorm = c.SDL_GPU_TEXTUREFORMAT_B5G6R5_UNORM,
    b5g5r5a1_unorm = c.SDL_GPU_TEXTUREFORMAT_B5G5R5A1_UNORM,
    b4g4r4a4_unorm = c.SDL_GPU_TEXTUREFORMAT_B4G4R4A4_UNORM,
    b8g8r8a8_unorm = c.SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM,
    bc1_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM,
    bc2_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM,
    bc3_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM,
    bc4_r_unorm = c.SDL_GPU_TEXTUREFORMAT_BC4_R_UNORM,
    bc5_rg_unorm = c.SDL_GPU_TEXTUREFORMAT_BC5_RG_UNORM,
    bc7_rgba_unorm = c.SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM,
    bc6h_rgb_float = c.SDL_GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT,
    bc6h_rgb_ufloat = c.SDL_GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT,
    r8_snorm = c.SDL_GPU_TEXTUREFORMAT_R8_SNORM,
    r8g8_snorm = c.SDL_GPU_TEXTUREFORMAT_R8G8_SNORM,
    r8g8b8a8_snorm = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_SNORM,
    r16_snorm = c.SDL_GPU_TEXTUREFORMAT_R16_SNORM,
    r16g16_snorm = c.SDL_GPU_TEXTUREFORMAT_R16G16_SNORM,
    r16g16b16a16_snorm = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_SNORM,
    r16_float = c.SDL_GPU_TEXTUREFORMAT_R16_FLOAT,
    r16g16_float = c.SDL_GPU_TEXTUREFORMAT_R16G16_FLOAT,
    r16g16b16a16_float = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT,
    r32_float = c.SDL_GPU_TEXTUREFORMAT_R32_FLOAT,
    r32g32_float = c.SDL_GPU_TEXTUREFORMAT_R32G32_FLOAT,
    r32g32b32a32_float = c.SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT,
    r11g11b10_ufloat = c.SDL_GPU_TEXTUREFORMAT_R11G11B10_UFLOAT,
    r8_uint = c.SDL_GPU_TEXTUREFORMAT_R8_UINT,
    r8g8_uint = c.SDL_GPU_TEXTUREFORMAT_R8G8_UINT,
    r8g8b8a8_uint = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UINT,
    r16_uint = c.SDL_GPU_TEXTUREFORMAT_R16_UINT,
    r16g16_uint = c.SDL_GPU_TEXTUREFORMAT_R16G16_UINT,
    r16g16b16a16_uint = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UINT,
    r32_uint = c.SDL_GPU_TEXTUREFORMAT_R32_UINT,
    r32g32_uint = c.SDL_GPU_TEXTUREFORMAT_R32G32_UINT,
    r32g32b32a32_uint = c.SDL_GPU_TEXTUREFORMAT_R32G32B32A32_UINT,
    r8_int = c.SDL_GPU_TEXTUREFORMAT_R8_INT,
    r8g8_int = c.SDL_GPU_TEXTUREFORMAT_R8G8_INT,
    r8g8b8a8_int = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_INT,
    r16_int = c.SDL_GPU_TEXTUREFORMAT_R16_INT,
    r16g16_int = c.SDL_GPU_TEXTUREFORMAT_R16G16_INT,
    r16g16b16a16_int = c.SDL_GPU_TEXTUREFORMAT_R16G16B16A16_INT,
    r32_int = c.SDL_GPU_TEXTUREFORMAT_R32_INT,
    r32g32_int = c.SDL_GPU_TEXTUREFORMAT_R32G32_INT,
    r32g32b32a32_int = c.SDL_GPU_TEXTUREFORMAT_R32G32B32A32_INT,
    r8g8b8a8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB,
    b8g8r8a8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB,
    bc1_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB,
    bc2_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB,
    bc3_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB,
    bc7_rgba_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB,
    d16_unorm = c.SDL_GPU_TEXTUREFORMAT_D16_UNORM,
    d24_unorm = c.SDL_GPU_TEXTUREFORMAT_D24_UNORM,
    d32_float = c.SDL_GPU_TEXTUREFORMAT_D32_FLOAT,
    d24_unorm_s8_uint = c.SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT,
    d32_float_s8_uint = c.SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT,
    astc_4x4_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM,
    astc_5x4_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM,
    astc_5x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM,
    astc_6x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM,
    astc_6x6_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM,
    astc_8x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM,
    astc_8x6_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM,
    astc_8x8_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM,
    astc_10x5_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM,
    astc_10x6_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM,
    astc_10x8_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM,
    astc_10x10_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM,
    astc_12x10_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM,
    astc_12x12_unorm = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM,
    astc_4x4_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_4x4_UNORM_SRGB,
    astc_5x4_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x4_UNORM_SRGB,
    astc_5x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x5_UNORM_SRGB,
    astc_6x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x5_UNORM_SRGB,
    astc_6x6_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x6_UNORM_SRGB,
    astc_8x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x5_UNORM_SRGB,
    astc_8x6_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x6_UNORM_SRGB,
    astc_8x8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x8_UNORM_SRGB,
    astc_10x5_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x5_UNORM_SRGB,
    astc_10x6_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x6_UNORM_SRGB,
    astc_10x8_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x8_UNORM_SRGB,
    astc_10x10_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x10_UNORM_SRGB,
    astc_12x10_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x10_UNORM_SRGB,
    astc_12x12_unorm_srgb = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x12_UNORM_SRGB,
    astc_4x4_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_4x4_FLOAT,
    astc_5x4_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x4_FLOAT,
    astc_5x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_5x5_FLOAT,
    astc_6x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x5_FLOAT,
    astc_6x6_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_6x6_FLOAT,
    astc_8x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x5_FLOAT,
    astc_8x6_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x6_FLOAT,
    astc_8x8_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_8x8_FLOAT,
    astc_10x5_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x5_FLOAT,
    astc_10x6_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x6_FLOAT,
    astc_10x8_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x8_FLOAT,
    astc_10x10_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_10x10_FLOAT,
    astc_12x10_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x10_FLOAT,
    astc_12x12_float = c.SDL_GPU_TEXTUREFORMAT_ASTC_12x12_FLOAT,
};

pub const TextureType = enum(u32) {
    @"2d" = c.SDL_GPU_TEXTURETYPE_2D,
    @"2d_array" = c.SDL_GPU_TEXTURETYPE_2D_ARRAY,
    @"3d" = c.SDL_GPU_TEXTURETYPE_3D,
    cube = c.SDL_GPU_TEXTURETYPE_CUBE,
    cube_array = c.SDL_GPU_TEXTURETYPE_CUBE_ARRAY,
};

pub const TextureUsageFlags = extern struct {
    sampler: bool = std.mem.zeroes(bool),
    color_target: bool = std.mem.zeroes(bool),
    depth_stencil_target: bool = std.mem.zeroes(bool),
    graphics_storage_read: bool = std.mem.zeroes(bool),
    compute_storage_read: bool = std.mem.zeroes(bool),
    compute_storage_write: bool = std.mem.zeroes(bool),
    compute_storage_simultaneous_read_write: bool = std.mem.zeroes(bool),

    pub inline fn toInt(self: TextureUsageFlags) c.SDL_GPUTextureUsageFlags {
        return (if (self.sampler) c.SDL_GPU_TEXTUREUSAGE_SAMPLER else 0) |
            (if (self.color_target) c.SDL_GPU_TEXTUREUSAGE_COLOR_TARGET else 0) |
            (if (self.depth_stencil_target) c.SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET else 0) |
            (if (self.graphics_storage_read) c.SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ else 0) |
            (if (self.compute_storage_read) c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ else 0) |
            (if (self.compute_storage_write) c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE else 0) |
            (if (self.compute_storage_simultaneous_read_write) c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE else 0);
    }

    pub inline fn fromInt(flags: c.SDL_GPUTextureUsageFlags) TextureUsageFlags {
        return .{
            .sampler = flags & c.SDL_GPU_TEXTUREUSAGE_SAMPLER != 0,
            .color_target = flags & c.SDL_GPU_TEXTUREUSAGE_COLOR_TARGET != 0,
            .depth_stencil_target = flags & c.SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET != 0,
            .graphics_storage_read = flags & c.SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ != 0,
            .compute_storage_read = flags & c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ != 0,
            .compute_storage_write = flags & c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE != 0,
            .compute_storage_simultaneous_read_write = flags & c.SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE != 0,
        };
    }
};

pub const SampleCount = enum(u32) {
    @"1" = c.SDL_GPU_SAMPLECOUNT_1,
    @"2" = c.SDL_GPU_SAMPLECOUNT_2,
    @"4" = c.SDL_GPU_SAMPLECOUNT_4,
    @"8" = c.SDL_GPU_SAMPLECOUNT_8,
};

pub const SwapchainComposition = enum(u32) {
    sdr = c.SDL_GPU_SWAPCHAINCOMPOSITION_SDR,
    sdr_linear = c.SDL_GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR,
    hdr_extended_linear = c.SDL_GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR,
    hdr10_st2084 = c.SDL_GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084,
};

pub const PresentMode = enum(u32) {
    immediate = c.SDL_GPU_PRESENTMODE_IMMEDIATE,
    vsync = c.SDL_GPU_PRESENTMODE_VSYNC,
    mailbox = c.SDL_GPU_PRESENTMODE_MAILBOX,
};

pub const PrimitiveType = enum(u32) {
    triangle_list = c.SDL_GPU_PRIMITIVETYPE_TRIANGLELIST,
    triangle_strip = c.SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP,
    line_list = c.SDL_GPU_PRIMITIVETYPE_LINELIST,
    line_strip = c.SDL_GPU_PRIMITIVETYPE_LINESTRIP,
    point_list = c.SDL_GPU_PRIMITIVETYPE_POINTLIST,
};

pub const LoadOp = enum(u32) {
    load = c.SDL_GPU_LOADOP_LOAD,
    clear = c.SDL_GPU_LOADOP_CLEAR,
    dont_care = c.SDL_GPU_LOADOP_DONT_CARE,
};

pub const StoreOp = enum(u32) {
    store = c.SDL_GPU_STOREOP_STORE,
    dont_care = c.SDL_GPU_STOREOP_DONT_CARE,
    resolve = c.SDL_GPU_STOREOP_RESOLVE,
    resolve_and_store = c.SDL_GPU_STOREOP_RESOLVE_AND_STORE,
};

pub const IndexElementSize = enum(u32) {
    @"16bit" = c.SDL_GPU_INDEXELEMENTSIZE_16BIT,
    @"32bit" = c.SDL_GPU_INDEXELEMENTSIZE_32BIT,
};

pub const VertexInputRate = enum(i32) {
    vertex = c.SDL_GPU_VERTEXINPUTRATE_VERTEX,
    instance = c.SDL_GPU_VERTEXINPUTRATE_INSTANCE,
};

pub const FillMode = enum(u32) {
    fill = c.SDL_GPU_FILLMODE_FILL,
    line = c.SDL_GPU_FILLMODE_LINE,
};

pub const CullMode = enum(u32) {
    none = c.SDL_GPU_CULLMODE_NONE,
    front = c.SDL_GPU_CULLMODE_FRONT,
    back = c.SDL_GPU_CULLMODE_BACK,
};

pub const FrontFace = enum(u32) {
    counter_clockwise = c.SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE,
    clockwise = c.SDL_GPU_FRONTFACE_CLOCKWISE,
};

pub const CompareOp = enum(u32) {
    invalid = c.SDL_GPU_COMPAREOP_INVALID,
    never = c.SDL_GPU_COMPAREOP_NEVER,
    less = c.SDL_GPU_COMPAREOP_LESS,
    equal = c.SDL_GPU_COMPAREOP_EQUAL,
    less_or_equal = c.SDL_GPU_COMPAREOP_LESS_OR_EQUAL,
    greater = c.SDL_GPU_COMPAREOP_GREATER,
    not_equal = c.SDL_GPU_COMPAREOP_NOT_EQUAL,
    greater_or_equal = c.SDL_GPU_COMPAREOP_GREATER_OR_EQUAL,
    always = c.SDL_GPU_COMPAREOP_ALWAYS,
};

pub const StencilOp = enum(u32) {
    invalid = c.SDL_GPU_STENCILOP_INVALID,
    keep = c.SDL_GPU_STENCILOP_KEEP,
    zero = c.SDL_GPU_STENCILOP_ZERO,
    replace = c.SDL_GPU_STENCILOP_REPLACE,
    increment_and_clamp = c.SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP,
    decrement_and_clamp = c.SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP,
    invert = c.SDL_GPU_STENCILOP_INVERT,
    increment_and_wrap = c.SDL_GPU_STENCILOP_INCREMENT_AND_WRAP,
    decrement_and_wrap = c.SDL_GPU_STENCILOP_DECREMENT_AND_WRAP,
};

pub const Device = struct {
    ptr: *c.SDL_GPUDevice,

    /// Check for GPU runtime support with specified format flags and name.
    pub inline fn supportsShaderFormats(flags: ShaderFormat, name: ?[*:0]const u8) bool {
        return c.SDL_GPUSupportsShaderFormats(flags, name);
    }

    /// Check for GPU runtime support with properties.
    pub inline fn supportsProperties(props: c.SDL_PropertiesID) bool {
        return c.SDL_GPUSupportsProperties(props);
    }

    /// Create a GPU device with format flags and debug mode.
    pub inline fn create(flags: ShaderFormat, debug_mode: bool, name: ?[*:0]const u8) !Device {
        return Device{
            .ptr = try errify(c.SDL_CreateGPUDevice(flags.toInt(), debug_mode, name)),
        };
    }

    /// Create a GPU device with properties.
    pub inline fn createWithProperties(props: DeviceProperties) !Device {
        const properties = c.SDL_CreateProperties();
        defer c.SDL_DestroyProperties(properties);
        props.apply(properties);
        return .{
            .ptr = try errify(c.SDL_CreateGPUDeviceWithProperties(properties)),
        };
    }

    /// Destroy the GPU device.
    pub inline fn destroy(self: *const Device) void {
        c.SDL_DestroyGPUDevice(self.ptr);
    }

    /// Get the number of GPU drivers compiled into SDL.
    pub inline fn getNumDrivers() i32 {
        return c.SDL_GetNumGPUDrivers();
    }

    /// Get the name of a built-in GPU driver.
    pub inline fn getDriver(index: i32) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetGPUDriver(index)));
    }

    /// Get the name of the backend used to create this GPU device.
    pub inline fn getDeviceDriver(self: *const Device) ![]const u8 {
        return std.mem.span(try errify(c.SDL_GetGPUDeviceDriver(self.ptr)));
    }

    /// Get supported shader formats for this GPU device.
    pub inline fn getShaderFormats(self: *const Device) ShaderFormat {
        return ShaderFormat.fromInt(c.SDL_GetGPUShaderFormats(self.ptr));
    }

    /// Create a compute pipeline object to be used in a compute workflow.
    pub inline fn createComputePipeline(self: *const Device, createinfo: ComputePipelineCreateInfo) !*ComputePipeline {
        return try errify(c.SDL_CreateGPUComputePipeline(self.ptr, createinfo));
    }

    /// Create a graphics pipeline object to be used in a graphics workflow.
    pub inline fn createGraphicsPipeline(self: *const Device, createinfo: GraphicsPipelineCreateInfo) !*GraphicsPipeline {
        return try errify(c.SDL_CreateGPUGraphicsPipeline(self.ptr, @ptrCast(&createinfo.toNative())));
    }

    /// Create a sampler object to be used when binding textures in a graphics workflow.
    pub inline fn createSampler(self: *const Device, createinfo: SamplerCreateInfo) !*Sampler {
        return try errify(c.SDL_CreateGPUSampler(self.ptr, @ptrCast(&createinfo)));
    }

    /// Create a shader to be used when creating a graphics pipeline.
    pub inline fn createShader(self: *const Device, createinfo: ShaderCreateInfo) !*Shader {
        return try errify(c.SDL_CreateGPUShader(self.ptr, @ptrCast(&createinfo.toNative())));
    }

    /// Create a texture object to be used in graphics or compute workflows.
    pub inline fn createTexture(self: *const Device, createinfo: TextureCreateInfo) !*Texture {
        return try errify(c.SDL_CreateGPUTexture(self.ptr, @ptrCast(&createinfo.toNative())));
    }

    /// Create a buffer object to be used in graphics or compute workflows.
    pub inline fn createBuffer(self: *const Device, createinfo: BufferCreateInfo) !*Buffer {
        return try errify(c.SDL_CreateGPUBuffer(self.ptr, @ptrCast(&createinfo.toNative())));
    }

    /// Create a transfer buffer to be used when uploading to or downloading from graphics resources.
    pub inline fn createTransferBuffer(self: *const Device, createinfo: TransferBufferCreateInfo) !*TransferBuffer {
        return try errify(c.SDL_CreateGPUTransferBuffer(self.ptr, @ptrCast(&createinfo)));
    }

    /// Set an arbitrary string constant to label a buffer.
    pub inline fn setBufferName(self: *const Device, buffer: *Buffer, text: [:0]const u8) void {
        c.SDL_SetGPUBufferName(self.ptr, buffer, text);
    }

    /// Set an arbitrary string constant to label a texture.
    pub inline fn setTextureName(self: *const Device, texture: *Texture, text: [:0]const u8) void {
        c.SDL_SetGPUTextureName(self.ptr, texture, text);
    }

    /// Free the given texture as soon as it is safe to do so.
    pub inline fn releaseTexture(self: *const Device, texture: *Texture) void {
        c.SDL_ReleaseGPUTexture(self.ptr, texture);
    }

    /// Free the given sampler as soon as it is safe to do so.
    pub inline fn releaseSampler(self: *const Device, sampler: *Sampler) void {
        c.SDL_ReleaseGPUSampler(self.ptr, sampler);
    }

    /// Free the given buffer as soon as it is safe to do so.
    pub inline fn releaseBuffer(self: *const Device, buffer: *Buffer) void {
        c.SDL_ReleaseGPUBuffer(self.ptr, buffer);
    }

    /// Free the given transfer buffer as soon as it is safe to do so.
    pub inline fn releaseTransferBuffer(self: *const Device, transfer_buffer: *TransferBuffer) void {
        c.SDL_ReleaseGPUTransferBuffer(self.ptr, transfer_buffer);
    }

    /// Free the given compute pipeline as soon as it is safe to do so.
    pub inline fn releaseComputePipeline(self: *const Device, compute_pipeline: *ComputePipeline) void {
        c.SDL_ReleaseGPUComputePipeline(self.ptr, compute_pipeline);
    }

    /// Free the given shader as soon as it is safe to do so.
    pub inline fn releaseShader(self: *const Device, shader: *Shader) void {
        c.SDL_ReleaseGPUShader(self.ptr, shader);
    }

    /// Free the given graphics pipeline as soon as it is safe to do so.
    pub inline fn releaseGraphicsPipeline(self: *const Device, graphics_pipeline: *GraphicsPipeline) void {
        c.SDL_ReleaseGPUGraphicsPipeline(self.ptr, graphics_pipeline);
    }

    /// Acquire a command buffer.
    pub inline fn acquireCommandBuffer(self: *const Device) !CommandBuffer {
        return .{
            .ptr = try errify(c.SDL_AcquireGPUCommandBuffer(self.ptr)),
        };
    }

    /// Check if a window supports the specified swapchain composition.
    pub inline fn windowSupportsSwapchainComposition(self: *const Device, window: *const Window, swapchain_composition: SwapchainComposition) bool {
        return c.SDL_WindowSupportsGPUSwapchainComposition(self.ptr, window.ptr, @intFromEnum(swapchain_composition));
    }

    /// Check if a window supports the specified present mode.
    pub inline fn windowSupportsPresentMode(self: *const Device, window: *const Window, present_mode: PresentMode) bool {
        return c.SDL_WindowSupportsGPUPresentMode(self.ptr, window.ptr, @intFromEnum(present_mode));
    }

    /// Claim a window, creating a swapchain structure for it.
    pub inline fn claimWindow(self: *const Device, window: Window) !void {
        try errify(c.SDL_ClaimWindowForGPUDevice(self.ptr, window.ptr));
    }

    /// Unclaim a window, destroying its swapchain structure.
    pub inline fn releaseWindow(self: *const Device, window: Window) void {
        c.SDL_ReleaseWindowFromGPUDevice(self.ptr, window.ptr);
    }

    /// Change the swapchain parameters for the given claimed window.
    pub inline fn setSwapchainParameters(self: *const Device, window: Window, swapchain_composition: SwapchainComposition, present_mode: PresentMode) !void {
        try errify(c.SDL_SetGPUSwapchainParameters(self.ptr, window.ptr, @intFromEnum(swapchain_composition), @intFromEnum(present_mode)));
    }

    /// Configure the maximum allowed number of frames in flight.
    pub inline fn setAllowedFramesInFlight(self: *const Device, allowed_frames_in_flight: u32) !void {
        try errify(c.SDL_SetGPUAllowedFramesInFlight(self.ptr, allowed_frames_in_flight));
    }

    /// Get the texture format of the swapchain for the given window.
    pub inline fn getSwapchainTextureFormat(self: *const Device, window: Window) TextureFormat {
        return @enumFromInt(c.SDL_GetGPUSwapchainTextureFormat(self.ptr, window.ptr));
    }

    /// Block the thread until the GPU is completely idle.
    pub inline fn waitForIdle(self: *const Device) !void {
        try errify(c.SDL_WaitForGPUIdle(self.ptr));
    }

    /// Block the thread until the given fences are signaled.
    pub inline fn waitForFences(self: *const Device, wait_all: bool, fences: []const *Fence) !void {
        try errify(c.SDL_WaitForGPUFences(self.ptr, wait_all, @ptrCast(fences.ptr), @intCast(fences.len)));
    }

    /// Check the status of a fence.
    pub inline fn queryFence(self: *const Device, fence: *Fence) bool {
        return c.SDL_QueryGPUFence(self.ptr, fence);
    }

    /// Release a fence obtained from SDL_SubmitGPUCommandBufferAndAcquireFence.
    pub inline fn releaseFence(self: *const Device, fence: *Fence) void {
        c.SDL_ReleaseGPUFence(self.ptr, fence);
    }

    /// Get the texel block size for a texture format.
    pub inline fn textureFormatTexelBlockSize(format: TextureFormat) u32 {
        return c.SDL_GPUTextureFormatTexelBlockSize(@intFromEnum(format));
    }

    /// Check if a texture format is supported for a given type and usage.
    pub inline fn textureSupportsFormat(self: *const Device, format: TextureFormat, @"type": TextureType, usage: TextureUsageFlags) bool {
        return c.SDL_GPUTextureSupportsFormat(self.ptr, @intFromEnum(format), @intFromEnum(@"type"), usage.toInt());
    }

    /// Check if a sample count for a texture format is supported.
    pub inline fn textureSupportsSampleCount(self: *const Device, format: TextureFormat, sample_count: SampleCount) bool {
        return c.SDL_GPUTextureSupportsSampleCount(self.ptr, @intFromEnum(format), @intFromEnum(sample_count));
    }

    /// Calculate the size in bytes of a texture format with dimensions.
    pub inline fn calculateTextureFormatSize(format: TextureFormat, width: u32, height: u32, depth_or_layer_count: u32) u32 {
        return c.SDL_CalculateGPUTextureFormatSize(@intFromEnum(format), width, height, depth_or_layer_count);
    }

    /// Suspend GPU operation on Xbox when receiving SDL_EVENT_DID_ENTER_BACKGROUND event.
    pub inline fn gdkSuspend(self: *const Device) void {
        c.SDL_GDKSuspendGPU(self.ptr);
    }

    /// Resume GPU operation on Xbox when receiving SDL_EVENT_WILL_ENTER_FOREGROUND event.
    pub inline fn gdkResume(self: *const Device) void {
        c.SDL_GDKResumeGPU(self.ptr);
    }

    /// Map a transfer buffer into application address space.
    pub inline fn mapTransferBuffer(self: *const Device, transfer_buffer: *TransferBuffer, cycle: bool) !*anyopaque {
        return try errify(c.SDL_MapGPUTransferBuffer(self.ptr, transfer_buffer, cycle));
    }

    /// Unmap a previously mapped transfer buffer.
    pub inline fn unmapTransferBuffer(self: *const Device, transfer_buffer: *TransferBuffer) void {
        c.SDL_UnmapGPUTransferBuffer(self.ptr, transfer_buffer);
    }

    /// Block the thread until a swapchain texture is available.
    pub inline fn waitForSwapchain(self: *const Device, window: Window) !void {
        try errify(c.SDL_WaitForGPUSwapchain(self.ptr, window.ptr));
    }
};
