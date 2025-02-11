const std = @import("std");
const internal = @import("internal.zig");
const c = @import("c.zig").c;
const errify = internal.errify;
const video = @import("video.zig");
const Window = video.Window;
const rect = @import("rect.zig");
const Rectangle = rect.Rectangle;
const PropertiesID = video.PropertiesID;

pub const KeyboardID = c.SDL_KeyboardID;
pub const Keycode = enum(u32) {
    unknown = c.SDLK_UNKNOWN,
    @"return" = c.SDLK_RETURN,
    escape = c.SDLK_ESCAPE,
    backspace = c.SDLK_BACKSPACE,
    tab = c.SDLK_TAB,
    space = c.SDLK_SPACE,
    exclaim = c.SDLK_EXCLAIM,
    dblapostrophe = c.SDLK_DBLAPOSTROPHE,
    hash = c.SDLK_HASH,
    dollar = c.SDLK_DOLLAR,
    percent = c.SDLK_PERCENT,
    ampersand = c.SDLK_AMPERSAND,
    apostrophe = c.SDLK_APOSTROPHE,
    leftparen = c.SDLK_LEFTPAREN,
    rightparen = c.SDLK_RIGHTPAREN,
    asterisk = c.SDLK_ASTERISK,
    plus = c.SDLK_PLUS,
    comma = c.SDLK_COMMA,
    minus = c.SDLK_MINUS,
    period = c.SDLK_PERIOD,
    slash = c.SDLK_SLASH,
    @"0" = c.SDLK_0,
    @"1" = c.SDLK_1,
    @"2" = c.SDLK_2,
    @"3" = c.SDLK_3,
    @"4" = c.SDLK_4,
    @"5" = c.SDLK_5,
    @"6" = c.SDLK_6,
    @"7" = c.SDLK_7,
    @"8" = c.SDLK_8,
    @"9" = c.SDLK_9,
    colon = c.SDLK_COLON,
    semicolon = c.SDLK_SEMICOLON,
    less = c.SDLK_LESS,
    equals = c.SDLK_EQUALS,
    greater = c.SDLK_GREATER,
    question = c.SDLK_QUESTION,
    at = c.SDLK_AT,
    leftbracket = c.SDLK_LEFTBRACKET,
    backslash = c.SDLK_BACKSLASH,
    rightbracket = c.SDLK_RIGHTBRACKET,
    caret = c.SDLK_CARET,
    underscore = c.SDLK_UNDERSCORE,
    grave = c.SDLK_GRAVE,
    a = c.SDLK_A,
    b = c.SDLK_B,
    c = c.SDLK_C,
    d = c.SDLK_D,
    e = c.SDLK_E,
    f = c.SDLK_F,
    g = c.SDLK_G,
    h = c.SDLK_H,
    i = c.SDLK_I,
    j = c.SDLK_J,
    k = c.SDLK_K,
    l = c.SDLK_L,
    m = c.SDLK_M,
    n = c.SDLK_N,
    o = c.SDLK_O,
    p = c.SDLK_P,
    q = c.SDLK_Q,
    r = c.SDLK_R,
    s = c.SDLK_S,
    t = c.SDLK_T,
    u = c.SDLK_U,
    v = c.SDLK_V,
    w = c.SDLK_W,
    x = c.SDLK_X,
    y = c.SDLK_Y,
    z = c.SDLK_Z,
    leftbrace = c.SDLK_LEFTBRACE,
    pipe = c.SDLK_PIPE,
    rightbrace = c.SDLK_RIGHTBRACE,
    tilde = c.SDLK_TILDE,
    delete = c.SDLK_DELETE,
    plusminus = c.SDLK_PLUSMINUS,
    capslock = c.SDLK_CAPSLOCK,
    f1 = c.SDLK_F1,
    f2 = c.SDLK_F2,
    f3 = c.SDLK_F3,
    f4 = c.SDLK_F4,
    f5 = c.SDLK_F5,
    f6 = c.SDLK_F6,
    f7 = c.SDLK_F7,
    f8 = c.SDLK_F8,
    f9 = c.SDLK_F9,
    f10 = c.SDLK_F10,
    f11 = c.SDLK_F11,
    f12 = c.SDLK_F12,
    printscreen = c.SDLK_PRINTSCREEN,
    scrolllock = c.SDLK_SCROLLLOCK,
    pause = c.SDLK_PAUSE,
    insert = c.SDLK_INSERT,
    home = c.SDLK_HOME,
    pageup = c.SDLK_PAGEUP,
    end = c.SDLK_END,
    pagedown = c.SDLK_PAGEDOWN,
    right = c.SDLK_RIGHT,
    left = c.SDLK_LEFT,
    down = c.SDLK_DOWN,
    up = c.SDLK_UP,
    numlockclear = c.SDLK_NUMLOCKCLEAR,
    kp_divide = c.SDLK_KP_DIVIDE,
    kp_multiply = c.SDLK_KP_MULTIPLY,
    kp_minus = c.SDLK_KP_MINUS,
    kp_plus = c.SDLK_KP_PLUS,
    kp_enter = c.SDLK_KP_ENTER,
    kp_1 = c.SDLK_KP_1,
    kp_2 = c.SDLK_KP_2,
    kp_3 = c.SDLK_KP_3,
    kp_4 = c.SDLK_KP_4,
    kp_5 = c.SDLK_KP_5,
    kp_6 = c.SDLK_KP_6,
    kp_7 = c.SDLK_KP_7,
    kp_8 = c.SDLK_KP_8,
    kp_9 = c.SDLK_KP_9,
    kp_0 = c.SDLK_KP_0,
    kp_period = c.SDLK_KP_PERIOD,
    application = c.SDLK_APPLICATION,
    power = c.SDLK_POWER,
    kp_equals = c.SDLK_KP_EQUALS,
    f13 = c.SDLK_F13,
    f14 = c.SDLK_F14,
    f15 = c.SDLK_F15,
    f16 = c.SDLK_F16,
    f17 = c.SDLK_F17,
    f18 = c.SDLK_F18,
    f19 = c.SDLK_F19,
    f20 = c.SDLK_F20,
    f21 = c.SDLK_F21,
    f22 = c.SDLK_F22,
    f23 = c.SDLK_F23,
    f24 = c.SDLK_F24,
    execute = c.SDLK_EXECUTE,
    help = c.SDLK_HELP,
    menu = c.SDLK_MENU,
    select = c.SDLK_SELECT,
    stop = c.SDLK_STOP,
    again = c.SDLK_AGAIN,
    undo = c.SDLK_UNDO,
    cut = c.SDLK_CUT,
    copy = c.SDLK_COPY,
    paste = c.SDLK_PASTE,
    find = c.SDLK_FIND,
    mute = c.SDLK_MUTE,
    volumeup = c.SDLK_VOLUMEUP,
    volumedown = c.SDLK_VOLUMEDOWN,
    kp_comma = c.SDLK_KP_COMMA,
    kp_equalsas400 = c.SDLK_KP_EQUALSAS400,
    alterase = c.SDLK_ALTERASE,
    sysreq = c.SDLK_SYSREQ,
    cancel = c.SDLK_CANCEL,
    clear = c.SDLK_CLEAR,
    prior = c.SDLK_PRIOR,
    return2 = c.SDLK_RETURN2,
    separator = c.SDLK_SEPARATOR,
    out = c.SDLK_OUT,
    oper = c.SDLK_OPER,
    clearagain = c.SDLK_CLEARAGAIN,
    crsel = c.SDLK_CRSEL,
    exsel = c.SDLK_EXSEL,
    kp_00 = c.SDLK_KP_00,
    kp_000 = c.SDLK_KP_000,
    thousandsseparator = c.SDLK_THOUSANDSSEPARATOR,
    decimalseparator = c.SDLK_DECIMALSEPARATOR,
    currencyunit = c.SDLK_CURRENCYUNIT,
    currencysubunit = c.SDLK_CURRENCYSUBUNIT,
    kp_leftparen = c.SDLK_KP_LEFTPAREN,
    kp_rightparen = c.SDLK_KP_RIGHTPAREN,
    kp_leftbrace = c.SDLK_KP_LEFTBRACE,
    kp_rightbrace = c.SDLK_KP_RIGHTBRACE,
    kp_tab = c.SDLK_KP_TAB,
    kp_backspace = c.SDLK_KP_BACKSPACE,
    kp_a = c.SDLK_KP_A,
    kp_b = c.SDLK_KP_B,
    kp_c = c.SDLK_KP_C,
    kp_d = c.SDLK_KP_D,
    kp_e = c.SDLK_KP_E,
    kp_f = c.SDLK_KP_F,
    kp_xor = c.SDLK_KP_XOR,
    kp_power = c.SDLK_KP_POWER,
    kp_percent = c.SDLK_KP_PERCENT,
    kp_less = c.SDLK_KP_LESS,
    kp_greater = c.SDLK_KP_GREATER,
    kp_ampersand = c.SDLK_KP_AMPERSAND,
    kp_dblampersand = c.SDLK_KP_DBLAMPERSAND,
    kp_verticalbar = c.SDLK_KP_VERTICALBAR,
    kp_dblverticalbar = c.SDLK_KP_DBLVERTICALBAR,
    kp_colon = c.SDLK_KP_COLON,
    kp_hash = c.SDLK_KP_HASH,
    kp_space = c.SDLK_KP_SPACE,
    kp_at = c.SDLK_KP_AT,
    kp_exclam = c.SDLK_KP_EXCLAM,
    kp_memstore = c.SDLK_KP_MEMSTORE,
    kp_memrecall = c.SDLK_KP_MEMRECALL,
    kp_memclear = c.SDLK_KP_MEMCLEAR,
    kp_memadd = c.SDLK_KP_MEMADD,
    kp_memsubtract = c.SDLK_KP_MEMSUBTRACT,
    kp_memmultiply = c.SDLK_KP_MEMMULTIPLY,
    kp_memdivide = c.SDLK_KP_MEMDIVIDE,
    kp_plusminus = c.SDLK_KP_PLUSMINUS,
    kp_clear = c.SDLK_KP_CLEAR,
    kp_clearentry = c.SDLK_KP_CLEARENTRY,
    kp_binary = c.SDLK_KP_BINARY,
    kp_octal = c.SDLK_KP_OCTAL,
    kp_decimal = c.SDLK_KP_DECIMAL,
    kp_hexadecimal = c.SDLK_KP_HEXADECIMAL,
    lctrl = c.SDLK_LCTRL,
    lshift = c.SDLK_LSHIFT,
    lalt = c.SDLK_LALT,
    lgui = c.SDLK_LGUI,
    rctrl = c.SDLK_RCTRL,
    rshift = c.SDLK_RSHIFT,
    ralt = c.SDLK_RALT,
    rgui = c.SDLK_RGUI,
    mode = c.SDLK_MODE,
    sleep = c.SDLK_SLEEP,
    wake = c.SDLK_WAKE,
    channel_increment = c.SDLK_CHANNEL_INCREMENT,
    channel_decrement = c.SDLK_CHANNEL_DECREMENT,
    media_play = c.SDLK_MEDIA_PLAY,
    media_pause = c.SDLK_MEDIA_PAUSE,
    media_record = c.SDLK_MEDIA_RECORD,
    media_fast_forward = c.SDLK_MEDIA_FAST_FORWARD,
    media_rewind = c.SDLK_MEDIA_REWIND,
    media_next_track = c.SDLK_MEDIA_NEXT_TRACK,
    media_previous_track = c.SDLK_MEDIA_PREVIOUS_TRACK,
    media_stop = c.SDLK_MEDIA_STOP,
    media_eject = c.SDLK_MEDIA_EJECT,
    media_play_pause = c.SDLK_MEDIA_PLAY_PAUSE,
    media_select = c.SDLK_MEDIA_SELECT,
    ac_new = c.SDLK_AC_NEW,
    ac_open = c.SDLK_AC_OPEN,
    ac_close = c.SDLK_AC_CLOSE,
    ac_exit = c.SDLK_AC_EXIT,
    ac_save = c.SDLK_AC_SAVE,
    ac_print = c.SDLK_AC_PRINT,
    ac_properties = c.SDLK_AC_PROPERTIES,
    ac_search = c.SDLK_AC_SEARCH,
    ac_home = c.SDLK_AC_HOME,
    ac_back = c.SDLK_AC_BACK,
    ac_forward = c.SDLK_AC_FORWARD,
    ac_stop = c.SDLK_AC_STOP,
    ac_refresh = c.SDLK_AC_REFRESH,
    ac_bookmarks = c.SDLK_AC_BOOKMARKS,
    softleft = c.SDLK_SOFTLEFT,
    softright = c.SDLK_SOFTRIGHT,
    call = c.SDLK_CALL,
    endcall = c.SDLK_ENDCALL,
    left_tab = c.SDLK_LEFT_TAB,
    level5_shift = c.SDLK_LEVEL5_SHIFT,
    multi_key_compose = c.SDLK_MULTI_KEY_COMPOSE,
    lmeta = c.SDLK_LMETA,
    rmeta = c.SDLK_RMETA,
    lhyper = c.SDLK_LHYPER,
    rhyper = c.SDLK_RHYPER,

    pub fn getName(self: Keycode) []const u8 {
        return std.mem.sliceTo(c.SDL_GetKeyName(@intFromEnum(self)), 0);
    }

    pub fn getScancode(self: Keycode, modstate: Keymod) Scancode {
        return @enumFromInt(c.SDL_GetScancodeFromKey(@intFromEnum(self), @intFromEnum(modstate)));
    }

    pub fn fromName(name: [:0]const u8) !Keycode {
        const key = c.SDL_GetKeyFromName(name.ptr);
        try errify(key != c.SDLK_UNKNOWN);
        return @enumFromInt(key);
    }
};

pub const Scancode = enum(u32) {
    unknown = c.SDL_SCANCODE_UNKNOWN,
    a = c.SDL_SCANCODE_A,
    b = c.SDL_SCANCODE_B,
    c = c.SDL_SCANCODE_C,
    d = c.SDL_SCANCODE_D,
    e = c.SDL_SCANCODE_E,
    f = c.SDL_SCANCODE_F,
    g = c.SDL_SCANCODE_G,
    h = c.SDL_SCANCODE_H,
    i = c.SDL_SCANCODE_I,
    j = c.SDL_SCANCODE_J,
    k = c.SDL_SCANCODE_K,
    l = c.SDL_SCANCODE_L,
    m = c.SDL_SCANCODE_M,
    n = c.SDL_SCANCODE_N,
    o = c.SDL_SCANCODE_O,
    p = c.SDL_SCANCODE_P,
    q = c.SDL_SCANCODE_Q,
    r = c.SDL_SCANCODE_R,
    s = c.SDL_SCANCODE_S,
    t = c.SDL_SCANCODE_T,
    u = c.SDL_SCANCODE_U,
    v = c.SDL_SCANCODE_V,
    w = c.SDL_SCANCODE_W,
    x = c.SDL_SCANCODE_X,
    y = c.SDL_SCANCODE_Y,
    z = c.SDL_SCANCODE_Z,
    @"1" = c.SDL_SCANCODE_1,
    @"2" = c.SDL_SCANCODE_2,
    @"3" = c.SDL_SCANCODE_3,
    @"4" = c.SDL_SCANCODE_4,
    @"5" = c.SDL_SCANCODE_5,
    @"6" = c.SDL_SCANCODE_6,
    @"7" = c.SDL_SCANCODE_7,
    @"8" = c.SDL_SCANCODE_8,
    @"9" = c.SDL_SCANCODE_9,
    @"0" = c.SDL_SCANCODE_0,
    @"return" = c.SDL_SCANCODE_RETURN,
    escape = c.SDL_SCANCODE_ESCAPE,
    backspace = c.SDL_SCANCODE_BACKSPACE,
    tab = c.SDL_SCANCODE_TAB,
    space = c.SDL_SCANCODE_SPACE,
    minus = c.SDL_SCANCODE_MINUS,
    equals = c.SDL_SCANCODE_EQUALS,
    leftbracket = c.SDL_SCANCODE_LEFTBRACKET,
    rightbracket = c.SDL_SCANCODE_RIGHTBRACKET,
    backslash = c.SDL_SCANCODE_BACKSLASH,
    nonushash = c.SDL_SCANCODE_NONUSHASH,
    _semicolon = c.SDL_SCANCODE_SEMICOLON,
    apostrophe = c.SDL_SCANCODE_APOSTROPHE,
    grave = c.SDL_SCANCODE_GRAVE,
    ode_comma = c.SDL_SCANCODE_COMMA,
    period = c.SDL_SCANCODE_PERIOD,
    slash = c.SDL_SCANCODE_SLASH,
    capslock = c.SDL_SCANCODE_CAPSLOCK,
    f1 = c.SDL_SCANCODE_F1,
    f2 = c.SDL_SCANCODE_F2,
    f3 = c.SDL_SCANCODE_F3,
    f4 = c.SDL_SCANCODE_F4,
    f5 = c.SDL_SCANCODE_F5,
    f6 = c.SDL_SCANCODE_F6,
    f7 = c.SDL_SCANCODE_F7,
    f8 = c.SDL_SCANCODE_F8,
    f9 = c.SDL_SCANCODE_F9,
    f10 = c.SDL_SCANCODE_F10,
    f11 = c.SDL_SCANCODE_F11,
    f12 = c.SDL_SCANCODE_F12,
    printscreen = c.SDL_SCANCODE_PRINTSCREEN,
    scrolllock = c.SDL_SCANCODE_SCROLLLOCK,
    pause = c.SDL_SCANCODE_PAUSE,
    insert = c.SDL_SCANCODE_INSERT,
    ode_home = c.SDL_SCANCODE_HOME,
    pageup = c.SDL_SCANCODE_PAGEUP,
    delete = c.SDL_SCANCODE_DELETE,
    end = c.SDL_SCANCODE_END,
    pagedown = c.SDL_SCANCODE_PAGEDOWN,
    right = c.SDL_SCANCODE_RIGHT,
    left = c.SDL_SCANCODE_LEFT,
    down = c.SDL_SCANCODE_DOWN,
    up = c.SDL_SCANCODE_UP,
    numlockclear = c.SDL_SCANCODE_NUMLOCKCLEAR,
    ode_kp_divide = c.SDL_SCANCODE_KP_DIVIDE,
    kp_multiply = c.SDL_SCANCODE_KP_MULTIPLY,
    kp_minus = c.SDL_SCANCODE_KP_MINUS,
    kp_plus = c.SDL_SCANCODE_KP_PLUS,
    kp_enter = c.SDL_SCANCODE_KP_ENTER,
    kp_1 = c.SDL_SCANCODE_KP_1,
    kp_2 = c.SDL_SCANCODE_KP_2,
    kp_3 = c.SDL_SCANCODE_KP_3,
    kp_4 = c.SDL_SCANCODE_KP_4,
    kp_5 = c.SDL_SCANCODE_KP_5,
    kp_6 = c.SDL_SCANCODE_KP_6,
    kp_7 = c.SDL_SCANCODE_KP_7,
    kp_8 = c.SDL_SCANCODE_KP_8,
    kp_9 = c.SDL_SCANCODE_KP_9,
    kp_0 = c.SDL_SCANCODE_KP_0,
    kp_period = c.SDL_SCANCODE_KP_PERIOD,
    nonusbackslash = c.SDL_SCANCODE_NONUSBACKSLASH,
    ode_application = c.SDL_SCANCODE_APPLICATION,
    cancode_power = c.SDL_SCANCODE_POWER,
    dl_scancode_kp_equals = c.SDL_SCANCODE_KP_EQUALS,
    f13 = c.SDL_SCANCODE_F13,
    f14 = c.SDL_SCANCODE_F14,
    f15 = c.SDL_SCANCODE_F15,
    f16 = c.SDL_SCANCODE_F16,
    f17 = c.SDL_SCANCODE_F17,
    f18 = c.SDL_SCANCODE_F18,
    f19 = c.SDL_SCANCODE_F19,
    f20 = c.SDL_SCANCODE_F20,
    f21 = c.SDL_SCANCODE_F21,
    f22 = c.SDL_SCANCODE_F22,
    f23 = c.SDL_SCANCODE_F23,
    f24 = c.SDL_SCANCODE_F24,
    execute = c.SDL_SCANCODE_EXECUTE,
    help = c.SDL_SCANCODE_HELP,
    menu = c.SDL_SCANCODE_MENU,
    select = c.SDL_SCANCODE_SELECT,
    stop = c.SDL_SCANCODE_STOP,
    again = c.SDL_SCANCODE_AGAIN,
    undo = c.SDL_SCANCODE_UNDO,
    cut = c.SDL_SCANCODE_CUT,
    copy = c.SDL_SCANCODE_COPY,
    paste = c.SDL_SCANCODE_PASTE,
    find = c.SDL_SCANCODE_FIND,
    mute = c.SDL_SCANCODE_MUTE,
    volumeup = c.SDL_SCANCODE_VOLUMEUP,
    volumedown = c.SDL_SCANCODE_VOLUMEDOWN,
    kp_comma = c.SDL_SCANCODE_KP_COMMA,
    kp_equalsas400 = c.SDL_SCANCODE_KP_EQUALSAS400,
    international1 = c.SDL_SCANCODE_INTERNATIONAL1,
    ode_international2 = c.SDL_SCANCODE_INTERNATIONAL2,
    international3 = c.SDL_SCANCODE_INTERNATIONAL3,
    ode_international4 = c.SDL_SCANCODE_INTERNATIONAL4,
    international5 = c.SDL_SCANCODE_INTERNATIONAL5,
    international6 = c.SDL_SCANCODE_INTERNATIONAL6,
    international7 = c.SDL_SCANCODE_INTERNATIONAL7,
    international8 = c.SDL_SCANCODE_INTERNATIONAL8,
    international9 = c.SDL_SCANCODE_INTERNATIONAL9,
    lang1 = c.SDL_SCANCODE_LANG1,
    lang2 = c.SDL_SCANCODE_LANG2,
    lang3 = c.SDL_SCANCODE_LANG3,
    lang4 = c.SDL_SCANCODE_LANG4,
    lang5 = c.SDL_SCANCODE_LANG5,
    lang6 = c.SDL_SCANCODE_LANG6,
    lang7 = c.SDL_SCANCODE_LANG7,
    lang8 = c.SDL_SCANCODE_LANG8,
    lang9 = c.SDL_SCANCODE_LANG9,
    alterase = c.SDL_SCANCODE_ALTERASE,
    sysreq = c.SDL_SCANCODE_SYSREQ,
    cancel = c.SDL_SCANCODE_CANCEL,
    clear = c.SDL_SCANCODE_CLEAR,
    prior = c.SDL_SCANCODE_PRIOR,
    return2 = c.SDL_SCANCODE_RETURN2,
    separator = c.SDL_SCANCODE_SEPARATOR,
    out = c.SDL_SCANCODE_OUT,
    oper = c.SDL_SCANCODE_OPER,
    clearagain = c.SDL_SCANCODE_CLEARAGAIN,
    crsel = c.SDL_SCANCODE_CRSEL,
    exsel = c.SDL_SCANCODE_EXSEL,
    kp_00 = c.SDL_SCANCODE_KP_00,
    kp_000 = c.SDL_SCANCODE_KP_000,
    thousandsseparator = c.SDL_SCANCODE_THOUSANDSSEPARATOR,
    decimalseparator = c.SDL_SCANCODE_DECIMALSEPARATOR,
    currencyunit = c.SDL_SCANCODE_CURRENCYUNIT,
    currencysubunit = c.SDL_SCANCODE_CURRENCYSUBUNIT,
    kp_leftparen = c.SDL_SCANCODE_KP_LEFTPAREN,
    kp_rightparen = c.SDL_SCANCODE_KP_RIGHTPAREN,
    kp_leftbrace = c.SDL_SCANCODE_KP_LEFTBRACE,
    kp_rightbrace = c.SDL_SCANCODE_KP_RIGHTBRACE,
    kp_tab = c.SDL_SCANCODE_KP_TAB,
    kp_backspace = c.SDL_SCANCODE_KP_BACKSPACE,
    kp_a = c.SDL_SCANCODE_KP_A,
    kp_b = c.SDL_SCANCODE_KP_B,
    kp_c = c.SDL_SCANCODE_KP_C,
    kp_d = c.SDL_SCANCODE_KP_D,
    kp_e = c.SDL_SCANCODE_KP_E,
    kp_f = c.SDL_SCANCODE_KP_F,
    kp_xor = c.SDL_SCANCODE_KP_XOR,
    kp_power = c.SDL_SCANCODE_KP_POWER,
    kp_percent = c.SDL_SCANCODE_KP_PERCENT,
    kp_less = c.SDL_SCANCODE_KP_LESS,
    kp_greater = c.SDL_SCANCODE_KP_GREATER,
    kp_ampersand = c.SDL_SCANCODE_KP_AMPERSAND,
    kp_dblampersand = c.SDL_SCANCODE_KP_DBLAMPERSAND,
    kp_verticalbar = c.SDL_SCANCODE_KP_VERTICALBAR,
    kp_dblverticalbar = c.SDL_SCANCODE_KP_DBLVERTICALBAR,
    kp_colon = c.SDL_SCANCODE_KP_COLON,
    kp_hash = c.SDL_SCANCODE_KP_HASH,
    kp_space = c.SDL_SCANCODE_KP_SPACE,
    kp_at = c.SDL_SCANCODE_KP_AT,
    kp_exclam = c.SDL_SCANCODE_KP_EXCLAM,
    kp_memstore = c.SDL_SCANCODE_KP_MEMSTORE,
    kp_memrecall = c.SDL_SCANCODE_KP_MEMRECALL,
    kp_memclear = c.SDL_SCANCODE_KP_MEMCLEAR,
    kp_memadd = c.SDL_SCANCODE_KP_MEMADD,
    kp_memsubtract = c.SDL_SCANCODE_KP_MEMSUBTRACT,
    kp_memmultiply = c.SDL_SCANCODE_KP_MEMMULTIPLY,
    kp_memdivide = c.SDL_SCANCODE_KP_MEMDIVIDE,
    kp_plusminus = c.SDL_SCANCODE_KP_PLUSMINUS,
    kp_clear = c.SDL_SCANCODE_KP_CLEAR,
    kp_clearentry = c.SDL_SCANCODE_KP_CLEARENTRY,
    kp_binary = c.SDL_SCANCODE_KP_BINARY,
    kp_octal = c.SDL_SCANCODE_KP_OCTAL,
    kp_decimal = c.SDL_SCANCODE_KP_DECIMAL,
    kp_hexadecimal = c.SDL_SCANCODE_KP_HEXADECIMAL,
    lctrl = c.SDL_SCANCODE_LCTRL,
    lshift = c.SDL_SCANCODE_LSHIFT,
    lalt = c.SDL_SCANCODE_LALT,
    lgui = c.SDL_SCANCODE_LGUI,
    rctrl = c.SDL_SCANCODE_RCTRL,
    rshift = c.SDL_SCANCODE_RSHIFT,
    ralt = c.SDL_SCANCODE_RALT,
    rgui = c.SDL_SCANCODE_RGUI,
    mode = c.SDL_SCANCODE_MODE,
    de_sleep = c.SDL_SCANCODE_SLEEP,
    wake = c.SDL_SCANCODE_WAKE,
    channel_increment = c.SDL_SCANCODE_CHANNEL_INCREMENT,
    channel_decrement = c.SDL_SCANCODE_CHANNEL_DECREMENT,
    media_play = c.SDL_SCANCODE_MEDIA_PLAY,
    media_pause = c.SDL_SCANCODE_MEDIA_PAUSE,
    media_record = c.SDL_SCANCODE_MEDIA_RECORD,
    media_fast_forward = c.SDL_SCANCODE_MEDIA_FAST_FORWARD,
    media_rewind = c.SDL_SCANCODE_MEDIA_REWIND,
    media_next_track = c.SDL_SCANCODE_MEDIA_NEXT_TRACK,
    media_previous_track = c.SDL_SCANCODE_MEDIA_PREVIOUS_TRACK,
    media_stop = c.SDL_SCANCODE_MEDIA_STOP,
    media_eject = c.SDL_SCANCODE_MEDIA_EJECT,
    media_play_pause = c.SDL_SCANCODE_MEDIA_PLAY_PAUSE,
    media_select = c.SDL_SCANCODE_MEDIA_SELECT,
    ac_new = c.SDL_SCANCODE_AC_NEW,
    ac_open = c.SDL_SCANCODE_AC_OPEN,
    ac_close = c.SDL_SCANCODE_AC_CLOSE,
    ac_exit = c.SDL_SCANCODE_AC_EXIT,
    ac_save = c.SDL_SCANCODE_AC_SAVE,
    ac_print = c.SDL_SCANCODE_AC_PRINT,
    ac_properties = c.SDL_SCANCODE_AC_PROPERTIES,
    ac_search = c.SDL_SCANCODE_AC_SEARCH,
    ac_home = c.SDL_SCANCODE_AC_HOME,
    ac_back = c.SDL_SCANCODE_AC_BACK,
    ac_forward = c.SDL_SCANCODE_AC_FORWARD,
    ac_stop = c.SDL_SCANCODE_AC_STOP,
    ac_refresh = c.SDL_SCANCODE_AC_REFRESH,
    ac_bookmarks = c.SDL_SCANCODE_AC_BOOKMARKS,
    de_softleft = c.SDL_SCANCODE_SOFTLEFT,
    softright = c.SDL_SCANCODE_SOFTRIGHT,
    call = c.SDL_SCANCODE_CALL,
    endcall = c.SDL_SCANCODE_ENDCALL,

    pub fn getName(self: Scancode) []const u8 {
        return std.mem.sliceTo(c.SDL_GetScancodeName(@intFromEnum(self)), 0);
    }

    pub fn setName(self: Scancode, name: [:0]const u8) !void {
        try errify(c.SDL_SetScancodeName(@intFromEnum(self), name.ptr));
    }

    pub fn getKey(self: Scancode, modstate: Keymod, key_event: bool) Keycode {
        return @enumFromInt(c.SDL_GetKeyFromScancode(@intFromEnum(self), @intFromEnum(modstate), key_event));
    }

    pub fn fromName(name: [:0]const u8) !Scancode {
        const scancode = c.SDL_GetScancodeFromName(name.ptr);
        try errify(scancode != c.SDL_SCANCODE_UNKNOWN);
        return @enumFromInt(scancode);
    }
};

pub const Keymod = enum(u16) {
    none = c.SDL_KMOD_NONE,
    lshift = c.SDL_KMOD_LSHIFT,
    rshift = c.SDL_KMOD_RSHIFT,
    level5 = c.SDL_KMOD_LEVEL5,
    lctrl = c.SDL_KMOD_LCTRL,
    rctrl = c.SDL_KMOD_RCTRL,
    lalt = c.SDL_KMOD_LALT,
    ralt = c.SDL_KMOD_RALT,
    lgui = c.SDL_KMOD_LGUI,
    rgui = c.SDL_KMOD_RGUI,
    num = c.SDL_KMOD_NUM,
    caps = c.SDL_KMOD_CAPS,
    mode = c.SDL_KMOD_MODE,
    scroll = c.SDL_KMOD_SCROLL,
    ctrl = c.SDL_KMOD_CTRL,
    shift = c.SDL_KMOD_SHIFT,
    alt = c.SDL_KMOD_ALT,
    gui = c.SDL_KMOD_GUI,

    pub fn getState() Keymod {
        return @enumFromInt(c.SDL_GetModState());
    }

    pub fn setState(self: Keymod) void {
        c.SDL_SetModState(@intFromEnum(self));
    }
};

pub const Keyboard = struct {
    id: KeyboardID,

    pub fn getName(self: *const Keyboard) ?[]const u8 {
        if (c.SDL_GetKeyboardNameForID(self.id)) |name_ptr| {
            return std.mem.sliceTo(name_ptr, 0);
        }
        return null;
    }
};

pub fn hasKeyboard() bool {
    return c.SDL_HasKeyboard();
}

pub fn getKeyboards() ![]Keyboard {
    var count: c_int = undefined;
    var keyboard_ids = try errify(c.SDL_GetKeyboards(&count));
    return @ptrCast(keyboard_ids[0..@intCast(count)]);
}

pub fn getKeyboardFocus() ?Window {
    if (c.SDL_GetKeyboardFocus()) |window_ptr| {
        return Window{ .ptr = window_ptr };
    }
    return null;
}

pub fn getKeyboardState(numkeys: ?*c_int) ![]const bool {
    const state = c.SDL_GetKeyboardState(numkeys);
    if (state == null) return error.SDLError;
    const len = if (numkeys) |n| @as(usize, @intCast(n.*)) else 512;
    return @ptrCast(state[0..len]);
}

pub fn resetKeyboard() void {
    c.SDL_ResetKeyboard();
}

pub fn startTextInput(window: *const Window) !void {
    try errify(c.SDL_StartTextInput(window.ptr));
}

pub fn startTextInputWithProperties(window: *const Window, props: PropertiesID) !void {
    try errify(c.SDL_StartTextInputWithProperties(window.ptr, props));
}

pub fn textInputActive(window: *const Window) bool {
    return c.SDL_TextInputActive(window.ptr);
}

pub fn stopTextInput(window: *const Window) !void {
    try errify(c.SDL_StopTextInput(window.ptr));
}

pub fn clearComposition(window: *const Window) !void {
    try errify(c.SDL_ClearComposition(window.ptr));
}

pub fn setTextInputArea(window: *const Window, rectangle: *const Rectangle, cursor: c_int) !void {
    try errify(c.SDL_SetTextInputArea(window.ptr, @ptrCast(rectangle), cursor));
}

pub fn getTextInputArea(window: *const Window, cursor: ?*c_int) !Rectangle {
    var rectangle: Rectangle = undefined;
    try errify(c.SDL_GetTextInputArea(window.ptr, @ptrCast(&rectangle), cursor));
    return rectangle;
}

pub fn hasScreenKeyboardSupport() bool {
    return c.SDL_HasScreenKeyboardSupport();
}

pub fn screenKeyboardShown(window: *const Window) bool {
    return c.SDL_ScreenKeyboardShown(window.ptr);
}
