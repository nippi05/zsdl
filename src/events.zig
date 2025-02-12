const std = @import("std");
const c = @import("c.zig").c;
const internal = @import("internal.zig");
const Window = @import("video.zig").Window;

const errify = internal.errify;

pub const EventType = enum(u32) {
    first,
    quit,
    app,
    display,
    window,
    keyboard,
    mouse,
    joystick,
    gamepad,
    touch,
    sensor,
    audio,
    render,
    drop,
    clipboard,
    camera,
    pen,
    _,
};

pub const Event = union(EventType) {
    first: void,
    quit: void,
    app: AppEvent,
    display: DisplayEvent,
    window: WindowEvent,
    keyboard: KeyboardEvent,
    mouse: MouseEvent,
    joystick: JoystickEvent,
    gamepad: GamepadEvent,
    touch: TouchEvent,
    sensor: SensorEvent,
    audio: AudioEvent,
    render: RenderEvent,
    drop: DropEvent,
    clipboard: ClipboardEvent,
    camera: CameraEvent,
    pen: PenEvent,

    pub fn fromNative(event: c.SDL_Event) Event {
        return switch (event.type) {
            c.SDL_EVENT_FIRST => .{ .first = {} },
            c.SDL_EVENT_QUIT => .{ .quit = {} },
            c.SDL_EVENT_TERMINATING...c.SDL_EVENT_SYSTEM_THEME_CHANGED => .{
                .app = .{
                    .data = switch (event.type) {
                        c.SDL_EVENT_TERMINATING => .terminating,
                        c.SDL_EVENT_LOW_MEMORY => .low_memory,
                        c.SDL_EVENT_WILL_ENTER_BACKGROUND => .will_enter_background,
                        c.SDL_EVENT_DID_ENTER_BACKGROUND => .did_enter_background,
                        c.SDL_EVENT_WILL_ENTER_FOREGROUND => .will_enter_foreground,
                        c.SDL_EVENT_DID_ENTER_FOREGROUND => .did_enter_foreground,
                        c.SDL_EVENT_LOCALE_CHANGED => .locale_changed,
                        c.SDL_EVENT_SYSTEM_THEME_CHANGED => .system_theme_changed,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_DISPLAY_FIRST...c.SDL_EVENT_DISPLAY_LAST => .{
                .display = .{
                    .id = event.display.displayID,
                    .data = switch (event.display.type) {
                        c.SDL_EVENT_DISPLAY_ORIENTATION => .{ .orientation = event.display.data1 },
                        c.SDL_EVENT_DISPLAY_ADDED => .added,
                        c.SDL_EVENT_DISPLAY_REMOVED => .removed,
                        c.SDL_EVENT_DISPLAY_MOVED => .moved,
                        c.SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED => .content_scale_changed,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_WINDOW_FIRST...c.SDL_EVENT_WINDOW_LAST => .{
                .window = .{
                    .window_id = event.window.windowID,
                    .data = switch (event.window.type) {
                        c.SDL_EVENT_WINDOW_SHOWN => .shown,
                        c.SDL_EVENT_WINDOW_HIDDEN => .hidden,
                        c.SDL_EVENT_WINDOW_EXPOSED => .exposed,
                        c.SDL_EVENT_WINDOW_MOVED => .{ .moved = .{ .x = event.window.data1, .y = event.window.data2 } },
                        c.SDL_EVENT_WINDOW_RESIZED => .{ .resized = .{ .width = event.window.data1, .height = event.window.data2 } },
                        c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => .{ .pixel_size_changed = .{ .width = event.window.data1, .height = event.window.data2 } },
                        c.SDL_EVENT_WINDOW_METAL_VIEW_RESIZED => .metal_view_resized,
                        c.SDL_EVENT_WINDOW_MINIMIZED => .minimized,
                        c.SDL_EVENT_WINDOW_MAXIMIZED => .maximized,
                        c.SDL_EVENT_WINDOW_RESTORED => .restored,
                        c.SDL_EVENT_WINDOW_MOUSE_ENTER => .mouse_enter,
                        c.SDL_EVENT_WINDOW_MOUSE_LEAVE => .mouse_leave,
                        c.SDL_EVENT_WINDOW_FOCUS_GAINED => .focus_gained,
                        c.SDL_EVENT_WINDOW_FOCUS_LOST => .focus_lost,
                        c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => .close_requested,
                        c.SDL_EVENT_WINDOW_HIT_TEST => .hit_test,
                        c.SDL_EVENT_WINDOW_ICCPROF_CHANGED => .iccprof_changed,
                        c.SDL_EVENT_WINDOW_DISPLAY_CHANGED => .{ .display_changed = event.window.data1 },
                        c.SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED => .display_scale_changed,
                        c.SDL_EVENT_WINDOW_SAFE_AREA_CHANGED => .safe_area_changed,
                        c.SDL_EVENT_WINDOW_OCCLUDED => .occluded,
                        c.SDL_EVENT_WINDOW_ENTER_FULLSCREEN => .enter_fullscreen,
                        c.SDL_EVENT_WINDOW_LEAVE_FULLSCREEN => .leave_fullscreen,
                        c.SDL_EVENT_WINDOW_DESTROYED => .destroyed,
                        c.SDL_EVENT_WINDOW_HDR_STATE_CHANGED => .hdr_state_changed,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_KEY_DOWN...c.SDL_EVENT_TEXT_EDITING_CANDIDATES => .{
                .keyboard = .{
                    .window_id = event.key.windowID,
                    .data = switch (event.type) {
                        c.SDL_EVENT_KEY_DOWN => .{ .down = .{
                            .scancode = event.key.scancode,
                            .keycode = event.key.key,
                            .mod = event.key.mod,
                            .repeat = event.key.repeat,
                        } },
                        c.SDL_EVENT_KEY_UP => .{ .up = .{
                            .scancode = event.key.scancode,
                            .keycode = event.key.key,
                            .mod = event.key.mod,
                            .repeat = event.key.repeat,
                        } },
                        c.SDL_EVENT_TEXT_EDITING => .{ .text_editing = .{
                            .text = event.edit.text[0..std.mem.len(event.edit.text)],
                            .start = event.edit.start,
                            .length = event.edit.length,
                        } },
                        c.SDL_EVENT_TEXT_INPUT => .{ .text_input = event.text.text[0..std.mem.len(event.text.text)] },
                        c.SDL_EVENT_KEYMAP_CHANGED => .keymap_changed,
                        c.SDL_EVENT_KEYBOARD_ADDED => .added,
                        c.SDL_EVENT_KEYBOARD_REMOVED => .removed,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_MOUSE_MOTION...c.SDL_EVENT_MOUSE_REMOVED => .{
                .mouse = .{
                    .window_id = switch (event.type) {
                        c.SDL_EVENT_MOUSE_MOTION => event.motion.windowID,
                        c.SDL_EVENT_MOUSE_BUTTON_DOWN, c.SDL_EVENT_MOUSE_BUTTON_UP => event.button.windowID,
                        c.SDL_EVENT_MOUSE_WHEEL => event.wheel.windowID,
                        else => 0,
                    },
                    .data = switch (event.type) {
                        c.SDL_EVENT_MOUSE_MOTION => .{ .motion = .{
                            .which = event.motion.which,
                            .state = event.motion.state,
                            .x = event.motion.x,
                            .y = event.motion.y,
                            .xrel = event.motion.xrel,
                            .yrel = event.motion.yrel,
                        } },
                        c.SDL_EVENT_MOUSE_BUTTON_DOWN => .{ .button_down = .{
                            .which = event.button.which,
                            .button = event.button.button,
                            .clicks = event.button.clicks,
                            .x = event.button.x,
                            .y = event.button.y,
                        } },
                        c.SDL_EVENT_MOUSE_BUTTON_UP => .{ .button_up = .{
                            .which = event.button.which,
                            .button = event.button.button,
                            .clicks = event.button.clicks,
                            .x = event.button.x,
                            .y = event.button.y,
                        } },
                        c.SDL_EVENT_MOUSE_WHEEL => .{ .wheel = .{
                            .which = event.wheel.which,
                            .x = event.wheel.x,
                            .y = event.wheel.y,
                            .direction = event.wheel.direction,
                        } },
                        c.SDL_EVENT_MOUSE_ADDED => .added,
                        c.SDL_EVENT_MOUSE_REMOVED => .removed,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_JOYSTICK_AXIS_MOTION...c.SDL_EVENT_JOYSTICK_UPDATE_COMPLETE => .{
                .joystick = .{
                    .which = event.jdevice.which,
                    .data = switch (event.type) {
                        c.SDL_EVENT_JOYSTICK_AXIS_MOTION => .{ .axis_motion = .{
                            .axis = event.jaxis.axis,
                            .value = event.jaxis.value,
                        } },
                        c.SDL_EVENT_JOYSTICK_BALL_MOTION => .{ .ball_motion = .{
                            .ball = event.jball.ball,
                            .xrel = event.jball.xrel,
                            .yrel = event.jball.yrel,
                        } },
                        c.SDL_EVENT_JOYSTICK_HAT_MOTION => .{ .hat_motion = .{
                            .hat = event.jhat.hat,
                            .value = event.jhat.value,
                        } },
                        c.SDL_EVENT_JOYSTICK_BUTTON_DOWN => .{ .button_down = .{
                            .button = event.jbutton.button,
                            .pressed = true,
                        } },
                        c.SDL_EVENT_JOYSTICK_BUTTON_UP => .{ .button_up = .{
                            .button = event.jbutton.button,
                            .pressed = false,
                        } },
                        c.SDL_EVENT_JOYSTICK_ADDED => .added,
                        c.SDL_EVENT_JOYSTICK_REMOVED => .removed,
                        c.SDL_EVENT_JOYSTICK_BATTERY_UPDATED => .{ .battery_updated = .{
                            .state = event.jbattery.state,
                            .percent = event.jbattery.percent,
                        } },
                        c.SDL_EVENT_JOYSTICK_UPDATE_COMPLETE => .update_complete,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_GAMEPAD_AXIS_MOTION...c.SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED => .{
                .gamepad = .{
                    .which = event.gdevice.which,
                    .data = switch (event.type) {
                        c.SDL_EVENT_GAMEPAD_AXIS_MOTION => .{ .axis_motion = .{
                            .axis = event.gaxis.axis,
                            .value = event.gaxis.value,
                        } },
                        c.SDL_EVENT_GAMEPAD_BUTTON_DOWN => .{ .button_down = .{
                            .button = event.gbutton.button,
                            .pressed = true,
                        } },
                        c.SDL_EVENT_GAMEPAD_BUTTON_UP => .{ .button_up = .{
                            .button = event.gbutton.button,
                            .pressed = false,
                        } },
                        c.SDL_EVENT_GAMEPAD_ADDED => .added,
                        c.SDL_EVENT_GAMEPAD_REMOVED => .removed,
                        c.SDL_EVENT_GAMEPAD_REMAPPED => .remapped,
                        c.SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN,
                        c.SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION,
                        c.SDL_EVENT_GAMEPAD_TOUCHPAD_UP,
                        => .{ .touchpad = .{
                            .kind = switch (event.type) {
                                c.SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN => .down,
                                c.SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION => .motion,
                                c.SDL_EVENT_GAMEPAD_TOUCHPAD_UP => .up,
                                else => unreachable,
                            },
                            .touchpad = event.gtouchpad.touchpad,
                            .finger = event.gtouchpad.finger,
                            .x = event.gtouchpad.x,
                            .y = event.gtouchpad.y,
                            .pressure = event.gtouchpad.pressure,
                        } },
                        c.SDL_EVENT_GAMEPAD_SENSOR_UPDATE => .{ .sensor = .{
                            .sensor = event.gsensor.sensor,
                            .data = event.gsensor.data,
                            .timestamp = event.gsensor.sensor_timestamp,
                        } },
                        c.SDL_EVENT_GAMEPAD_UPDATE_COMPLETE => .update_complete,
                        c.SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED => .steam_handle_updated,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_FINGER_DOWN...c.SDL_EVENT_FINGER_CANCELED => .{
                .touch = .{
                    .window_id = event.tfinger.windowID,
                    .data = if (event.type == c.SDL_EVENT_FINGER_CANCELED) .canceled else .{
                        .finger = .{
                            .kind = switch (event.type) {
                                c.SDL_EVENT_FINGER_DOWN => .down,
                                c.SDL_EVENT_FINGER_UP => .up,
                                c.SDL_EVENT_FINGER_MOTION => .motion,
                                else => unreachable,
                            },
                            .touch_id = event.tfinger.touchID,
                            .finger_id = event.tfinger.fingerID,
                            .x = event.tfinger.x,
                            .y = event.tfinger.y,
                            .dx = event.tfinger.dx,
                            .dy = event.tfinger.dy,
                            .pressure = event.tfinger.pressure,
                        },
                    },
                },
            },
            c.SDL_EVENT_DROP_FILE...c.SDL_EVENT_DROP_POSITION => .{
                .drop = .{
                    .window_id = event.drop.windowID,
                    .data = switch (event.type) {
                        c.SDL_EVENT_DROP_FILE => .{ .file = event.drop.data[0..std.mem.len(event.drop.data)] },
                        c.SDL_EVENT_DROP_TEXT => .{ .text = event.drop.data[0..std.mem.len(event.drop.data)] },
                        c.SDL_EVENT_DROP_BEGIN => .begin,
                        c.SDL_EVENT_DROP_COMPLETE => .complete,
                        c.SDL_EVENT_DROP_POSITION => .{ .position = .{ .x = event.drop.x, .y = event.drop.y } },
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_AUDIO_DEVICE_ADDED...c.SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED => .{
                .audio = .{
                    .which = event.adevice.which,
                    .recording = event.adevice.recording,
                    .data = switch (event.type) {
                        c.SDL_EVENT_AUDIO_DEVICE_ADDED => .added,
                        c.SDL_EVENT_AUDIO_DEVICE_REMOVED => .removed,
                        c.SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED => .format_changed,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_SENSOR_UPDATE => .{
                .sensor = .{
                    .which = event.sensor.which,
                    .data = event.sensor.data,
                    .timestamp = event.sensor.sensor_timestamp,
                },
            },
            c.SDL_EVENT_RENDER_TARGETS_RESET...c.SDL_EVENT_RENDER_DEVICE_LOST => .{
                .render = .{
                    .window_id = event.render.windowID,
                    .data = switch (event.type) {
                        c.SDL_EVENT_RENDER_TARGETS_RESET => .targets_reset,
                        c.SDL_EVENT_RENDER_DEVICE_RESET => .device_reset,
                        c.SDL_EVENT_RENDER_DEVICE_LOST => .device_lost,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_CLIPBOARD_UPDATE => .{
                .clipboard = .{
                    .owner = event.clipboard.owner,
                    .mime_types = @as([*]const [*:0]const u8, @ptrCast(event.clipboard.mime_types))[0..@intCast(event.clipboard.num_mime_types)],
                },
            },
            c.SDL_EVENT_CAMERA_DEVICE_ADDED...c.SDL_EVENT_CAMERA_DEVICE_DENIED => .{
                .camera = .{
                    .which = event.cdevice.which,
                    .data = switch (event.type) {
                        c.SDL_EVENT_CAMERA_DEVICE_ADDED => .added,
                        c.SDL_EVENT_CAMERA_DEVICE_REMOVED => .removed,
                        c.SDL_EVENT_CAMERA_DEVICE_APPROVED => .approved,
                        c.SDL_EVENT_CAMERA_DEVICE_DENIED => .denied,
                        else => unreachable,
                    },
                },
            },
            c.SDL_EVENT_PEN_PROXIMITY_IN...c.SDL_EVENT_PEN_AXIS => .{
                .pen = .{
                    .window_id = switch (event.type) {
                        c.SDL_EVENT_PEN_PROXIMITY_IN, c.SDL_EVENT_PEN_PROXIMITY_OUT => event.pproximity.windowID,
                        c.SDL_EVENT_PEN_DOWN, c.SDL_EVENT_PEN_UP => event.ptouch.windowID,
                        c.SDL_EVENT_PEN_MOTION => event.pmotion.windowID,
                        c.SDL_EVENT_PEN_BUTTON_DOWN, c.SDL_EVENT_PEN_BUTTON_UP => event.pbutton.windowID,
                        c.SDL_EVENT_PEN_AXIS => event.paxis.windowID,
                        else => unreachable,
                    },
                    .which = switch (event.type) {
                        c.SDL_EVENT_PEN_PROXIMITY_IN, c.SDL_EVENT_PEN_PROXIMITY_OUT => event.pproximity.which,
                        c.SDL_EVENT_PEN_DOWN, c.SDL_EVENT_PEN_UP => event.ptouch.which,
                        c.SDL_EVENT_PEN_MOTION => event.pmotion.which,
                        c.SDL_EVENT_PEN_BUTTON_DOWN, c.SDL_EVENT_PEN_BUTTON_UP => event.pbutton.which,
                        c.SDL_EVENT_PEN_AXIS => event.paxis.which,
                        else => unreachable,
                    },
                    .data = switch (event.type) {
                        c.SDL_EVENT_PEN_PROXIMITY_IN => .proximity_in,
                        c.SDL_EVENT_PEN_PROXIMITY_OUT => .proximity_out,
                        c.SDL_EVENT_PEN_DOWN => .{ .down = .{
                            .pen_state = event.ptouch.pen_state,
                            .x = event.ptouch.x,
                            .y = event.ptouch.y,
                            .eraser = event.ptouch.eraser,
                        } },
                        c.SDL_EVENT_PEN_UP => .{ .up = .{
                            .pen_state = event.ptouch.pen_state,
                            .x = event.ptouch.x,
                            .y = event.ptouch.y,
                            .eraser = event.ptouch.eraser,
                        } },
                        c.SDL_EVENT_PEN_MOTION => .{ .motion = .{
                            .pen_state = event.pmotion.pen_state,
                            .x = event.pmotion.x,
                            .y = event.pmotion.y,
                        } },
                        c.SDL_EVENT_PEN_BUTTON_DOWN => .{ .button_down = .{
                            .pen_state = event.pbutton.pen_state,
                            .x = event.pbutton.x,
                            .y = event.pbutton.y,
                            .button = event.pbutton.button,
                            .pressed = event.pbutton.down,
                        } },
                        c.SDL_EVENT_PEN_BUTTON_UP => .{ .button_up = .{
                            .pen_state = event.pbutton.pen_state,
                            .x = event.pbutton.x,
                            .y = event.pbutton.y,
                            .button = event.pbutton.button,
                            .pressed = event.pbutton.down,
                        } },
                        c.SDL_EVENT_PEN_AXIS => .{ .axis = .{
                            .pen_state = event.paxis.pen_state,
                            .x = event.paxis.x,
                            .y = event.paxis.y,
                            .axis = event.paxis.axis,
                            .value = event.paxis.value,
                        } },
                        else => unreachable,
                    },
                },
            },
            else => unreachable,
        };
    }
};

pub const Point = struct { x: i32, y: i32 };
pub const Size = struct { width: i32, height: i32 };

pub const AppEvent = struct {
    data: Data,

    const Data = enum {
        terminating,
        low_memory,
        will_enter_background,
        did_enter_background,
        will_enter_foreground,
        did_enter_foreground,
        locale_changed,
        system_theme_changed,
    };
};

pub const DisplayEvent = struct {
    id: c.SDL_DisplayID,
    data: Data,

    const Data = union(enum) {
        orientation: i32,
        added: void,
        removed: void,
        moved: void,
        content_scale_changed: void,
    };
};

pub const WindowEvent = struct {
    window_id: c.SDL_WindowID,
    data: Data,

    const Data = union(enum) {
        shown: void,
        hidden: void,
        exposed: void,
        moved: Point,
        resized: Size,
        pixel_size_changed: Size,
        metal_view_resized: void,
        minimized: void,
        maximized: void,
        restored: void,
        mouse_enter: void,
        mouse_leave: void,
        focus_gained: void,
        focus_lost: void,
        close_requested: void,
        hit_test: void,
        iccprof_changed: void,
        display_changed: i32,
        display_scale_changed: void,
        safe_area_changed: void,
        occluded: void,
        enter_fullscreen: void,
        leave_fullscreen: void,
        destroyed: void,
        hdr_state_changed: void,
    };
};

pub const KeyboardEvent = struct {
    window_id: c.SDL_WindowID,
    data: Data,

    const Data = union(enum) {
        down: KeyInfo,
        up: KeyInfo,
        text_editing: TextEditInfo,
        text_input: []const u8,
        keymap_changed: void,
        added: void,
        removed: void,
    };

    const KeyInfo = struct {
        scancode: c.SDL_Scancode,
        keycode: c.SDL_Keycode,
        mod: c.SDL_Keymod,
        repeat: bool,
    };

    const TextEditInfo = struct {
        text: []const u8,
        start: i32,
        length: i32,
    };
};

pub const MouseEvent = struct {
    window_id: c.SDL_WindowID,
    data: Data,

    const Data = union(enum) {
        motion: Motion,
        button_down: Button,
        button_up: Button,
        wheel: Wheel,
        added: void,
        removed: void,
    };

    const Motion = struct {
        which: c.SDL_MouseID,
        state: c.SDL_MouseButtonFlags,
        x: f32,
        y: f32,
        xrel: f32,
        yrel: f32,
    };

    const Button = struct {
        which: c.SDL_MouseID,
        button: u8,
        clicks: u8,
        x: f32,
        y: f32,
    };

    const Wheel = struct {
        which: c.SDL_MouseID,
        x: f32,
        y: f32,
        direction: c.SDL_MouseWheelDirection,
    };
};

pub const JoystickEvent = struct {
    which: c.SDL_JoystickID,
    data: Data,

    const Data = union(enum) {
        axis_motion: Axis,
        ball_motion: Ball,
        hat_motion: Hat,
        button_down: Button,
        button_up: Button,
        added: void,
        removed: void,
        battery_updated: Battery,
        update_complete: void,
    };

    const Axis = struct {
        axis: u8,
        value: i16,
    };

    const Ball = struct {
        ball: u8,
        xrel: i16,
        yrel: i16,
    };

    const Hat = struct {
        hat: u8,
        value: u8,
    };

    const Button = struct {
        button: u8,
        pressed: bool,
    };

    const Battery = struct {
        state: c.SDL_PowerState,
        percent: i32,
    };
};

pub const GamepadEvent = struct {
    which: c.SDL_JoystickID,
    data: Data,

    const Data = union(enum) {
        axis_motion: Axis,
        button_down: Button,
        button_up: Button,
        added: void,
        removed: void,
        remapped: void,
        touchpad: Touchpad,
        sensor: Sensor,
        update_complete: void,
        steam_handle_updated: void,
    };

    const Axis = struct {
        axis: u8,
        value: i16,
    };

    const Button = struct {
        button: u8,
        pressed: bool,
    };

    const Touchpad = struct {
        kind: enum { down, motion, up },
        touchpad: i32,
        finger: i32,
        x: f32,
        y: f32,
        pressure: f32,
    };

    const Sensor = struct {
        sensor: i32,
        data: [3]f32,
        timestamp: u64,
    };
};

pub const TouchEvent = struct {
    window_id: c.SDL_WindowID,
    data: Data,

    const Data = union(enum) {
        finger: Finger,
        canceled: void,
    };

    const Finger = struct {
        kind: enum { down, up, motion },
        touch_id: c.SDL_TouchID,
        finger_id: c.SDL_FingerID,
        x: f32,
        y: f32,
        dx: f32,
        dy: f32,
        pressure: f32,
    };
};

pub const DropEvent = struct {
    window_id: c.SDL_WindowID,
    data: Data,

    const Data = union(enum) {
        file: []const u8,
        text: []const u8,
        begin: void,
        complete: void,
        position: Position,
    };

    const Position = struct {
        x: f32,
        y: f32,
    };
};

pub const ClipboardEvent = struct {
    owner: bool,
    mime_types: []const [*:0]const u8,
};

pub const AudioEvent = struct {
    which: c.SDL_AudioDeviceID,
    recording: bool,
    data: Data,

    const Data = union(enum) {
        added: void,
        removed: void,
        format_changed: void,
    };
};

pub const CameraEvent = struct {
    which: c.SDL_CameraID,
    data: Data,

    const Data = union(enum) {
        added: void,
        removed: void,
        approved: void,
        denied: void,
    };
};

pub const SensorEvent = struct {
    which: c.SDL_SensorID,
    data: [6]f32,
    timestamp: u64,
};

pub const PenEvent = struct {
    window_id: c.SDL_WindowID,
    which: c.SDL_PenID,
    data: Data,

    const Data = union(enum) {
        proximity_in: void,
        proximity_out: void,
        down: PenTouch,
        up: PenTouch,
        motion: PenMotion,
        button_down: PenButton,
        button_up: PenButton,
        axis: PenAxis,
    };

    const PenTouch = struct {
        pen_state: c.SDL_PenInputFlags,
        x: f32,
        y: f32,
        eraser: bool,
    };

    const PenMotion = struct {
        pen_state: c.SDL_PenInputFlags,
        x: f32,
        y: f32,
    };

    const PenButton = struct {
        pen_state: c.SDL_PenInputFlags,
        x: f32,
        y: f32,
        button: u8,
        pressed: bool,
    };

    const PenAxis = struct {
        pen_state: c.SDL_PenInputFlags,
        x: f32,
        y: f32,
        axis: c.SDL_PenAxis,
        value: f32,
    };
};

pub const RenderEvent = struct {
    window_id: c.SDL_WindowID,
    data: Data,

    const Data = union(enum) {
        targets_reset: void,
        device_reset: void,
        device_lost: void,
    };
};

/// Poll for currently pending events.
pub fn pollEvent() ?Event {
    var event: c.SDL_Event = undefined;
    if (!c.SDL_PollEvent(&event)) return null;
    return Event.fromNative(event);
}

/// Pump the event loop, gathering events from the input devices.
pub fn pumpEvents() void {
    c.SDL_PumpEvents();
}

/// Check the event queue for messages and optionally return them.
pub fn peepEvents(events: ?[*]c.SDL_Event, numevents: i32, action: c.SDL_EventAction, minType: u32, maxType: u32) !i32 {
    return errify(c.SDL_PeepEvents(events, numevents, action, minType, maxType));
}

/// Check for the existence of a certain event type in the event queue.
pub fn hasEvent(event_type: u32) bool {
    return c.SDL_HasEvent(event_type);
}

/// Check for the existence of certain event types in the event queue.
pub fn hasEvents(minType: u32, maxType: u32) bool {
    return c.SDL_HasEvents(minType, maxType);
}

/// Clear events of a specific type from the event queue.
pub fn flushEvent(event_type: u32) void {
    c.SDL_FlushEvent(event_type);
}

/// Clear events of a range of types from the event queue.
pub fn flushEvents(minType: u32, maxType: u32) void {
    c.SDL_FlushEvents(minType, maxType);
}

/// Wait indefinitely for the next available event.
pub fn waitEvent(event: ?*c.SDL_Event) !bool {
    return errify(c.SDL_WaitEvent(event));
}

/// Wait until the specified timeout (in milliseconds) for the next available event.
pub fn waitEventTimeout(event: ?*c.SDL_Event, timeout: i32) bool {
    return c.SDL_WaitEventTimeout(event, timeout);
}

/// Add an event to the event queue.
pub fn pushEvent(event: *c.SDL_Event) !bool {
    return errify(c.SDL_PushEvent(event));
}

/// Set up a filter to process all events before they are added to the internal event queue.
pub fn setEventFilter(filter: c.SDL_EventFilter, userdata: ?*anyopaque) void {
    c.SDL_SetEventFilter(filter, userdata);
}

/// Query the current event filter.
pub fn getEventFilter(filter: ?*c.SDL_EventFilter, userdata: ?*?*anyopaque) bool {
    return c.SDL_GetEventFilter(filter, userdata);
}

/// Add a callback to be triggered when an event is added to the event queue.
pub fn addEventWatch(filter: c.SDL_EventFilter, userdata: ?*anyopaque) !bool {
    return errify(c.SDL_AddEventWatch(filter, userdata));
}

/// Remove an event watch callback added with addEventWatch().
pub fn removeEventWatch(filter: c.SDL_EventFilter, userdata: ?*anyopaque) void {
    c.SDL_RemoveEventWatch(filter, userdata);
}

/// Run a specific filter function on the current event queue, removing any events for which the filter returns false.
pub fn filterEvents(filter: c.SDL_EventFilter, userdata: ?*anyopaque) void {
    c.SDL_FilterEvents(filter, userdata);
}

/// Set the state of processing events by type.
pub fn setEventEnabled(event_type: u32, enabled: bool) void {
    c.SDL_SetEventEnabled(event_type, enabled);
}

/// Query the state of processing events by type.
pub fn eventEnabled(event_type: u32) bool {
    return c.SDL_EventEnabled(event_type);
}

/// Allocate a set of user-defined events, and return the beginning event number for that set of events.
pub fn registerEvents(numevents: i32) u32 {
    return c.SDL_RegisterEvents(numevents);
}

/// Get window associated with an event.
pub fn getWindowFromEvent(event: *const c.SDL_Event) ?*Window {
    if (c.SDL_GetWindowFromEvent(event)) |window| {
        return @ptrCast(window);
    }
    return null;
}
