const std = @import("std");

const c = @import("c.zig").c;
const EventFilter = c.SDL_EventFilter;
const PenID = c.SDL_PenID;
const AudioDeviceID = c.SDL_AudioDeviceID;
const SensorID = c.SDL_SensorID;
const CameraID = @import("camera.zig").CameraID;
const internal = @import("internal.zig");
const errifyWithValue = internal.errifyWithValue;
const errify = internal.errify;
const JoystickID = @import("joystick.zig").JoystickID;
const KeyboardID = @import("keyboard.zig").KeyboardID;
const MouseID = @import("mouse.zig").MouseID;
const Point = @import("rect.zig").Point;
const Size = @import("rect.zig").Size;
const touch = @import("touch.zig");
const TouchID = touch.TouchID;
const FingerID = touch.FingerID;
const video = @import("video.zig");
const Window = video.Window;
const DisplayID = video.DisplayID;
const WindowID = video.WindowID;

pub const EventType = enum(u32) {
    first = c.SDL_EVENT_FIRST,
    quit = c.SDL_EVENT_QUIT,
    terminating = c.SDL_EVENT_TERMINATING,
    low_memory = c.SDL_EVENT_LOW_MEMORY,
    will_enter_background = c.SDL_EVENT_WILL_ENTER_BACKGROUND,
    did_enter_background = c.SDL_EVENT_DID_ENTER_BACKGROUND,
    will_enter_foreground = c.SDL_EVENT_WILL_ENTER_FOREGROUND,
    did_enter_foreground = c.SDL_EVENT_DID_ENTER_FOREGROUND,
    locale_changed = c.SDL_EVENT_LOCALE_CHANGED,
    system_theme_changed = c.SDL_EVENT_SYSTEM_THEME_CHANGED,
    display_orientation = c.SDL_EVENT_DISPLAY_ORIENTATION,
    display_added = c.SDL_EVENT_DISPLAY_ADDED,
    display_removed = c.SDL_EVENT_DISPLAY_REMOVED,
    display_moved = c.SDL_EVENT_DISPLAY_MOVED,
    display_desktop_mode_changed = c.SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED,
    display_current_mode_changed = c.SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED,
    display_content_scale_changed = c.SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED,
    window_shown = c.SDL_EVENT_WINDOW_SHOWN,
    window_hidden = c.SDL_EVENT_WINDOW_HIDDEN,
    window_exposed = c.SDL_EVENT_WINDOW_EXPOSED,
    window_moved = c.SDL_EVENT_WINDOW_MOVED,
    window_resized = c.SDL_EVENT_WINDOW_RESIZED,
    window_pixel_size_changed = c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED,
    window_metal_view_resized = c.SDL_EVENT_WINDOW_METAL_VIEW_RESIZED,
    window_minimized = c.SDL_EVENT_WINDOW_MINIMIZED,
    window_maximized = c.SDL_EVENT_WINDOW_MAXIMIZED,
    window_restored = c.SDL_EVENT_WINDOW_RESTORED,
    window_mouse_enter = c.SDL_EVENT_WINDOW_MOUSE_ENTER,
    window_mouse_leave = c.SDL_EVENT_WINDOW_MOUSE_LEAVE,
    window_focus_gained = c.SDL_EVENT_WINDOW_FOCUS_GAINED,
    window_focus_lost = c.SDL_EVENT_WINDOW_FOCUS_LOST,
    window_close_requested = c.SDL_EVENT_WINDOW_CLOSE_REQUESTED,
    window_hit_test = c.SDL_EVENT_WINDOW_HIT_TEST,
    window_iccprof_changed = c.SDL_EVENT_WINDOW_ICCPROF_CHANGED,
    window_display_changed = c.SDL_EVENT_WINDOW_DISPLAY_CHANGED,
    window_display_scale_changed = c.SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED,
    window_safe_area_changed = c.SDL_EVENT_WINDOW_SAFE_AREA_CHANGED,
    window_occluded = c.SDL_EVENT_WINDOW_OCCLUDED,
    window_enter_fullscreen = c.SDL_EVENT_WINDOW_ENTER_FULLSCREEN,
    window_leave_fullscreen = c.SDL_EVENT_WINDOW_LEAVE_FULLSCREEN,
    window_destroyed = c.SDL_EVENT_WINDOW_DESTROYED,
    window_hdr_state_changed = c.SDL_EVENT_WINDOW_HDR_STATE_CHANGED,
    key_down = c.SDL_EVENT_KEY_DOWN,
    key_up = c.SDL_EVENT_KEY_UP,
    text_editing = c.SDL_EVENT_TEXT_EDITING,
    text_input = c.SDL_EVENT_TEXT_INPUT,
    keymap_changed = c.SDL_EVENT_KEYMAP_CHANGED,
    keyboard_added = c.SDL_EVENT_KEYBOARD_ADDED,
    keyboard_removed = c.SDL_EVENT_KEYBOARD_REMOVED,
    text_editing_candidates = c.SDL_EVENT_TEXT_EDITING_CANDIDATES,
    mouse_motion = c.SDL_EVENT_MOUSE_MOTION,
    mouse_button_down = c.SDL_EVENT_MOUSE_BUTTON_DOWN,
    mouse_button_up = c.SDL_EVENT_MOUSE_BUTTON_UP,
    mouse_wheel = c.SDL_EVENT_MOUSE_WHEEL,
    mouse_added = c.SDL_EVENT_MOUSE_ADDED,
    mouse_removed = c.SDL_EVENT_MOUSE_REMOVED,
    joystick_axis_motion = c.SDL_EVENT_JOYSTICK_AXIS_MOTION,
    joystick_ball_motion = c.SDL_EVENT_JOYSTICK_BALL_MOTION,
    joystick_hat_motion = c.SDL_EVENT_JOYSTICK_HAT_MOTION,
    joystick_button_down = c.SDL_EVENT_JOYSTICK_BUTTON_DOWN,
    joystick_button_up = c.SDL_EVENT_JOYSTICK_BUTTON_UP,
    joystick_added = c.SDL_EVENT_JOYSTICK_ADDED,
    joystick_removed = c.SDL_EVENT_JOYSTICK_REMOVED,
    joystick_battery_updated = c.SDL_EVENT_JOYSTICK_BATTERY_UPDATED,
    joystick_update_complete = c.SDL_EVENT_JOYSTICK_UPDATE_COMPLETE,
    gamepad_axis_motion = c.SDL_EVENT_GAMEPAD_AXIS_MOTION,
    gamepad_button_down = c.SDL_EVENT_GAMEPAD_BUTTON_DOWN,
    gamepad_button_up = c.SDL_EVENT_GAMEPAD_BUTTON_UP,
    gamepad_added = c.SDL_EVENT_GAMEPAD_ADDED,
    gamepad_removed = c.SDL_EVENT_GAMEPAD_REMOVED,
    gamepad_remapped = c.SDL_EVENT_GAMEPAD_REMAPPED,
    gamepad_touchpad_down = c.SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN,
    gamepad_touchpad_motion = c.SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION,
    gamepad_touchpad_up = c.SDL_EVENT_GAMEPAD_TOUCHPAD_UP,
    gamepad_sensor_update = c.SDL_EVENT_GAMEPAD_SENSOR_UPDATE,
    gamepad_update_complete = c.SDL_EVENT_GAMEPAD_UPDATE_COMPLETE,
    gamepad_steam_handle_updated = c.SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED,
    finger_down = c.SDL_EVENT_FINGER_DOWN,
    finger_up = c.SDL_EVENT_FINGER_UP,
    finger_motion = c.SDL_EVENT_FINGER_MOTION,
    finger_canceled = c.SDL_EVENT_FINGER_CANCELED,
    clipboard_update = c.SDL_EVENT_CLIPBOARD_UPDATE,
    drop_file = c.SDL_EVENT_DROP_FILE,
    drop_text = c.SDL_EVENT_DROP_TEXT,
    drop_begin = c.SDL_EVENT_DROP_BEGIN,
    drop_complete = c.SDL_EVENT_DROP_COMPLETE,
    drop_position = c.SDL_EVENT_DROP_POSITION,
    audio_device_added = c.SDL_EVENT_AUDIO_DEVICE_ADDED,
    audio_device_removed = c.SDL_EVENT_AUDIO_DEVICE_REMOVED,
    audio_device_format_changed = c.SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED,
    sensor_update = c.SDL_EVENT_SENSOR_UPDATE,
    pen_proximity_in = c.SDL_EVENT_PEN_PROXIMITY_IN,
    pen_proximity_out = c.SDL_EVENT_PEN_PROXIMITY_OUT,
    pen_down = c.SDL_EVENT_PEN_DOWN,
    pen_up = c.SDL_EVENT_PEN_UP,
    pen_button_down = c.SDL_EVENT_PEN_BUTTON_DOWN,
    pen_button_up = c.SDL_EVENT_PEN_BUTTON_UP,
    pen_motion = c.SDL_EVENT_PEN_MOTION,
    pen_axis = c.SDL_EVENT_PEN_AXIS,
    camera_device_added = c.SDL_EVENT_CAMERA_DEVICE_ADDED,
    camera_device_removed = c.SDL_EVENT_CAMERA_DEVICE_REMOVED,
    camera_device_approved = c.SDL_EVENT_CAMERA_DEVICE_APPROVED,
    camera_device_denied = c.SDL_EVENT_CAMERA_DEVICE_DENIED,
    render_targets_reset = c.SDL_EVENT_RENDER_TARGETS_RESET,
    render_device_reset = c.SDL_EVENT_RENDER_DEVICE_RESET,
    render_device_lost = c.SDL_EVENT_RENDER_DEVICE_LOST,
    private0 = c.SDL_EVENT_PRIVATE0,
    private1 = c.SDL_EVENT_PRIVATE1,
    private2 = c.SDL_EVENT_PRIVATE2,
    private3 = c.SDL_EVENT_PRIVATE3,
    poll_sentinel = c.SDL_EVENT_POLL_SENTINEL,
    user = c.SDL_EVENT_USER,
    last = c.SDL_EVENT_LAST,
    enum_padding = c.SDL_EVENT_ENUM_PADDING,
    _,
};

pub const CommonEvent = struct {
    timestamp: u64,
};

pub const QuitEvent = struct {
    timestamp: u64,
};

pub const DisplayOrientationEvent = struct {
    timestamp: u64,
    displayID: DisplayID,
    orientation: i32,
};

pub const DisplayEvent = struct {
    timestamp: u64,
    displayID: DisplayID,
};

pub const WindowEvent = struct {
    timestamp: u64,
    windowID: WindowID,
};

pub const WindowPositionEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    position: Point,
};

pub const WindowSizeEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    size: Size,
};

pub const WindowDisplayEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    displayID: i32,
};

pub const KeyboardDeviceEvent = struct {
    timestamp: u64,
    which: KeyboardID,
};

pub const KeyboardEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: KeyboardID,
    scancode: c.SDL_Scancode,
    keycode: c.SDL_Keycode,
    mod: c.SDL_Keymod,
    repeat: bool,
};

pub const TextEditingEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    text: [*:0]const u8,
    start: i32,
    length: i32,
};

pub const TextEditingCandidatesEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    candidates: []const [*:0]const u8,
    selected_candidate: i32,
    horizontal: bool,
};

pub const TextInputEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    text: [*:0]const u8,
};

pub const MouseDeviceEvent = struct {
    timestamp: u64,
    which: MouseID,
};

pub const MouseMotionEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: MouseID,
    state: c.SDL_MouseButtonFlags,
    x: f32,
    y: f32,
    xrel: f32,
    yrel: f32,
};

pub const MouseButtonEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: MouseID,
    button: u8,
    clicks: u8,
    x: f32,
    y: f32,
};

pub const MouseWheelEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: MouseID,
    x: f32,
    y: f32,
    direction: c.SDL_MouseWheelDirection,
    mouse_x: f32,
    mouse_y: f32,
};

pub const JoystickDeviceEvent = struct {
    timestamp: u64,
    which: JoystickID,
};

pub const JoystickAxisEvent = struct {
    timestamp: u64,
    which: JoystickID,
    axis: u8,
    value: i16,
};

pub const JoystickBallEvent = struct {
    timestamp: u64,
    which: JoystickID,
    ball: u8,
    xrel: i16,
    yrel: i16,
};

pub const JoystickHatEvent = struct {
    timestamp: u64,
    which: JoystickID,
    hat: u8,
    value: u8,
};

pub const JoystickButtonEvent = struct {
    timestamp: u64,
    which: JoystickID,
    button: u8,
};

pub const JoystickBatteryEvent = struct {
    timestamp: u64,
    which: JoystickID,
    state: c.SDL_PowerState,
    percent: i32,
};

pub const GamepadDeviceEvent = struct {
    timestamp: u64,
    which: JoystickID,
};

pub const GamepadAxisEvent = struct {
    timestamp: u64,
    which: JoystickID,
    axis: u8,
    value: i16,
};

pub const GamepadButtonEvent = struct {
    timestamp: u64,
    which: JoystickID,
    button: u8,
};

pub const GamepadTouchpadEvent = struct {
    timestamp: u64,
    which: JoystickID,
    touchpad: i32,
    finger: i32,
    x: f32,
    y: f32,
    pressure: f32,
};

pub const GamepadSensorEvent = struct {
    timestamp: u64,
    which: JoystickID,
    sensor: i32,
    data: [3]f32,
    sensor_timestamp: u64,
};

pub const TouchFingerEvent = struct {
    timestamp: u64,
    touchID: TouchID,
    fingerID: FingerID,
    x: f32,
    y: f32,
    dx: f32,
    dy: f32,
    pressure: f32,
    windowID: WindowID,
};

pub const TouchEvent = struct {
    timestamp: u64,
    windowID: WindowID,
};

pub const ClipboardEvent = struct {
    timestamp: u64,
    owner: bool,
    mime_types: []const [*:0]const u8,
};

pub const DropFileEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    file: [*:0]const u8,
};

pub const DropTextEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    text: [*:0]const u8,
};

pub const DropEvent = struct {
    timestamp: u64,
    windowID: WindowID,
};

pub const DropPositionEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    x: f32,
    y: f32,
};

pub const AudioDeviceEvent = struct {
    timestamp: u64,
    which: AudioDeviceID,
    recording: bool,
};

pub const SensorEvent = struct {
    timestamp: u64,
    which: SensorID,
    data: [6]f32,
    sensor_timestamp: u64,
};

pub const PenProximityEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: PenID,
};

pub const PenTouchEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: PenID,
    pen_state: c.SDL_PenInputFlags,
    x: f32,
    y: f32,
    eraser: bool,
};

pub const PenMotionEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: PenID,
    pen_state: c.SDL_PenInputFlags,
    x: f32,
    y: f32,
};

pub const PenButtonEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: PenID,
    pen_state: c.SDL_PenInputFlags,
    x: f32,
    y: f32,
    button: u8,
};

pub const PenAxisEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    which: PenID,
    pen_state: c.SDL_PenInputFlags,
    x: f32,
    y: f32,
    axis: c.SDL_PenAxis,
    value: f32,
};

pub const CameraDeviceEvent = struct {
    timestamp: u64,
    which: CameraID,
};

pub const RenderEvent = struct {
    timestamp: u64,
    windowID: WindowID,
};

pub const UserEvent = struct {
    timestamp: u64,
    windowID: WindowID,
    code: i32,
    data1: ?*anyopaque,
    data2: ?*anyopaque,
};

pub const EventAction = enum(u32) {
    addevent = c.SDL_ADDEVENT,
    peekevent = c.SDL_PEEKEVENT,
    getevent = c.SDL_GETEVENT,
};

pub const Event = union(EventType) {
    first: CommonEvent,
    quit: QuitEvent,
    terminating: QuitEvent,
    low_memory: QuitEvent,
    will_enter_background: QuitEvent,
    did_enter_background: QuitEvent,
    will_enter_foreground: QuitEvent,
    did_enter_foreground: QuitEvent,
    locale_changed: QuitEvent,
    system_theme_changed: QuitEvent,
    display_orientation: DisplayOrientationEvent,
    display_added: DisplayEvent,
    display_removed: DisplayEvent,
    display_moved: DisplayEvent,
    display_desktop_mode_changed: DisplayEvent,
    display_current_mode_changed: DisplayEvent,
    display_content_scale_changed: DisplayEvent,
    window_shown: WindowEvent,
    window_hidden: WindowEvent,
    window_exposed: WindowEvent,
    window_moved: WindowPositionEvent,
    window_resized: WindowSizeEvent,
    window_pixel_size_changed: WindowSizeEvent,
    window_metal_view_resized: WindowEvent,
    window_minimized: WindowEvent,
    window_maximized: WindowEvent,
    window_restored: WindowEvent,
    window_mouse_enter: WindowEvent,
    window_mouse_leave: WindowEvent,
    window_focus_gained: WindowEvent,
    window_focus_lost: WindowEvent,
    window_close_requested: WindowEvent,
    window_hit_test: WindowEvent,
    window_iccprof_changed: WindowEvent,
    window_display_changed: WindowDisplayEvent,
    window_display_scale_changed: WindowEvent,
    window_safe_area_changed: WindowEvent,
    window_occluded: WindowEvent,
    window_enter_fullscreen: WindowEvent,
    window_leave_fullscreen: WindowEvent,
    window_destroyed: WindowEvent,
    window_hdr_state_changed: WindowEvent,
    key_down: KeyboardEvent,
    key_up: KeyboardEvent,
    text_editing: TextEditingEvent,
    text_input: TextInputEvent,
    keymap_changed: CommonEvent,
    keyboard_added: KeyboardDeviceEvent,
    keyboard_removed: KeyboardDeviceEvent,
    text_editing_candidates: TextEditingCandidatesEvent,
    mouse_motion: MouseMotionEvent,
    mouse_button_down: MouseButtonEvent,
    mouse_button_up: MouseButtonEvent,
    mouse_wheel: MouseWheelEvent,
    mouse_added: MouseDeviceEvent,
    mouse_removed: MouseDeviceEvent,
    joystick_axis_motion: JoystickAxisEvent,
    joystick_ball_motion: JoystickBallEvent,
    joystick_hat_motion: JoystickHatEvent,
    joystick_button_down: JoystickButtonEvent,
    joystick_button_up: JoystickButtonEvent,
    joystick_added: JoystickDeviceEvent,
    joystick_removed: JoystickDeviceEvent,
    joystick_battery_updated: JoystickBatteryEvent,
    joystick_update_complete: JoystickDeviceEvent,
    gamepad_axis_motion: GamepadAxisEvent,
    gamepad_button_down: GamepadButtonEvent,
    gamepad_button_up: GamepadButtonEvent,
    gamepad_added: GamepadDeviceEvent,
    gamepad_removed: GamepadDeviceEvent,
    gamepad_remapped: GamepadDeviceEvent,
    gamepad_touchpad_down: GamepadTouchpadEvent,
    gamepad_touchpad_motion: GamepadTouchpadEvent,
    gamepad_touchpad_up: GamepadTouchpadEvent,
    gamepad_sensor_update: GamepadSensorEvent,
    gamepad_update_complete: GamepadDeviceEvent,
    gamepad_steam_handle_updated: GamepadDeviceEvent,
    finger_down: TouchFingerEvent,
    finger_up: TouchFingerEvent,
    finger_motion: TouchFingerEvent,
    finger_canceled: TouchEvent,
    clipboard_update: ClipboardEvent,
    drop_file: DropFileEvent,
    drop_text: DropTextEvent,
    drop_begin: DropEvent,
    drop_complete: DropEvent,
    drop_position: DropPositionEvent,
    audio_device_added: AudioDeviceEvent,
    audio_device_removed: AudioDeviceEvent,
    audio_device_format_changed: AudioDeviceEvent,
    sensor_update: SensorEvent,
    pen_proximity_in: PenProximityEvent,
    pen_proximity_out: PenProximityEvent,
    pen_down: PenTouchEvent,
    pen_up: PenTouchEvent,
    pen_button_down: PenButtonEvent,
    pen_button_up: PenButtonEvent,
    pen_motion: PenMotionEvent,
    pen_axis: PenAxisEvent,
    camera_device_added: CameraDeviceEvent,
    camera_device_removed: CameraDeviceEvent,
    camera_device_approved: CameraDeviceEvent,
    camera_device_denied: CameraDeviceEvent,
    render_targets_reset: RenderEvent,
    render_device_reset: RenderEvent,
    render_device_lost: RenderEvent,
    private0: CommonEvent,
    private1: CommonEvent,
    private2: CommonEvent,
    private3: CommonEvent,
    poll_sentinel: CommonEvent,
    user: UserEvent,
    last: CommonEvent,
    enum_padding: CommonEvent,

    pub inline fn fromNative(sdl_event: c.SDL_Event) Event {
        return switch (sdl_event.type) {
            c.SDL_EVENT_FIRST => .{ .first = .{ .timestamp = sdl_event.common.timestamp } },
            c.SDL_EVENT_QUIT => .{ .quit = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_TERMINATING => .{ .terminating = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_LOW_MEMORY => .{ .low_memory = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_WILL_ENTER_BACKGROUND => .{ .will_enter_background = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_DID_ENTER_BACKGROUND => .{ .did_enter_background = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_WILL_ENTER_FOREGROUND => .{ .will_enter_foreground = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_DID_ENTER_FOREGROUND => .{ .did_enter_foreground = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_LOCALE_CHANGED => .{ .locale_changed = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_SYSTEM_THEME_CHANGED => .{ .system_theme_changed = .{ .timestamp = sdl_event.quit.timestamp } },
            c.SDL_EVENT_DISPLAY_ORIENTATION => .{ .display_orientation = .{
                .timestamp = sdl_event.display.timestamp,
                .displayID = sdl_event.display.displayID,
                .orientation = sdl_event.display.data1,
            } },
            c.SDL_EVENT_DISPLAY_ADDED => .{ .display_added = .{
                .timestamp = sdl_event.display.timestamp,
                .displayID = sdl_event.display.displayID,
            } },
            c.SDL_EVENT_DISPLAY_REMOVED => .{ .display_removed = .{
                .timestamp = sdl_event.display.timestamp,
                .displayID = sdl_event.display.displayID,
            } },
            c.SDL_EVENT_DISPLAY_MOVED => .{ .display_moved = .{
                .timestamp = sdl_event.display.timestamp,
                .displayID = sdl_event.display.displayID,
            } },
            c.SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED => .{ .display_desktop_mode_changed = .{
                .timestamp = sdl_event.display.timestamp,
                .displayID = sdl_event.display.displayID,
            } },
            c.SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED => .{ .display_current_mode_changed = .{
                .timestamp = sdl_event.display.timestamp,
                .displayID = sdl_event.display.displayID,
            } },
            c.SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED => .{ .display_content_scale_changed = .{
                .timestamp = sdl_event.display.timestamp,
                .displayID = sdl_event.display.displayID,
            } },
            c.SDL_EVENT_WINDOW_SHOWN => .{ .window_shown = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_HIDDEN => .{ .window_hidden = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_EXPOSED => .{ .window_exposed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_MOVED => .{ .window_moved = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
                .position = .{ .x = sdl_event.window.data1, .y = sdl_event.window.data2 },
            } },
            c.SDL_EVENT_WINDOW_RESIZED => .{ .window_resized = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
                .size = .{ .width = sdl_event.window.data1, .height = sdl_event.window.data2 },
            } },
            c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED => .{ .window_pixel_size_changed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
                .size = .{ .width = sdl_event.window.data1, .height = sdl_event.window.data2 },
            } },
            c.SDL_EVENT_WINDOW_METAL_VIEW_RESIZED => .{ .window_metal_view_resized = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_MINIMIZED => .{ .window_minimized = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_MAXIMIZED => .{ .window_maximized = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_RESTORED => .{ .window_restored = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_MOUSE_ENTER => .{ .window_mouse_enter = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_MOUSE_LEAVE => .{ .window_mouse_leave = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_FOCUS_GAINED => .{ .window_focus_gained = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_FOCUS_LOST => .{ .window_focus_lost = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_CLOSE_REQUESTED => .{ .window_close_requested = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_HIT_TEST => .{ .window_hit_test = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_ICCPROF_CHANGED => .{ .window_iccprof_changed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_DISPLAY_CHANGED => .{ .window_display_changed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
                .displayID = sdl_event.window.data1,
            } },
            c.SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED => .{ .window_display_scale_changed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_SAFE_AREA_CHANGED => .{ .window_safe_area_changed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_OCCLUDED => .{ .window_occluded = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_ENTER_FULLSCREEN => .{ .window_enter_fullscreen = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_LEAVE_FULLSCREEN => .{ .window_leave_fullscreen = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_DESTROYED => .{ .window_destroyed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_WINDOW_HDR_STATE_CHANGED => .{ .window_hdr_state_changed = .{
                .timestamp = sdl_event.window.timestamp,
                .windowID = sdl_event.window.windowID,
            } },
            c.SDL_EVENT_KEYBOARD_ADDED => .{ .keyboard_added = .{
                .timestamp = sdl_event.kdevice.timestamp,
                .which = sdl_event.kdevice.which,
            } },
            c.SDL_EVENT_KEYBOARD_REMOVED => .{ .keyboard_removed = .{
                .timestamp = sdl_event.kdevice.timestamp,
                .which = sdl_event.kdevice.which,
            } },
            c.SDL_EVENT_KEY_DOWN => .{ .key_down = .{
                .timestamp = sdl_event.key.timestamp,
                .windowID = sdl_event.key.windowID,
                .which = sdl_event.key.which,
                .scancode = sdl_event.key.scancode,
                .keycode = sdl_event.key.key,
                .mod = sdl_event.key.mod,
                .repeat = sdl_event.key.repeat,
            } },
            c.SDL_EVENT_KEY_UP => .{ .key_up = .{
                .timestamp = sdl_event.key.timestamp,
                .windowID = sdl_event.key.windowID,
                .which = sdl_event.key.which,
                .scancode = sdl_event.key.scancode,
                .keycode = sdl_event.key.key,
                .mod = sdl_event.key.mod,
                .repeat = sdl_event.key.repeat,
            } },
            c.SDL_EVENT_TEXT_EDITING => .{ .text_editing = .{
                .timestamp = sdl_event.edit.timestamp,
                .windowID = sdl_event.edit.windowID,
                .text = std.mem.span(sdl_event.edit.text),
                .start = sdl_event.edit.start,
                .length = sdl_event.edit.length,
            } },
            c.SDL_EVENT_TEXT_INPUT => .{ .text_input = .{
                .timestamp = sdl_event.text.timestamp,
                .windowID = sdl_event.text.windowID,
                .text = std.mem.span(sdl_event.text.text),
            } },
            c.SDL_EVENT_KEYMAP_CHANGED => .{ .keymap_changed = .{
                .timestamp = sdl_event.common.timestamp,
            } },
            c.SDL_EVENT_TEXT_EDITING_CANDIDATES => .{ .text_editing_candidates = .{
                .timestamp = sdl_event.edit_candidates.timestamp,
                .windowID = sdl_event.edit_candidates.windowID,
                .candidates = @as([*]const [*:0]const u8, @ptrCast(sdl_event.edit_candidates.candidates))[0..@intCast(sdl_event.edit_candidates.num_candidates)],
                .selected_candidate = sdl_event.edit_candidates.selected_candidate,
                .horizontal = sdl_event.edit_candidates.horizontal,
            } },
            c.SDL_EVENT_MOUSE_MOTION => .{ .mouse_motion = .{
                .timestamp = sdl_event.motion.timestamp,
                .windowID = sdl_event.motion.windowID,
                .which = sdl_event.motion.which,
                .state = sdl_event.motion.state,
                .x = sdl_event.motion.x,
                .y = sdl_event.motion.y,
                .xrel = sdl_event.motion.xrel,
                .yrel = sdl_event.motion.yrel,
            } },
            c.SDL_EVENT_MOUSE_BUTTON_DOWN => .{ .mouse_button_down = .{
                .timestamp = sdl_event.button.timestamp,
                .windowID = sdl_event.button.windowID,
                .which = sdl_event.button.which,
                .button = sdl_event.button.button,
                .clicks = sdl_event.button.clicks,
                .x = sdl_event.button.x,
                .y = sdl_event.button.y,
            } },
            c.SDL_EVENT_MOUSE_BUTTON_UP => .{ .mouse_button_up = .{
                .timestamp = sdl_event.button.timestamp,
                .windowID = sdl_event.button.windowID,
                .which = sdl_event.button.which,
                .button = sdl_event.button.button,
                .clicks = sdl_event.button.clicks,
                .x = sdl_event.button.x,
                .y = sdl_event.button.y,
            } },
            c.SDL_EVENT_MOUSE_WHEEL => .{ .mouse_wheel = .{
                .timestamp = sdl_event.wheel.timestamp,
                .windowID = sdl_event.wheel.windowID,
                .which = sdl_event.wheel.which,
                .x = sdl_event.wheel.x,
                .y = sdl_event.wheel.y,
                .direction = sdl_event.wheel.direction,
                .mouse_x = sdl_event.wheel.mouse_x,
                .mouse_y = sdl_event.wheel.mouse_y,
            } },
            c.SDL_EVENT_MOUSE_ADDED => .{ .mouse_added = .{
                .timestamp = sdl_event.mdevice.timestamp,
                .which = sdl_event.mdevice.which,
            } },
            c.SDL_EVENT_MOUSE_REMOVED => .{ .mouse_removed = .{
                .timestamp = sdl_event.mdevice.timestamp,
                .which = sdl_event.mdevice.which,
            } },
            c.SDL_EVENT_JOYSTICK_AXIS_MOTION => .{ .joystick_axis_motion = .{
                .timestamp = sdl_event.jaxis.timestamp,
                .which = sdl_event.jaxis.which,
                .axis = sdl_event.jaxis.axis,
                .value = sdl_event.jaxis.value,
            } },
            c.SDL_EVENT_JOYSTICK_BALL_MOTION => .{ .joystick_ball_motion = .{
                .timestamp = sdl_event.jball.timestamp,
                .which = sdl_event.jball.which,
                .ball = sdl_event.jball.ball,
                .xrel = sdl_event.jball.xrel,
                .yrel = sdl_event.jball.yrel,
            } },
            c.SDL_EVENT_JOYSTICK_HAT_MOTION => .{ .joystick_hat_motion = .{
                .timestamp = sdl_event.jhat.timestamp,
                .which = sdl_event.jhat.which,
                .hat = sdl_event.jhat.hat,
                .value = sdl_event.jhat.value,
            } },
            c.SDL_EVENT_JOYSTICK_BUTTON_DOWN => .{ .joystick_button_down = .{
                .timestamp = sdl_event.jbutton.timestamp,
                .which = sdl_event.jbutton.which,
                .button = sdl_event.jbutton.button,
            } },
            c.SDL_EVENT_JOYSTICK_BUTTON_UP => .{ .joystick_button_up = .{
                .timestamp = sdl_event.jbutton.timestamp,
                .which = sdl_event.jbutton.which,
                .button = sdl_event.jbutton.button,
            } },
            c.SDL_EVENT_JOYSTICK_ADDED => .{ .joystick_added = .{
                .timestamp = sdl_event.jdevice.timestamp,
                .which = sdl_event.jdevice.which,
            } },
            c.SDL_EVENT_JOYSTICK_REMOVED => .{ .joystick_removed = .{
                .timestamp = sdl_event.jdevice.timestamp,
                .which = sdl_event.jdevice.which,
            } },
            c.SDL_EVENT_JOYSTICK_BATTERY_UPDATED => .{ .joystick_battery_updated = .{
                .timestamp = sdl_event.jbattery.timestamp,
                .which = sdl_event.jbattery.which,
                .state = sdl_event.jbattery.state,
                .percent = sdl_event.jbattery.percent,
            } },
            c.SDL_EVENT_JOYSTICK_UPDATE_COMPLETE => .{ .joystick_update_complete = .{
                .timestamp = sdl_event.jdevice.timestamp,
                .which = sdl_event.jdevice.which,
            } },
            c.SDL_EVENT_GAMEPAD_AXIS_MOTION => .{ .gamepad_axis_motion = .{
                .timestamp = sdl_event.gaxis.timestamp,
                .which = sdl_event.gaxis.which,
                .axis = sdl_event.gaxis.axis,
                .value = sdl_event.gaxis.value,
            } },
            c.SDL_EVENT_GAMEPAD_BUTTON_DOWN => .{ .gamepad_button_down = .{
                .timestamp = sdl_event.gbutton.timestamp,
                .which = sdl_event.gbutton.which,
                .button = sdl_event.gbutton.button,
            } },
            c.SDL_EVENT_GAMEPAD_BUTTON_UP => .{ .gamepad_button_up = .{
                .timestamp = sdl_event.gbutton.timestamp,
                .which = sdl_event.gbutton.which,
                .button = sdl_event.gbutton.button,
            } },
            c.SDL_EVENT_GAMEPAD_ADDED => .{ .gamepad_added = .{
                .timestamp = sdl_event.gdevice.timestamp,
                .which = sdl_event.gdevice.which,
            } },
            c.SDL_EVENT_GAMEPAD_REMOVED => .{ .gamepad_removed = .{
                .timestamp = sdl_event.gdevice.timestamp,
                .which = sdl_event.gdevice.which,
            } },
            c.SDL_EVENT_GAMEPAD_REMAPPED => .{ .gamepad_remapped = .{
                .timestamp = sdl_event.gdevice.timestamp,
                .which = sdl_event.gdevice.which,
            } },
            c.SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN => .{ .gamepad_touchpad_down = .{
                .timestamp = sdl_event.gtouchpad.timestamp,
                .which = sdl_event.gtouchpad.which,
                .touchpad = sdl_event.gtouchpad.touchpad,
                .finger = sdl_event.gtouchpad.finger,
                .x = sdl_event.gtouchpad.x,
                .y = sdl_event.gtouchpad.y,
                .pressure = sdl_event.gtouchpad.pressure,
            } },
            c.SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION => .{ .gamepad_touchpad_motion = .{
                .timestamp = sdl_event.gtouchpad.timestamp,
                .which = sdl_event.gtouchpad.which,
                .touchpad = sdl_event.gtouchpad.touchpad,
                .finger = sdl_event.gtouchpad.finger,
                .x = sdl_event.gtouchpad.x,
                .y = sdl_event.gtouchpad.y,
                .pressure = sdl_event.gtouchpad.pressure,
            } },
            c.SDL_EVENT_GAMEPAD_TOUCHPAD_UP => .{ .gamepad_touchpad_up = .{
                .timestamp = sdl_event.gtouchpad.timestamp,
                .which = sdl_event.gtouchpad.which,
                .touchpad = sdl_event.gtouchpad.touchpad,
                .finger = sdl_event.gtouchpad.finger,
                .x = sdl_event.gtouchpad.x,
                .y = sdl_event.gtouchpad.y,
                .pressure = sdl_event.gtouchpad.pressure,
            } },
            c.SDL_EVENT_GAMEPAD_SENSOR_UPDATE => .{ .gamepad_sensor_update = .{
                .timestamp = sdl_event.gsensor.timestamp,
                .which = sdl_event.gsensor.which,
                .sensor = sdl_event.gsensor.sensor,
                .data = sdl_event.gsensor.data,
                .sensor_timestamp = sdl_event.gsensor.sensor_timestamp,
            } },
            c.SDL_EVENT_GAMEPAD_UPDATE_COMPLETE => .{ .gamepad_update_complete = .{
                .timestamp = sdl_event.gdevice.timestamp,
                .which = sdl_event.gdevice.which,
            } },
            c.SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED => .{ .gamepad_steam_handle_updated = .{
                .timestamp = sdl_event.gdevice.timestamp,
                .which = sdl_event.gdevice.which,
            } },
            c.SDL_EVENT_FINGER_DOWN => .{ .finger_down = .{
                .timestamp = sdl_event.tfinger.timestamp,
                .touchID = sdl_event.tfinger.touchID,
                .fingerID = sdl_event.tfinger.fingerID,
                .x = sdl_event.tfinger.x,
                .y = sdl_event.tfinger.y,
                .dx = sdl_event.tfinger.dx,
                .dy = sdl_event.tfinger.dy,
                .pressure = sdl_event.tfinger.pressure,
                .windowID = sdl_event.tfinger.windowID,
            } },
            c.SDL_EVENT_FINGER_UP => .{ .finger_up = .{
                .timestamp = sdl_event.tfinger.timestamp,
                .touchID = sdl_event.tfinger.touchID,
                .fingerID = sdl_event.tfinger.fingerID,
                .x = sdl_event.tfinger.x,
                .y = sdl_event.tfinger.y,
                .dx = sdl_event.tfinger.dx,
                .dy = sdl_event.tfinger.dy,
                .pressure = sdl_event.tfinger.pressure,
                .windowID = sdl_event.tfinger.windowID,
            } },
            c.SDL_EVENT_FINGER_MOTION => .{ .finger_motion = .{
                .timestamp = sdl_event.tfinger.timestamp,
                .touchID = sdl_event.tfinger.touchID,
                .fingerID = sdl_event.tfinger.fingerID,
                .x = sdl_event.tfinger.x,
                .y = sdl_event.tfinger.y,
                .dx = sdl_event.tfinger.dx,
                .dy = sdl_event.tfinger.dy,
                .pressure = sdl_event.tfinger.pressure,
                .windowID = sdl_event.tfinger.windowID,
            } },
            c.SDL_EVENT_FINGER_CANCELED => .{ .finger_canceled = .{
                .timestamp = sdl_event.tfinger.timestamp,
                .windowID = sdl_event.tfinger.windowID,
            } },
            c.SDL_EVENT_CLIPBOARD_UPDATE => .{ .clipboard_update = .{
                .timestamp = sdl_event.clipboard.timestamp,
                .owner = sdl_event.clipboard.owner,
                .mime_types = @as([*]const [*:0]const u8, @ptrCast(sdl_event.clipboard.mime_types))[0..@intCast(sdl_event.clipboard.num_mime_types)],
            } },
            c.SDL_EVENT_DROP_FILE => .{ .drop_file = .{
                .timestamp = sdl_event.drop.timestamp,
                .windowID = sdl_event.drop.windowID,
                .file = std.mem.span(sdl_event.drop.data),
            } },
            c.SDL_EVENT_DROP_TEXT => .{ .drop_text = .{
                .timestamp = sdl_event.drop.timestamp,
                .windowID = sdl_event.drop.windowID,
                .text = std.mem.span(sdl_event.drop.data),
            } },
            c.SDL_EVENT_DROP_BEGIN => .{ .drop_begin = .{
                .timestamp = sdl_event.drop.timestamp,
                .windowID = sdl_event.drop.windowID,
            } },
            c.SDL_EVENT_DROP_COMPLETE => .{ .drop_complete = .{
                .timestamp = sdl_event.drop.timestamp,
                .windowID = sdl_event.drop.windowID,
            } },
            c.SDL_EVENT_DROP_POSITION => .{ .drop_position = .{
                .timestamp = sdl_event.drop.timestamp,
                .windowID = sdl_event.drop.windowID,
                .x = sdl_event.drop.x,
                .y = sdl_event.drop.y,
            } },
            c.SDL_EVENT_AUDIO_DEVICE_ADDED => .{ .audio_device_added = .{
                .timestamp = sdl_event.adevice.timestamp,
                .which = sdl_event.adevice.which,
                .recording = sdl_event.adevice.recording,
            } },
            c.SDL_EVENT_AUDIO_DEVICE_REMOVED => .{ .audio_device_removed = .{
                .timestamp = sdl_event.adevice.timestamp,
                .which = sdl_event.adevice.which,
                .recording = sdl_event.adevice.recording,
            } },
            c.SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED => .{ .audio_device_format_changed = .{
                .timestamp = sdl_event.adevice.timestamp,
                .which = sdl_event.adevice.which,
                .recording = sdl_event.adevice.recording,
            } },
            c.SDL_EVENT_SENSOR_UPDATE => .{ .sensor_update = .{
                .timestamp = sdl_event.sensor.timestamp,
                .which = sdl_event.sensor.which,
                .data = sdl_event.sensor.data,
                .sensor_timestamp = sdl_event.sensor.sensor_timestamp,
            } },
            c.SDL_EVENT_PEN_PROXIMITY_IN => .{ .pen_proximity_in = .{
                .timestamp = sdl_event.pproximity.timestamp,
                .windowID = sdl_event.pproximity.windowID,
                .which = sdl_event.pproximity.which,
            } },
            c.SDL_EVENT_PEN_PROXIMITY_OUT => .{ .pen_proximity_out = .{
                .timestamp = sdl_event.pproximity.timestamp,
                .windowID = sdl_event.pproximity.windowID,
                .which = sdl_event.pproximity.which,
            } },
            c.SDL_EVENT_PEN_DOWN => .{ .pen_down = .{
                .timestamp = sdl_event.ptouch.timestamp,
                .windowID = sdl_event.ptouch.windowID,
                .which = sdl_event.ptouch.which,
                .pen_state = sdl_event.ptouch.pen_state,
                .x = sdl_event.ptouch.x,
                .y = sdl_event.ptouch.y,
                .eraser = sdl_event.ptouch.eraser,
            } },
            c.SDL_EVENT_PEN_UP => .{ .pen_up = .{
                .timestamp = sdl_event.ptouch.timestamp,
                .windowID = sdl_event.ptouch.windowID,
                .which = sdl_event.ptouch.which,
                .pen_state = sdl_event.ptouch.pen_state,
                .x = sdl_event.ptouch.x,
                .y = sdl_event.ptouch.y,
                .eraser = sdl_event.ptouch.eraser,
            } },
            c.SDL_EVENT_PEN_MOTION => .{ .pen_motion = .{
                .timestamp = sdl_event.pmotion.timestamp,
                .windowID = sdl_event.pmotion.windowID,
                .which = sdl_event.pmotion.which,
                .pen_state = sdl_event.pmotion.pen_state,
                .x = sdl_event.pmotion.x,
                .y = sdl_event.pmotion.y,
            } },
            c.SDL_EVENT_PEN_BUTTON_DOWN => .{ .pen_button_down = .{
                .timestamp = sdl_event.pbutton.timestamp,
                .windowID = sdl_event.pbutton.windowID,
                .which = sdl_event.pbutton.which,
                .pen_state = sdl_event.pbutton.pen_state,
                .x = sdl_event.pbutton.x,
                .y = sdl_event.pbutton.y,
                .button = sdl_event.pbutton.button,
            } },
            c.SDL_EVENT_PEN_BUTTON_UP => .{ .pen_button_up = .{
                .timestamp = sdl_event.pbutton.timestamp,
                .windowID = sdl_event.pbutton.windowID,
                .which = sdl_event.pbutton.which,
                .pen_state = sdl_event.pbutton.pen_state,
                .x = sdl_event.pbutton.x,
                .y = sdl_event.pbutton.y,
                .button = sdl_event.pbutton.button,
            } },
            c.SDL_EVENT_PEN_AXIS => .{ .pen_axis = .{
                .timestamp = sdl_event.paxis.timestamp,
                .windowID = sdl_event.paxis.windowID,
                .which = sdl_event.paxis.which,
                .pen_state = sdl_event.paxis.pen_state,
                .x = sdl_event.paxis.x,
                .y = sdl_event.paxis.y,
                .axis = sdl_event.paxis.axis,
                .value = sdl_event.paxis.value,
            } },
            c.SDL_EVENT_CAMERA_DEVICE_ADDED => .{ .camera_device_added = .{
                .timestamp = sdl_event.cdevice.timestamp,
                .which = sdl_event.cdevice.which,
            } },
            c.SDL_EVENT_CAMERA_DEVICE_REMOVED => .{ .camera_device_removed = .{
                .timestamp = sdl_event.cdevice.timestamp,
                .which = sdl_event.cdevice.which,
            } },
            c.SDL_EVENT_CAMERA_DEVICE_APPROVED => .{ .camera_device_approved = .{
                .timestamp = sdl_event.cdevice.timestamp,
                .which = sdl_event.cdevice.which,
            } },
            c.SDL_EVENT_CAMERA_DEVICE_DENIED => .{ .camera_device_denied = .{
                .timestamp = sdl_event.cdevice.timestamp,
                .which = sdl_event.cdevice.which,
            } },

            c.SDL_EVENT_RENDER_TARGETS_RESET => .{ .render_targets_reset = .{
                .timestamp = sdl_event.render.timestamp,
                .windowID = sdl_event.render.windowID,
            } },
            c.SDL_EVENT_RENDER_DEVICE_RESET => .{ .render_device_reset = .{
                .timestamp = sdl_event.render.timestamp,
                .windowID = sdl_event.render.windowID,
            } },
            c.SDL_EVENT_RENDER_DEVICE_LOST => .{ .render_device_lost = .{
                .timestamp = sdl_event.render.timestamp,
                .windowID = sdl_event.render.windowID,
            } },
            c.SDL_EVENT_PRIVATE0 => .{ .private0 = .{ .timestamp = sdl_event.common.timestamp } },
            c.SDL_EVENT_PRIVATE1 => .{ .private1 = .{ .timestamp = sdl_event.common.timestamp } },
            c.SDL_EVENT_PRIVATE2 => .{ .private2 = .{ .timestamp = sdl_event.common.timestamp } },
            c.SDL_EVENT_PRIVATE3 => .{ .private3 = .{ .timestamp = sdl_event.common.timestamp } },
            c.SDL_EVENT_POLL_SENTINEL => .{ .poll_sentinel = .{ .timestamp = sdl_event.common.timestamp } },
            c.SDL_EVENT_USER => .{ .user = .{
                .timestamp = sdl_event.user.timestamp,
                .windowID = sdl_event.user.windowID,
                .code = sdl_event.user.code,
                .data1 = sdl_event.user.data1,
                .data2 = sdl_event.user.data2,
            } },
            c.SDL_EVENT_LAST => .{ .last = .{ .timestamp = sdl_event.common.timestamp } },
            c.SDL_EVENT_ENUM_PADDING => .{ .enum_padding = .{ .timestamp = sdl_event.common.timestamp } },
            else => unreachable,
        };
    }

    pub inline fn toNative(self: *const Event) c.SDL_Event {
        var sdl_event: c.SDL_Event = undefined;

        switch (self) {
            .first => {
                sdl_event.type = c.SDL_EVENT_FIRST;
                sdl_event.common.timestamp = self.first.timestamp;
            },

            .quit => {
                sdl_event.type = c.SDL_EVENT_QUIT;
                sdl_event.quit.timestamp = self.quit.timestamp;
            },
            .terminating => {
                sdl_event.type = c.SDL_EVENT_TERMINATING;
                sdl_event.quit.timestamp = self.terminating.timestamp;
            },
            .low_memory => {
                sdl_event.type = c.SDL_EVENT_LOW_MEMORY;
                sdl_event.quit.timestamp = self.low_memory.timestamp;
            },
            .will_enter_background => {
                sdl_event.type = c.SDL_EVENT_WILL_ENTER_BACKGROUND;
                sdl_event.quit.timestamp = self.will_enter_background.timestamp;
            },
            .did_enter_background => {
                sdl_event.type = c.SDL_EVENT_DID_ENTER_BACKGROUND;
                sdl_event.quit.timestamp = self.did_enter_background.timestamp;
            },
            .will_enter_foreground => {
                sdl_event.type = c.SDL_EVENT_WILL_ENTER_FOREGROUND;
                sdl_event.quit.timestamp = self.will_enter_foreground.timestamp;
            },
            .did_enter_foreground => {
                sdl_event.type = c.SDL_EVENT_DID_ENTER_FOREGROUND;
                sdl_event.quit.timestamp = self.did_enter_foreground.timestamp;
            },
            .locale_changed => {
                sdl_event.type = c.SDL_EVENT_LOCALE_CHANGED;
                sdl_event.quit.timestamp = self.locale_changed.timestamp;
            },
            .system_theme_changed => {
                sdl_event.type = c.SDL_EVENT_SYSTEM_THEME_CHANGED;
                sdl_event.quit.timestamp = self.system_theme_changed.timestamp;
            },

            .display_orientation => {
                sdl_event.type = c.SDL_EVENT_DISPLAY_ORIENTATION;
                sdl_event.display.timestamp = self.display_orientation.timestamp;
                sdl_event.display.displayID = self.display_orientation.displayID;
                sdl_event.display.data1 = self.display_orientation.orientation;
            },
            .display_added => {
                sdl_event.type = c.SDL_EVENT_DISPLAY_ADDED;
                sdl_event.display.timestamp = self.display_added.timestamp;
                sdl_event.display.displayID = self.display_added.displayID;
            },
            .display_removed => {
                sdl_event.type = c.SDL_EVENT_DISPLAY_REMOVED;
                sdl_event.display.timestamp = self.display_removed.timestamp;
                sdl_event.display.displayID = self.display_removed.displayID;
            },
            .display_moved => {
                sdl_event.type = c.SDL_EVENT_DISPLAY_MOVED;
                sdl_event.display.timestamp = self.display_moved.timestamp;
                sdl_event.display.displayID = self.display_moved.displayID;
            },
            .display_desktop_mode_changed => {
                sdl_event.type = c.SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED;
                sdl_event.display.timestamp = self.display_desktop_mode_changed.timestamp;
                sdl_event.display.displayID = self.display_desktop_mode_changed.displayID;
            },
            .display_current_mode_changed => {
                sdl_event.type = c.SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED;
                sdl_event.display.timestamp = self.display_current_mode_changed.timestamp;
                sdl_event.display.displayID = self.display_current_mode_changed.displayID;
            },
            .display_content_scale_changed => {
                sdl_event.type = c.SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED;
                sdl_event.display.timestamp = self.display_content_scale_changed.timestamp;
                sdl_event.display.displayID = self.display_content_scale_changed.displayID;
            },

            .window_shown => {
                sdl_event.type = c.SDL_EVENT_WINDOW_SHOWN;
                sdl_event.window.timestamp = self.window_shown.timestamp;
                sdl_event.window.windowID = self.window_shown.windowID;
            },
            .window_hidden => {
                sdl_event.type = c.SDL_EVENT_WINDOW_HIDDEN;
                sdl_event.window.timestamp = self.window_hidden.timestamp;
                sdl_event.window.windowID = self.window_hidden.windowID;
            },
            .window_exposed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_EXPOSED;
                sdl_event.window.timestamp = self.window_exposed.timestamp;
                sdl_event.window.windowID = self.window_exposed.windowID;
            },
            .window_moved => {
                sdl_event.type = c.SDL_EVENT_WINDOW_MOVED;
                sdl_event.window.timestamp = self.window_moved.timestamp;
                sdl_event.window.windowID = self.window_moved.windowID;
                sdl_event.window.data1 = self.window_moved.position.x;
                sdl_event.window.data2 = self.window_moved.position.y;
            },
            .window_resized => {
                sdl_event.type = c.SDL_EVENT_WINDOW_RESIZED;
                sdl_event.window.timestamp = self.window_resized.timestamp;
                sdl_event.window.windowID = self.window_resized.windowID;
                sdl_event.window.data1 = self.window_resized.size.width;
                sdl_event.window.data2 = self.window_resized.size.height;
            },
            .window_pixel_size_changed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED;
                sdl_event.window.timestamp = self.window_pixel_size_changed.timestamp;
                sdl_event.window.windowID = self.window_pixel_size_changed.windowID;
                sdl_event.window.data1 = self.window_pixel_size_changed.size.width;
                sdl_event.window.data2 = self.window_pixel_size_changed.size.height;
            },
            .window_metal_view_resized => {
                sdl_event.type = c.SDL_EVENT_WINDOW_METAL_VIEW_RESIZED;
                sdl_event.window.timestamp = self.window_metal_view_resized.timestamp;
                sdl_event.window.windowID = self.window_metal_view_resized.windowID;
            },
            .window_minimized => {
                sdl_event.type = c.SDL_EVENT_WINDOW_MINIMIZED;
                sdl_event.window.timestamp = self.window_minimized.timestamp;
                sdl_event.window.windowID = self.window_minimized.windowID;
            },
            .window_maximized => {
                sdl_event.type = c.SDL_EVENT_WINDOW_MAXIMIZED;
                sdl_event.window.timestamp = self.window_maximized.timestamp;
                sdl_event.window.windowID = self.window_maximized.windowID;
            },
            .window_restored => {
                sdl_event.type = c.SDL_EVENT_WINDOW_RESTORED;
                sdl_event.window.timestamp = self.window_restored.timestamp;
                sdl_event.window.windowID = self.window_restored.windowID;
            },
            .window_mouse_enter => {
                sdl_event.type = c.SDL_EVENT_WINDOW_MOUSE_ENTER;
                sdl_event.window.timestamp = self.window_mouse_enter.timestamp;
                sdl_event.window.windowID = self.window_mouse_enter.windowID;
            },
            .window_mouse_leave => {
                sdl_event.type = c.SDL_EVENT_WINDOW_MOUSE_LEAVE;
                sdl_event.window.timestamp = self.window_mouse_leave.timestamp;
                sdl_event.window.windowID = self.window_mouse_leave.windowID;
            },
            .window_focus_gained => {
                sdl_event.type = c.SDL_EVENT_WINDOW_FOCUS_GAINED;
                sdl_event.window.timestamp = self.window_focus_gained.timestamp;
                sdl_event.window.windowID = self.window_focus_gained.windowID;
            },
            .window_focus_lost => {
                sdl_event.type = c.SDL_EVENT_WINDOW_FOCUS_LOST;
                sdl_event.window.timestamp = self.window_focus_lost.timestamp;
                sdl_event.window.windowID = self.window_focus_lost.windowID;
            },
            .window_close_requested => {
                sdl_event.type = c.SDL_EVENT_WINDOW_CLOSE_REQUESTED;
                sdl_event.window.timestamp = self.window_close_requested.timestamp;
                sdl_event.window.windowID = self.window_close_requested.windowID;
            },
            .window_hit_test => {
                sdl_event.type = c.SDL_EVENT_WINDOW_HIT_TEST;
                sdl_event.window.timestamp = self.window_hit_test.timestamp;
                sdl_event.window.windowID = self.window_hit_test.windowID;
            },
            .window_iccprof_changed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_ICCPROF_CHANGED;
                sdl_event.window.timestamp = self.window_iccprof_changed.timestamp;
                sdl_event.window.windowID = self.window_iccprof_changed.windowID;
            },
            .window_display_changed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_DISPLAY_CHANGED;
                sdl_event.window.timestamp = self.window_display_changed.timestamp;
                sdl_event.window.windowID = self.window_display_changed.windowID;
                sdl_event.window.data1 = self.window_display_changed.displayID;
            },
            .window_display_scale_changed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED;
                sdl_event.window.timestamp = self.window_display_scale_changed.timestamp;
                sdl_event.window.windowID = self.window_display_scale_changed.windowID;
            },
            .window_safe_area_changed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_SAFE_AREA_CHANGED;
                sdl_event.window.timestamp = self.window_safe_area_changed.timestamp;
                sdl_event.window.windowID = self.window_safe_area_changed.windowID;
            },
            .window_occluded => {
                sdl_event.type = c.SDL_EVENT_WINDOW_OCCLUDED;
                sdl_event.window.timestamp = self.window_occluded.timestamp;
                sdl_event.window.windowID = self.window_occluded.windowID;
            },
            .window_enter_fullscreen => {
                sdl_event.type = c.SDL_EVENT_WINDOW_ENTER_FULLSCREEN;
                sdl_event.window.timestamp = self.window_enter_fullscreen.timestamp;
                sdl_event.window.windowID = self.window_enter_fullscreen.windowID;
            },
            .window_leave_fullscreen => {
                sdl_event.type = c.SDL_EVENT_WINDOW_LEAVE_FULLSCREEN;
                sdl_event.window.timestamp = self.window_leave_fullscreen.timestamp;
                sdl_event.window.windowID = self.window_leave_fullscreen.windowID;
            },
            .window_destroyed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_DESTROYED;
                sdl_event.window.timestamp = self.window_destroyed.timestamp;
                sdl_event.window.windowID = self.window_destroyed.windowID;
            },
            .window_hdr_state_changed => {
                sdl_event.type = c.SDL_EVENT_WINDOW_HDR_STATE_CHANGED;
                sdl_event.window.timestamp = self.window_hdr_state_changed.timestamp;
                sdl_event.window.windowID = self.window_hdr_state_changed.windowID;
            },

            .keymap_changed => {
                sdl_event.type = c.SDL_EVENT_KEYMAP_CHANGED;
                sdl_event.common.timestamp = self.keymap_changed.timestamp;
            },
            .keyboard_added => {
                sdl_event.type = c.SDL_EVENT_KEYBOARD_ADDED;
                sdl_event.kdevice.timestamp = self.keyboard_added.timestamp;
                sdl_event.kdevice.which = self.keyboard_added.which;
            },
            .keyboard_removed => {
                sdl_event.type = c.SDL_EVENT_KEYBOARD_REMOVED;
                sdl_event.kdevice.timestamp = self.keyboard_removed.timestamp;
                sdl_event.kdevice.which = self.keyboard_removed.which;
            },
            .key_down => {
                sdl_event.type = c.SDL_EVENT_KEY_DOWN;
                sdl_event.key.timestamp = self.key_down.timestamp;
                sdl_event.key.windowID = self.key_down.windowID;
                sdl_event.key.which = self.key_down.which;
                sdl_event.key.scancode = self.key_down.scancode;
                sdl_event.key.key = self.key_down.keycode;
                sdl_event.key.mod = self.key_down.mod;
                sdl_event.key.repeat = @intFromBool(self.key_down.repeat);
            },
            .key_up => {
                sdl_event.type = c.SDL_EVENT_KEY_UP;
                sdl_event.key.timestamp = self.key_up.timestamp;
                sdl_event.key.windowID = self.key_up.windowID;
                sdl_event.key.which = self.key_up.which;
                sdl_event.key.scancode = self.key_up.scancode;
                sdl_event.key.key = self.key_up.keycode;
                sdl_event.key.mod = self.key_up.mod;
                sdl_event.key.repeat = @intFromBool(self.key_up.repeat);
            },
            .text_editing => {
                sdl_event.type = c.SDL_EVENT_TEXT_EDITING;
                sdl_event.edit.timestamp = self.text_editing.timestamp;
                sdl_event.edit.windowID = self.text_editing.windowID;

                if (self.text_editing.text.len > 0) {
                    const len = @min(self.text_editing.text.len, 31);
                    @memcpy(sdl_event.edit.text[0..len], self.text_editing.text[0..len]);
                    sdl_event.edit.text[len] = 0;
                } else {
                    sdl_event.edit.text[0] = 0;
                }
                sdl_event.edit.start = self.text_editing.start;
                sdl_event.edit.length = self.text_editing.length;
            },
            .text_input => {
                sdl_event.type = c.SDL_EVENT_TEXT_INPUT;
                sdl_event.text.timestamp = self.text_input.timestamp;
                sdl_event.text.windowID = self.text_input.windowID;

                if (self.text_input.text.len > 0) {
                    const len = @min(self.text_input.text.len, 31);
                    @memcpy(sdl_event.text.text[0..len], self.text_input.text[0..len]);
                    sdl_event.text.text[len] = 0;
                } else {
                    sdl_event.text.text[0] = 0;
                }
            },
            .text_editing_candidates => {
                sdl_event.type = c.SDL_EVENT_TEXT_EDITING_CANDIDATES;
                sdl_event.edit_candidates.timestamp = self.text_editing_candidates.timestamp;
                sdl_event.edit_candidates.windowID = self.text_editing_candidates.windowID;

                sdl_event.edit_candidates.candidates = @ptrCast(self.text_editing_candidates.candidates.ptr);
                sdl_event.edit_candidates.num_candidates = @intCast(self.text_editing_candidates.candidates.len);
                sdl_event.edit_candidates.selected_candidate = self.text_editing_candidates.selected_candidate;
                sdl_event.edit_candidates.horizontal = @intFromBool(self.text_editing_candidates.horizontal);
            },

            .mouse_motion => {
                sdl_event.type = c.SDL_EVENT_MOUSE_MOTION;
                sdl_event.motion.timestamp = self.mouse_motion.timestamp;
                sdl_event.motion.windowID = self.mouse_motion.windowID;
                sdl_event.motion.which = self.mouse_motion.which;
                sdl_event.motion.state = self.mouse_motion.state;
                sdl_event.motion.x = self.mouse_motion.x;
                sdl_event.motion.y = self.mouse_motion.y;
                sdl_event.motion.xrel = self.mouse_motion.xrel;
                sdl_event.motion.yrel = self.mouse_motion.yrel;
            },
            .mouse_button_down => {
                sdl_event.type = c.SDL_EVENT_MOUSE_BUTTON_DOWN;
                sdl_event.button.timestamp = self.mouse_button_down.timestamp;
                sdl_event.button.windowID = self.mouse_button_down.windowID;
                sdl_event.button.which = self.mouse_button_down.which;
                sdl_event.button.button = self.mouse_button_down.button;
                sdl_event.button.clicks = self.mouse_button_down.clicks;
                sdl_event.button.x = self.mouse_button_down.x;
                sdl_event.button.y = self.mouse_button_down.y;
            },
            .mouse_button_up => {
                sdl_event.type = c.SDL_EVENT_MOUSE_BUTTON_UP;
                sdl_event.button.timestamp = self.mouse_button_up.timestamp;
                sdl_event.button.windowID = self.mouse_button_up.windowID;
                sdl_event.button.which = self.mouse_button_up.which;
                sdl_event.button.button = self.mouse_button_up.button;
                sdl_event.button.clicks = self.mouse_button_up.clicks;
                sdl_event.button.x = self.mouse_button_up.x;
                sdl_event.button.y = self.mouse_button_up.y;
            },
            .mouse_wheel => {
                sdl_event.type = c.SDL_EVENT_MOUSE_WHEEL;
                sdl_event.wheel.timestamp = self.mouse_wheel.timestamp;
                sdl_event.wheel.windowID = self.mouse_wheel.windowID;
                sdl_event.wheel.which = self.mouse_wheel.which;
                sdl_event.wheel.x = self.mouse_wheel.x;
                sdl_event.wheel.y = self.mouse_wheel.y;
                sdl_event.wheel.direction = self.mouse_wheel.direction;
                sdl_event.wheel.mouse_x = self.mouse_wheel.mouse_x;
                sdl_event.wheel.mouse_y = self.mouse_wheel.mouse_y;
            },
            .mouse_added => {
                sdl_event.type = c.SDL_EVENT_MOUSE_ADDED;
                sdl_event.mdevice.timestamp = self.mouse_added.timestamp;
                sdl_event.mdevice.which = self.mouse_added.which;
            },
            .mouse_removed => {
                sdl_event.type = c.SDL_EVENT_MOUSE_REMOVED;
                sdl_event.mdevice.timestamp = self.mouse_removed.timestamp;
                sdl_event.mdevice.which = self.mouse_removed.which;
            },

            .joystick_axis_motion => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_AXIS_MOTION;
                sdl_event.jaxis.timestamp = self.joystick_axis_motion.timestamp;
                sdl_event.jaxis.which = self.joystick_axis_motion.which;
                sdl_event.jaxis.axis = self.joystick_axis_motion.axis;
                sdl_event.jaxis.value = self.joystick_axis_motion.value;
            },
            .joystick_ball_motion => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_BALL_MOTION;
                sdl_event.jball.timestamp = self.joystick_ball_motion.timestamp;
                sdl_event.jball.which = self.joystick_ball_motion.which;
                sdl_event.jball.ball = self.joystick_ball_motion.ball;
                sdl_event.jball.xrel = self.joystick_ball_motion.xrel;
                sdl_event.jball.yrel = self.joystick_ball_motion.yrel;
            },
            .joystick_hat_motion => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_HAT_MOTION;
                sdl_event.jhat.timestamp = self.joystick_hat_motion.timestamp;
                sdl_event.jhat.which = self.joystick_hat_motion.which;
                sdl_event.jhat.hat = self.joystick_hat_motion.hat;
                sdl_event.jhat.value = self.joystick_hat_motion.value;
            },
            .joystick_button_down => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_BUTTON_DOWN;
                sdl_event.jbutton.timestamp = self.joystick_button_down.timestamp;
                sdl_event.jbutton.which = self.joystick_button_down.which;
                sdl_event.jbutton.button = self.joystick_button_down.button;
                sdl_event.jbutton.down = 1;
            },
            .joystick_button_up => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_BUTTON_UP;
                sdl_event.jbutton.timestamp = self.joystick_button_up.timestamp;
                sdl_event.jbutton.which = self.joystick_button_up.which;
                sdl_event.jbutton.button = self.joystick_button_up.button;
                sdl_event.jbutton.down = 0;
            },
            .joystick_added => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_ADDED;
                sdl_event.jdevice.timestamp = self.joystick_added.timestamp;
                sdl_event.jdevice.which = self.joystick_added.which;
            },
            .joystick_removed => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_REMOVED;
                sdl_event.jdevice.timestamp = self.joystick_removed.timestamp;
                sdl_event.jdevice.which = self.joystick_removed.which;
            },
            .joystick_battery_updated => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_BATTERY_UPDATED;
                sdl_event.jbattery.timestamp = self.joystick_battery_updated.timestamp;
                sdl_event.jbattery.which = self.joystick_battery_updated.which;
                sdl_event.jbattery.state = self.joystick_battery_updated.state;
                sdl_event.jbattery.percent = self.joystick_battery_updated.percent;
            },
            .joystick_update_complete => {
                sdl_event.type = c.SDL_EVENT_JOYSTICK_UPDATE_COMPLETE;
                sdl_event.jdevice.timestamp = self.joystick_update_complete.timestamp;
                sdl_event.jdevice.which = self.joystick_update_complete.which;
            },

            .gamepad_axis_motion => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_AXIS_MOTION;
                sdl_event.gaxis.timestamp = self.gamepad_axis_motion.timestamp;
                sdl_event.gaxis.which = self.gamepad_axis_motion.which;
                sdl_event.gaxis.axis = self.gamepad_axis_motion.axis;
                sdl_event.gaxis.value = self.gamepad_axis_motion.value;
            },
            .gamepad_button_down => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_BUTTON_DOWN;
                sdl_event.gbutton.timestamp = self.gamepad_button_down.timestamp;
                sdl_event.gbutton.which = self.gamepad_button_down.which;
                sdl_event.gbutton.button = self.gamepad_button_down.button;
                sdl_event.gbutton.down = 1;
            },
            .gamepad_button_up => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_BUTTON_UP;
                sdl_event.gbutton.timestamp = self.gamepad_button_up.timestamp;
                sdl_event.gbutton.which = self.gamepad_button_up.which;
                sdl_event.gbutton.button = self.gamepad_button_up.button;
                sdl_event.gbutton.down = 0;
            },
            .gamepad_added => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_ADDED;
                sdl_event.gdevice.timestamp = self.gamepad_added.timestamp;
                sdl_event.gdevice.which = self.gamepad_added.which;
            },
            .gamepad_removed => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_REMOVED;
                sdl_event.gdevice.timestamp = self.gamepad_removed.timestamp;
                sdl_event.gdevice.which = self.gamepad_removed.which;
            },
            .gamepad_remapped => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_REMAPPED;
                sdl_event.gdevice.timestamp = self.gamepad_remapped.timestamp;
                sdl_event.gdevice.which = self.gamepad_remapped.which;
            },
            .gamepad_touchpad_down => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN;
                sdl_event.gtouchpad.timestamp = self.gamepad_touchpad_down.timestamp;
                sdl_event.gtouchpad.which = self.gamepad_touchpad_down.which;
                sdl_event.gtouchpad.touchpad = self.gamepad_touchpad_down.touchpad;
                sdl_event.gtouchpad.finger = self.gamepad_touchpad_down.finger;
                sdl_event.gtouchpad.x = self.gamepad_touchpad_down.x;
                sdl_event.gtouchpad.y = self.gamepad_touchpad_down.y;
                sdl_event.gtouchpad.pressure = self.gamepad_touchpad_down.pressure;
            },
            .gamepad_touchpad_motion => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION;
                sdl_event.gtouchpad.timestamp = self.gamepad_touchpad_motion.timestamp;
                sdl_event.gtouchpad.which = self.gamepad_touchpad_motion.which;
                sdl_event.gtouchpad.touchpad = self.gamepad_touchpad_motion.touchpad;
                sdl_event.gtouchpad.finger = self.gamepad_touchpad_motion.finger;
                sdl_event.gtouchpad.x = self.gamepad_touchpad_motion.x;
                sdl_event.gtouchpad.y = self.gamepad_touchpad_motion.y;
                sdl_event.gtouchpad.pressure = self.gamepad_touchpad_motion.pressure;
            },
            .gamepad_touchpad_up => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_TOUCHPAD_UP;
                sdl_event.gtouchpad.timestamp = self.gamepad_touchpad_up.timestamp;
                sdl_event.gtouchpad.which = self.gamepad_touchpad_up.which;
                sdl_event.gtouchpad.touchpad = self.gamepad_touchpad_up.touchpad;
                sdl_event.gtouchpad.finger = self.gamepad_touchpad_up.finger;
                sdl_event.gtouchpad.x = self.gamepad_touchpad_up.x;
                sdl_event.gtouchpad.y = self.gamepad_touchpad_up.y;
                sdl_event.gtouchpad.pressure = self.gamepad_touchpad_up.pressure;
            },
            .gamepad_sensor_update => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_SENSOR_UPDATE;
                sdl_event.gsensor.timestamp = self.gamepad_sensor_update.timestamp;
                sdl_event.gsensor.which = self.gamepad_sensor_update.which;
                sdl_event.gsensor.sensor = self.gamepad_sensor_update.sensor;
                sdl_event.gsensor.data = self.gamepad_sensor_update.data;
                sdl_event.gsensor.sensor_timestamp = self.gamepad_sensor_update.sensor_timestamp;
            },
            .gamepad_update_complete => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_UPDATE_COMPLETE;
                sdl_event.gdevice.timestamp = self.gamepad_update_complete.timestamp;
                sdl_event.gdevice.which = self.gamepad_update_complete.which;
            },
            .gamepad_steam_handle_updated => {
                sdl_event.type = c.SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED;
                sdl_event.gdevice.timestamp = self.gamepad_steam_handle_updated.timestamp;
                sdl_event.gdevice.which = self.gamepad_steam_handle_updated.which;
            },

            .finger_down => {
                sdl_event.type = c.SDL_EVENT_FINGER_DOWN;
                sdl_event.tfinger.timestamp = self.finger_down.timestamp;
                sdl_event.tfinger.touchID = self.finger_down.touchID;
                sdl_event.tfinger.fingerID = self.finger_down.fingerID;
                sdl_event.tfinger.x = self.finger_down.x;
                sdl_event.tfinger.y = self.finger_down.y;
                sdl_event.tfinger.dx = self.finger_down.dx;
                sdl_event.tfinger.dy = self.finger_down.dy;
                sdl_event.tfinger.pressure = self.finger_down.pressure;
                sdl_event.tfinger.windowID = self.finger_down.windowID;
            },
            .finger_up => {
                sdl_event.type = c.SDL_EVENT_FINGER_UP;
                sdl_event.tfinger.timestamp = self.finger_up.timestamp;
                sdl_event.tfinger.touchID = self.finger_up.touchID;
                sdl_event.tfinger.fingerID = self.finger_up.fingerID;
                sdl_event.tfinger.x = self.finger_up.x;
                sdl_event.tfinger.y = self.finger_up.y;
                sdl_event.tfinger.dx = self.finger_up.dx;
                sdl_event.tfinger.dy = self.finger_up.dy;
                sdl_event.tfinger.pressure = self.finger_up.pressure;
                sdl_event.tfinger.windowID = self.finger_up.windowID;
            },
            .finger_motion => {
                sdl_event.type = c.SDL_EVENT_FINGER_MOTION;
                sdl_event.tfinger.timestamp = self.finger_motion.timestamp;
                sdl_event.tfinger.touchID = self.finger_motion.touchID;
                sdl_event.tfinger.fingerID = self.finger_motion.fingerID;
                sdl_event.tfinger.x = self.finger_motion.x;
                sdl_event.tfinger.y = self.finger_motion.y;
                sdl_event.tfinger.dx = self.finger_motion.dx;
                sdl_event.tfinger.dy = self.finger_motion.dy;
                sdl_event.tfinger.pressure = self.finger_motion.pressure;
                sdl_event.tfinger.windowID = self.finger_motion.windowID;
            },
            .finger_canceled => {
                sdl_event.type = c.SDL_EVENT_FINGER_CANCELED;
                sdl_event.tfinger.timestamp = self.finger_canceled.timestamp;
                sdl_event.tfinger.windowID = self.finger_canceled.windowID;
            },

            .clipboard_update => {
                sdl_event.type = c.SDL_EVENT_CLIPBOARD_UPDATE;
                sdl_event.clipboard.timestamp = self.clipboard_update.timestamp;
                sdl_event.clipboard.owner = @intFromBool(self.clipboard_update.owner);

                sdl_event.clipboard.mime_types = @ptrCast(self.clipboard_update.mime_types.ptr);
                sdl_event.clipboard.num_mime_types = @intCast(self.clipboard_update.mime_types.len);
            },

            .drop_file => {
                sdl_event.type = c.SDL_EVENT_DROP_FILE;
                sdl_event.drop.timestamp = self.drop_file.timestamp;
                sdl_event.drop.windowID = self.drop_file.windowID;
                sdl_event.drop.data = @ptrCast(self.drop_file.file.ptr);
            },
            .drop_text => {
                sdl_event.type = c.SDL_EVENT_DROP_TEXT;
                sdl_event.drop.timestamp = self.drop_text.timestamp;
                sdl_event.drop.windowID = self.drop_text.windowID;
                sdl_event.drop.data = @ptrCast(self.drop_text.text.ptr);
            },
            .drop_begin => {
                sdl_event.type = c.SDL_EVENT_DROP_BEGIN;
                sdl_event.drop.timestamp = self.drop_begin.timestamp;
                sdl_event.drop.windowID = self.drop_begin.windowID;
                sdl_event.drop.data = null;
            },
            .drop_complete => {
                sdl_event.type = c.SDL_EVENT_DROP_COMPLETE;
                sdl_event.drop.timestamp = self.drop_complete.timestamp;
                sdl_event.drop.windowID = self.drop_complete.windowID;
                sdl_event.drop.data = null;
            },
            .drop_position => {
                sdl_event.type = c.SDL_EVENT_DROP_POSITION;
                sdl_event.drop.timestamp = self.drop_position.timestamp;
                sdl_event.drop.windowID = self.drop_position.windowID;
                sdl_event.drop.x = self.drop_position.x;
                sdl_event.drop.y = self.drop_position.y;
                sdl_event.drop.data = null;
            },

            .audio_device_added => {
                sdl_event.type = c.SDL_EVENT_AUDIO_DEVICE_ADDED;
                sdl_event.adevice.timestamp = self.audio_device_added.timestamp;
                sdl_event.adevice.which = self.audio_device_added.which;
                sdl_event.adevice.recording = @intFromBool(self.audio_device_added.recording);
            },
            .audio_device_removed => {
                sdl_event.type = c.SDL_EVENT_AUDIO_DEVICE_REMOVED;
                sdl_event.adevice.timestamp = self.audio_device_removed.timestamp;
                sdl_event.adevice.which = self.audio_device_removed.which;
                sdl_event.adevice.recording = @intFromBool(self.audio_device_removed.recording);
            },
            .audio_device_format_changed => {
                sdl_event.type = c.SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED;
                sdl_event.adevice.timestamp = self.audio_device_format_changed.timestamp;
                sdl_event.adevice.which = self.audio_device_format_changed.which;
                sdl_event.adevice.recording = @intFromBool(self.audio_device_format_changed.recording);
            },

            .sensor_update => {
                sdl_event.type = c.SDL_EVENT_SENSOR_UPDATE;
                sdl_event.sensor.timestamp = self.sensor_update.timestamp;
                sdl_event.sensor.which = self.sensor_update.which;
                sdl_event.sensor.data = self.sensor_update.data;
                sdl_event.sensor.sensor_timestamp = self.sensor_update.sensor_timestamp;
            },

            .pen_proximity_in => {
                sdl_event.type = c.SDL_EVENT_PEN_PROXIMITY_IN;
                sdl_event.pproximity.timestamp = self.pen_proximity_in.timestamp;
                sdl_event.pproximity.windowID = self.pen_proximity_in.windowID;
                sdl_event.pproximity.which = self.pen_proximity_in.which;
            },
            .pen_proximity_out => {
                sdl_event.type = c.SDL_EVENT_PEN_PROXIMITY_OUT;
                sdl_event.pproximity.timestamp = self.pen_proximity_out.timestamp;
                sdl_event.pproximity.windowID = self.pen_proximity_out.windowID;
                sdl_event.pproximity.which = self.pen_proximity_out.which;
            },
            .pen_down => {
                sdl_event.type = c.SDL_EVENT_PEN_DOWN;
                sdl_event.ptouch.timestamp = self.pen_down.timestamp;
                sdl_event.ptouch.windowID = self.pen_down.windowID;
                sdl_event.ptouch.which = self.pen_down.which;
                sdl_event.ptouch.pen_state = self.pen_down.pen_state;
                sdl_event.ptouch.x = self.pen_down.x;
                sdl_event.ptouch.y = self.pen_down.y;
                sdl_event.ptouch.eraser = @intFromBool(self.pen_down.eraser);
                sdl_event.ptouch.down = 1;
            },
            .pen_up => {
                sdl_event.type = c.SDL_EVENT_PEN_UP;
                sdl_event.ptouch.timestamp = self.pen_up.timestamp;
                sdl_event.ptouch.windowID = self.pen_up.windowID;
                sdl_event.ptouch.which = self.pen_up.which;
                sdl_event.ptouch.pen_state = self.pen_up.pen_state;
                sdl_event.ptouch.x = self.pen_up.x;
                sdl_event.ptouch.y = self.pen_up.y;
                sdl_event.ptouch.eraser = @intFromBool(self.pen_up.eraser);
                sdl_event.ptouch.down = 0;
            },
            .pen_motion => {
                sdl_event.type = c.SDL_EVENT_PEN_MOTION;
                sdl_event.pmotion.timestamp = self.pen_motion.timestamp;
                sdl_event.pmotion.windowID = self.pen_motion.windowID;
                sdl_event.pmotion.which = self.pen_motion.which;
                sdl_event.pmotion.pen_state = self.pen_motion.pen_state;
                sdl_event.pmotion.x = self.pen_motion.x;
                sdl_event.pmotion.y = self.pen_motion.y;
            },
            .pen_button_down => {
                sdl_event.type = c.SDL_EVENT_PEN_BUTTON_DOWN;
                sdl_event.pbutton.timestamp = self.pen_button_down.timestamp;
                sdl_event.pbutton.windowID = self.pen_button_down.windowID;
                sdl_event.pbutton.which = self.pen_button_down.which;
                sdl_event.pbutton.pen_state = self.pen_button_down.pen_state;
                sdl_event.pbutton.x = self.pen_button_down.x;
                sdl_event.pbutton.y = self.pen_button_down.y;
                sdl_event.pbutton.button = self.pen_button_down.button;
                sdl_event.pbutton.down = 1;
            },
            .pen_button_up => {
                sdl_event.type = c.SDL_EVENT_PEN_BUTTON_UP;
                sdl_event.pbutton.timestamp = self.pen_button_up.timestamp;
                sdl_event.pbutton.windowID = self.pen_button_up.windowID;
                sdl_event.pbutton.which = self.pen_button_up.which;
                sdl_event.pbutton.pen_state = self.pen_button_up.pen_state;
                sdl_event.pbutton.x = self.pen_button_up.x;
                sdl_event.pbutton.y = self.pen_button_up.y;
                sdl_event.pbutton.button = self.pen_button_up.button;
                sdl_event.pbutton.down = 0;
            },
            .pen_axis => {
                sdl_event.type = c.SDL_EVENT_PEN_AXIS;
                sdl_event.paxis.timestamp = self.pen_axis.timestamp;
                sdl_event.paxis.windowID = self.pen_axis.windowID;
                sdl_event.paxis.which = self.pen_axis.which;
                sdl_event.paxis.pen_state = self.pen_axis.pen_state;
                sdl_event.paxis.x = self.pen_axis.x;
                sdl_event.paxis.y = self.pen_axis.y;
                sdl_event.paxis.axis = self.pen_axis.axis;
                sdl_event.paxis.value = self.pen_axis.value;
            },

            .camera_device_added => {
                sdl_event.type = c.SDL_EVENT_CAMERA_DEVICE_ADDED;
                sdl_event.cdevice.timestamp = self.camera_device_added.timestamp;
                sdl_event.cdevice.which = self.camera_device_added.which;
            },
            .camera_device_removed => {
                sdl_event.type = c.SDL_EVENT_CAMERA_DEVICE_REMOVED;
                sdl_event.cdevice.timestamp = self.camera_device_removed.timestamp;
                sdl_event.cdevice.which = self.camera_device_removed.which;
            },
            .camera_device_approved => {
                sdl_event.type = c.SDL_EVENT_CAMERA_DEVICE_APPROVED;
                sdl_event.cdevice.timestamp = self.camera_device_approved.timestamp;
                sdl_event.cdevice.which = self.camera_device_approved.which;
            },
            .camera_device_denied => {
                sdl_event.type = c.SDL_EVENT_CAMERA_DEVICE_DENIED;
                sdl_event.cdevice.timestamp = self.camera_device_denied.timestamp;
                sdl_event.cdevice.which = self.camera_device_denied.which;
            },

            .render_targets_reset => {
                sdl_event.type = c.SDL_EVENT_RENDER_TARGETS_RESET;
                sdl_event.render.timestamp = self.render_targets_reset.timestamp;
                sdl_event.render.windowID = self.render_targets_reset.windowID;
            },
            .render_device_reset => {
                sdl_event.type = c.SDL_EVENT_RENDER_DEVICE_RESET;
                sdl_event.render.timestamp = self.render_device_reset.timestamp;
                sdl_event.render.windowID = self.render_device_reset.windowID;
            },
            .render_device_lost => {
                sdl_event.type = c.SDL_EVENT_RENDER_DEVICE_LOST;
                sdl_event.render.timestamp = self.render_device_lost.timestamp;
                sdl_event.render.windowID = self.render_device_lost.windowID;
            },

            .user => {
                sdl_event.type = c.SDL_EVENT_USER;
                sdl_event.user.timestamp = self.user.timestamp;
                sdl_event.user.windowID = self.user.windowID;
                sdl_event.user.code = self.user.code;
                sdl_event.user.data1 = self.user.data1;
                sdl_event.user.data2 = self.user.data2;
            },

            .last => {
                sdl_event.type = c.SDL_EVENT_LAST;
                sdl_event.common.timestamp = self.last.timestamp;
            },
            .enum_padding => {
                sdl_event.type = c.SDL_EVENT_ENUM_PADDING;
                sdl_event.common.timestamp = self.enum_padding.timestamp;
            },
            .private0 => {
                sdl_event.type = c.SDL_EVENT_PRIVATE0;
                sdl_event.common.timestamp = self.private0.timestamp;
            },
            .private1 => {
                sdl_event.type = c.SDL_EVENT_PRIVATE1;
                sdl_event.common.timestamp = self.private1.timestamp;
            },
            .private2 => {
                sdl_event.type = c.SDL_EVENT_PRIVATE2;
                sdl_event.common.timestamp = self.private2.timestamp;
            },
            .private3 => {
                sdl_event.type = c.SDL_EVENT_PRIVATE3;
                sdl_event.common.timestamp = self.private3.timestamp;
            },
            .poll_sentinel => {
                sdl_event.type = c.SDL_EVENT_POLL_SENTINEL;
                sdl_event.common.timestamp = self.poll_sentinel.timestamp;
            },
        }

        return sdl_event;
    }
};

/// Poll for currently pending events.
pub inline fn pollEvent() ?Event {
    var sdl_event: c.SDL_Event = undefined;
    if (!c.SDL_PollEvent(&sdl_event)) return null;
    return Event.fromNative(sdl_event);
}

/// Pump the event loop, gathering events from the input devices.
pub inline fn pumpEvents() void {
    c.SDL_PumpEvents();
}

/// Check the event queue for messages and optionally return them.
pub inline fn peepEvents(events: []Event, action: EventAction, minType: EventType, maxType: EventType) !i32 {
    if (events.len == 0 and action != .peekevent) {
        return 0;
    }

    var sdl_events_buffer: [128]c.SDL_Event = undefined;
    const max_events = @min(events.len, sdl_events_buffer.len);
    var sdl_events = sdl_events_buffer[0..max_events];

    if (action == .addevent) {
        for (events, 0..max_events) |event, i| {
            sdl_events[i] = event.toNative();
        }
    }

    const numevents: c_int = @intCast(max_events);
    const result = c.SDL_PeepEvents(sdl_events.ptr, numevents, @intFromEnum(action), @intFromEnum(minType), @intFromEnum(maxType));

    if (result < 0) {
        return error.SDLError;
    }

    if (action == .getevent or action == .peekevent) {
        for (0..@intCast(result)) |i| {
            events[i] = Event.fromNative(sdl_events[i]);
        }
    }

    return result;
}

/// Check for the existence of a certain event type in the event queue.
pub inline fn hasEvent(event_type: EventType) bool {
    return c.SDL_HasEvent(@intFromEnum(event_type));
}

/// Check for the existence of certain event types in the event queue.
pub inline fn hasEvents(minType: EventType, maxType: EventType) bool {
    return c.SDL_HasEvents(@intFromEnum(minType), @intFromEnum(maxType));
}

/// Clear events of a specific type from the event queue.
pub inline fn flushEvent(event_type: EventType) void {
    c.SDL_FlushEvent(@intFromEnum(event_type));
}

/// Clear events of a range of types from the event queue.
pub inline fn flushEvents(minType: EventType, maxType: EventType) void {
    c.SDL_FlushEvents(@intFromEnum(minType), @intFromEnum(maxType));
}

/// Wait indefinitely for the next available event.
pub inline fn waitEvent() !?Event {
    var sdl_event: c.SDL_Event = undefined;
    try errify(c.SDL_WaitEvent(&sdl_event));
    return Event.fromNative(sdl_event);
}

/// Wait until the specified timeout (in milliseconds) for the next available event.
pub inline fn waitEventTimeout(timeout: i32) !?Event {
    var sdl_event: c.SDL_Event = undefined;
    try errify(c.SDL_WaitEventTimeout(&sdl_event, timeout));
    return Event.fromNative(sdl_event);
}

/// Add an event to the event queue.
pub inline fn pushEvent(event: Event) !void {
    var sdl_event = event.toNative();
    try errify(c.SDL_PushEvent(&sdl_event));
}

/// Set up a filter to process all events before they are added to the internal event queue.
pub inline fn setEventFilter(filter: EventFilter, userdata: ?*anyopaque) void {
    c.SDL_SetEventFilter(filter, userdata);
}

/// Query the current event filter.
pub inline fn getEventFilter(filter: ?*EventFilter, userdata: ?*?*anyopaque) bool {
    return c.SDL_GetEventFilter(filter, userdata);
}

/// Add a callback to be triggered when an event is added to the event queue.
pub inline fn addEventWatch(filter: EventFilter, userdata: ?*anyopaque) !void {
    try errify(c.SDL_AddEventWatch(filter, userdata));
}

/// Remove an event watch callback added with addEventWatch().
pub inline fn removeEventWatch(filter: EventFilter, userdata: ?*anyopaque) void {
    c.SDL_RemoveEventWatch(filter, userdata);
}

/// Run a specific filter function on the current event queue, removing any events for which the filter returns false.
pub inline fn filterEvents(filter: EventFilter, userdata: ?*anyopaque) void {
    c.SDL_FilterEvents(filter, userdata);
}

/// Set the state of processing events by type.
pub inline fn setEventEnabled(event_type: EventType, enabled: bool) void {
    c.SDL_SetEventEnabled(@intFromEnum(event_type), enabled);
}

/// Query the state of processing events by type.
pub inline fn eventEnabled(event_type: EventType) bool {
    return c.SDL_EventEnabled(@intFromEnum(event_type));
}

/// Allocate a set of user-defined events, and return the beginning event number for that set of events.
pub inline fn registerEvents(numevents: i32) u32 {
    return c.SDL_RegisterEvents(numevents);
}

/// Get window associated with an event.
pub inline fn getWindowFromEvent(event: Event) ?Window {
    // Convert to SDL event
    const sdl_event = event.toNative();

    if (c.SDL_GetWindowFromEvent(&sdl_event)) |window| {
        return .{
            .ptr = @ptrCast(window),
        };
    }
    return null;
}
