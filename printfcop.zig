// © 2025 Carl Åstholm
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice (including the
// next paragraph) shall be included in all copies or substantial portions
// of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

const std = @import("std");

pub fn toPrintfArgs(
    comptime features: PrintfFeatures,
    comptime format: [:0]const u8,
    args: anytype,
) PrintfArgs(features, format) {
    const Args = @TypeOf(args);
    const is_tuple = switch (@typeInfo(Args)) {
        .@"struct" => |info| info.is_tuple,
        else => false,
    };
    if (!is_tuple) {
        @compileError("expected a tuple, found '" ++ @typeName(Args) ++ "'");
    }
    var printf_args: PrintfArgs(features, format) = undefined;
    if (args.len != printf_args.len) {
        const expected = comptime stringFromInt(printf_args.len);
        const actual = comptime stringFromInt(args.len);
        @compileError("expected " ++ expected ++ " format argument(s), found " ++ actual);
    }
    inline for (&printf_args, args) |*printf_arg, arg| {
        printf_arg.* = arg;
    }
    return printf_args;
}

test toPrintfArgs {
    const c = struct {
        extern fn snprintf(noalias s: ?[*]u8, n: usize, noalias format: [*:0]const u8, ...) c_int;
    };

    const zig = struct {
        fn snprintf(sn: ?[]u8, comptime format: [:0]const u8, args: anytype) !usize {
            const s: ?[*]u8, const n: usize = if (sn) |x| .{ x.ptr, x.len } else .{ null, 0 };
            const result = @call(.auto, c.snprintf, .{ s, n, format } ++ toPrintfArgs(.c99, format, args));
            return if (result < 0) error.PrintfError else @intCast(result);
        }
    };

    var lucky: c_ushort = 0;
    lucky = 17;

    var sn: [255:0]u8 = undefined;
    const written = try zig.snprintf(&sn, "Hi %s! Your lucky number is: %hu", .{ "Bob", lucky });

    try std.testing.expectEqualStrings("Hi Bob! Your lucky number is: 17", sn[0..written :0]);
}

pub const PrintfFeatures = struct {
    flags: Flags = .{},
    argument_supplied_field_width: bool = false,
    max_field_width: c_int = -1,
    argument_supplied_precision: bool = false,
    max_precision: c_int = -1,
    int_length_modifiers: IntLengthModifiers = .{},
    float_length_modifiers: FloatLengthModifiers = .{},
    conversion_specifiers: ConversionSpecifiers = .{},

    pub const Flags = struct {
        @"-": bool = false,
        @"+": bool = false,
        @" ": bool = false,
        @"#": bool = false,
        @"0": bool = false,
    };

    pub const IntLengthModifiers = struct {
        hh: bool = false,
        h: bool = false,
        l: bool = false,
        ll: bool = false,
        z: bool = false,
        w8: bool = false,
        w16: bool = false,
        w32: bool = false,
        w64: bool = false,
    };

    pub const FloatLengthModifiers = struct {
        l: bool = false,
        L: bool = false,
    };

    pub const ConversionSpecifiers = struct {
        d: bool = false,
        i: bool = false,
        b: bool = false,
        B: bool = false,
        o: bool = false,
        u: bool = false,
        x: bool = false,
        X: bool = false,
        f: bool = false,
        F: bool = false,
        e: bool = false,
        E: bool = false,
        g: bool = false,
        G: bool = false,
        a: bool = false,
        A: bool = false,
        c: bool = false,
        s: bool = false,
        p: bool = false,
        n: bool = false,
    };

    /// ISO/IEC 9899:1990
    ///
    /// `#undef __STDC_VERSION__`
    pub const c89: PrintfFeatures = .{
        .flags = .{
            .@"-" = true,
            .@"+" = true,
            .@" " = true,
            .@"#" = true,
            .@"0" = true,
        },
        .argument_supplied_field_width = true,
        .max_field_width = std.math.maxInt(c_int),
        .argument_supplied_precision = true,
        .max_precision = std.math.maxInt(c_int),
        .int_length_modifiers = .{
            .h = true,
            .l = true,
        },
        .float_length_modifiers = .{
            .L = true,
        },
        .conversion_specifiers = .{
            .d = true,
            .i = true,
            .o = true,
            .u = true,
            .x = true,
            .X = true,
            .f = true,
            .e = true,
            .E = true,
            .g = true,
            .G = true,
            .c = true,
            .s = true,
            .p = true,
            .n = true,
        },
    };

    /// ISO/IEC 9899:1990/AMD1:1995
    ///
    /// `#define __STDC_VERSION__ 199409L`
    pub const c94: PrintfFeatures = c94: {
        break :c94 c89;
    };

    /// ISO/IEC 9899:1999
    ///
    /// `#define __STDC_VERSION__ 199901L`
    pub const c99: PrintfFeatures = c99: {
        var x = c89;
        x.int_length_modifiers.hh = true;
        x.int_length_modifiers.ll = true;
        x.int_length_modifiers.z = true;
        x.float_length_modifiers.l = true;
        x.conversion_specifiers.F = true;
        x.conversion_specifiers.a = true;
        x.conversion_specifiers.A = true;
        break :c99 x;
    };

    /// ISO/IEC 9899:2011
    ///
    /// `#define __STDC_VERSION__ 201112L`
    pub const c11: PrintfFeatures = c11: {
        break :c11 c99;
    };

    /// ISO/IEC 9899:2018
    ///
    /// `#define __STDC_VERSION__ 201710L`
    pub const c17: PrintfFeatures = c17: {
        break :c17 c11;
    };

    /// ISO/IEC 9899:2024
    ///
    /// `#define __STDC_VERSION__ 202311L`
    pub const c23: PrintfFeatures = c23: {
        var x = c99;
        x.int_length_modifiers.w8 = true;
        x.int_length_modifiers.w16 = true;
        x.int_length_modifiers.w32 = true;
        x.int_length_modifiers.w64 = true;
        x.conversion_specifiers.b = true;
        x.conversion_specifiers.B = true;
        break :c23 x;
    };
};

pub inline fn pri(
    comptime specifier: PrintfIntConversionSpecifier,
    comptime bits: u16,
) [:0]const u8 {
    return comptime result: {
        const modifier: []const u8 = if (bits == @typeInfo(u8).int.bits)
            "hh"
        else if (bits == @typeInfo(c_short).int.bits)
            "h"
        else if (bits == @typeInfo(c_int).int.bits)
            ""
        else if (bits == @typeInfo(c_long).int.bits)
            "l"
        else if (bits == @typeInfo(c_longlong).int.bits)
            "ll"
        else
            "w" ++ stringFromInt(bits);
        break :result modifier ++ @tagName(specifier);
    };
}

test pri {
    const int64_t: type = inline for (.{ c_short, c_int, c_long, c_longlong }) |T| {
        if (@typeInfo(T).int.bits == 64) break T;
    } else i64;

    switch (int64_t) {
        c_long => {
            try std.testing.expectEqualStrings(
                "found %ld element(s) at offset %#lx (checksum: %.2hhx)",
                "found %" ++ pri(.d, 64) ++ " element(s) at offset %#" ++ pri(.x, 64) ++ " (checksum: %.2" ++ pri(.x, 8) ++ ")",
            );
        },
        c_longlong => {
            try std.testing.expectEqualStrings(
                "found %lld element(s) at offset %#llx (checksum: %.2hhx)",
                "found %" ++ pri(.d, 64) ++ " element(s) at offset %#" ++ pri(.x, 64) ++ " (checksum: %.2" ++ pri(.x, 8) ++ ")",
            );
        },
        else => return error.SkipZigTest,
    }
}

pub const PrintfIntConversionSpecifier = enum { d, i, b, B, o, u, x, X };

pub fn PrintfArgs(
    comptime features: PrintfFeatures,
    comptime format: [:0]const u8,
) type {
    var Args: []const type = &.{};
    {
        var i: usize = 0;
        next_directive: while (i < format.len) : (i += 1) check_directive: switch (format[i]) {
            '%' => {
                const specification_start = i;
                i += 1;

                if (format[i] == '%') {
                    continue :next_directive;
                }

                var note: ?[]const u8 = null;

                const Flags = struct { @"-": bool = false, @"+": bool = false, @" ": bool = false, @"#": bool = false, @"0": bool = false };
                var flags: Flags = .{};
                check_flag: switch (format[i]) {
                    '-', '+', ' ', '#', '0' => {
                        const field_name = format[i..][0..1];
                        if (!@field(features.flags, field_name)) {
                            note = note orelse "unsupported flag '" ++ field_name ++ "'";
                        } else if (@field(flags, field_name)) {
                            note = note orelse "duplicate flag '" ++ field_name ++ "'";
                        }
                        @field(flags, field_name) = true;
                        i += 1;
                        continue :check_flag format[i];
                    },
                    else => {},
                }
                if (flags.@" " and flags.@"+") {
                    note = note orelse "flag ' ' ignored with flag '+'";
                } else if (flags.@"0" and flags.@"-") {
                    note = note orelse "flag '0' ignored with flag '-'";
                }

                var has_field_width = false;
                switch (format[i]) {
                    '*' => {
                        if (!features.argument_supplied_field_width) {
                            note = note orelse "argument-supplied field width not supported";
                        }
                        Args = Args ++ .{c_int};
                        has_field_width = true;
                        i += 1;
                    },
                    '1'...'9' => {
                        if (features.max_field_width < 1) {
                            note = note orelse "field width not supported";
                        }
                        if (parseFormatStringInt(format, &i)) |n| {
                            if (n > features.max_field_width) {
                                note = note orelse "field width exceeds maximum allowed value " ++ stringFromInt(features.max_field_width);
                            }
                        } else {
                            note = note orelse "field width not representable by type 'c_int'";
                        }
                        has_field_width = true;
                    },
                    else => {},
                }
                if (flags.@"-" and !has_field_width) {
                    note = note orelse "flag '-' redundant without field width";
                }

                var has_precision = false;
                if (format[i] == '.') {
                    has_precision = true;
                    i += 1;
                    check_precision: switch (format[i]) {
                        '*' => {
                            if (!features.argument_supplied_precision) {
                                note = note orelse "argument-supplied precision not supported";
                            }
                            Args = Args ++ .{c_int};
                            i += 1;
                        },
                        '0' => {
                            i += 1;
                            switch (format[i]) {
                                '0'...'9' => {
                                    note = note orelse "precision has leading zero(s)";
                                },
                                else => {},
                            }
                            continue :check_precision '1';
                        },
                        else => {
                            if (features.max_precision < 0) {
                                note = note orelse "precision not supported";
                            }
                            if (parseFormatStringInt(format, &i)) |n| {
                                if (n > features.max_precision) {
                                    note = note orelse "precision exceeds maximum allowed value " ++ stringFromInt(features.max_field_width);
                                }
                            } else {
                                note = note orelse "precision not representable by type 'c_int'";
                            }
                        },
                    }
                }

                const modifier_start = i;
                const Modifier = union(enum) { none, hh, h, l, ll, j, z, t, w: c_int, wf: c_int, L, H, D, DD };
                var modifier: Modifier = .none;
                switch (format[i]) {
                    'h', 'l', 'D' => |x| {
                        i += 1;
                        if (format[i] == x) {
                            i += 1;
                        }
                        modifier = @unionInit(Modifier, format[modifier_start..i], {});
                    },
                    'j', 'z', 't', 'L', 'H' => {
                        i += 1;
                        modifier = @unionInit(Modifier, format[modifier_start..i], {});
                    },
                    'w' => {
                        i += 1;
                        if (format[i] == 'f') {
                            i += 1;
                        }
                        const field_name = format[modifier_start..i];
                        var bits: c_int = 0;
                        check_bits: switch (format[i]) {
                            '0' => {
                                i += 1;
                                switch (format[i]) {
                                    '0'...'9' => {
                                        note = note orelse "bit width has leading zero(s)";
                                    },
                                    else => {
                                        note = note orelse "bit width is 0";
                                    },
                                }
                                continue :check_bits '1';
                            },
                            '1'...'9' => if (parseFormatStringInt(format, &i)) |n| {
                                bits = n;
                            } else {
                                note = note orelse "bit width not representable by type 'c_int'";
                            },
                            else => {
                                note = note orelse "missing bit width";
                            },
                        }
                        modifier = @unionInit(Modifier, field_name, bits);
                    },
                    else => {},
                }

                if (i < format.len and format[i] == 0) {
                    continue :check_directive 0;
                }

                note = note orelse fail: {
                    const specifier = format[i..][0..1];
                    if (@hasField(PrintfFeatures.ConversionSpecifiers, specifier) and !@field(features.conversion_specifiers, specifier)) {
                        break :fail "unsupported conversion specifier '" ++ specifier ++ "'";
                    }
                    check_specifier: switch (specifier[0]) {
                        'd', 'i' => {
                            if (flags.@"#") {
                                break :fail "flag '#' used with conversion specifier '" ++ specifier ++ "'";
                            }
                            const have = features.int_length_modifiers;
                            const Arg: type = m: switch (modifier) {
                                .none => c_int,
                                .hh => if (!have.hh) continue :m .j else i8,
                                .h => if (!have.h) continue :m .j else c_short,
                                .l => if (!have.l) continue :m .j else c_long,
                                .ll => if (!have.ll) continue :m .j else c_longlong,
                                .z => if (!have.z) continue :m .j else isize,
                                .w => |bits| b: switch (bits) {
                                    8 => if (!have.w8) continue :b 0 else i8,
                                    16 => if (!have.w16) continue :b 0 else i16,
                                    32 => if (!have.w32) continue :b 0 else i32,
                                    64 => if (!have.w64) continue :b 0 else i64,
                                    else => break :fail "unsupported bit width",
                                },
                                .j, .t, .wf => break :fail "unsupported conversion specifier '" ++ format[modifier_start..(i + 1)] ++ "'",
                                else => break :fail null,
                            };
                            Args = Args ++ .{Arg};
                        },
                        'u' => if (flags.@"#") {
                            break :fail "flag '#' used with conversion specifier 'u'";
                        } else {
                            continue :check_specifier 'b';
                        },
                        'b', 'B', 'o', 'x', 'X' => {
                            if (@as(?[]const u8, if (flags.@"+") "+" else if (flags.@" ") " " else null)) |flag| {
                                break :fail "flag '" ++ flag ++ "' used with conversion specifier '" ++ specifier ++ "'";
                            }
                            const have = features.int_length_modifiers;
                            const Arg: type = m: switch (modifier) {
                                .none => c_uint,
                                .hh => if (!have.hh) continue :m .j else u8,
                                .h => if (!have.h) continue :m .j else c_ushort,
                                .l => if (!have.l) continue :m .j else c_ulong,
                                .ll => if (!have.ll) continue :m .j else c_ulonglong,
                                .z => if (!have.z) continue :m .j else usize,
                                .w => |bits| b: switch (bits) {
                                    8 => if (!have.w8) continue :b 0 else u8,
                                    16 => if (!have.w16) continue :b 0 else u16,
                                    32 => if (!have.w32) continue :b 0 else u32,
                                    64 => if (!have.w64) continue :b 0 else u64,
                                    else => break :fail "unsupported bit width",
                                },
                                .j, .t, .wf => break :fail "unsupported conversion specifier '" ++ format[modifier_start..(i + 1)] ++ "'",
                                else => break :fail null,
                            };
                            Args = Args ++ .{Arg};
                        },
                        'f', 'F', 'e', 'E', 'g', 'G', 'a', 'A' => {
                            const have = features.float_length_modifiers;
                            const Arg: type = m: switch (modifier) {
                                .none => f64, // default argument promotions
                                .l => if (!have.l) continue :m .H else f64,
                                .L => if (!have.L) continue :m .H else c_longdouble,
                                .H, .D, .DD => break :fail "unsupported conversion specifier '" ++ format[modifier_start..(i + 1)] ++ "'",
                                else => break :fail null,
                            };
                            Args = Args ++ .{Arg};
                        },
                        'c' => {
                            if (@as(?[]const u8, if (flags.@"+") "+" else if (flags.@" ") " " else if (flags.@"#") "#" else if (flags.@"0") "0" else null)) |flag| {
                                break :fail "flag '" ++ flag ++ "' used with conversion specifier 'c'";
                            }
                            if (has_precision) {
                                break :fail "precision used with conversion specifier 'c'";
                            }
                            const Arg: type = switch (modifier) {
                                .none => c_int,
                                .l => break :fail "unsupported conversion specifier '" ++ format[modifier_start..(i + 1)] ++ "'",
                                else => break :fail null,
                            };
                            Args = Args ++ .{Arg};
                        },
                        's' => {
                            if (@as(?[]const u8, if (flags.@"+") "+" else if (flags.@" ") " " else if (flags.@"#") "#" else if (flags.@"0") "0" else null)) |flag| {
                                break :fail "flag '" ++ flag ++ "' used with conversion specifier 's'";
                            }
                            const Arg: type = switch (modifier) {
                                .none => [*:0]const u8,
                                .l => break :fail "unsupported conversion specifier '" ++ format[modifier_start..(i + 1)] ++ "'",
                                else => break :fail null,
                            };
                            Args = Args ++ .{Arg};
                        },
                        'p' => {
                            if (@as(?[]const u8, if (flags.@"+") "+" else if (flags.@" ") " " else if (flags.@"#") "#" else if (flags.@"0") "0" else null)) |flag| {
                                break :fail "flag '" ++ flag ++ "' used with conversion specifier 'p'";
                            }
                            if (has_precision) {
                                break :fail "precision used with conversion specifier 'p'";
                            }
                            if (modifier != .none) {
                                break :fail null;
                            }
                            Args = Args ++ .{?*const anyopaque};
                        },
                        'n' => {
                            if (flags.@"-" or flags.@"+" or flags.@" " or flags.@"#" or flags.@"0") {
                                break :fail "flag(s) used with conversion specifier 'n'";
                            }
                            if (has_field_width) {
                                break :fail "field width used with conversion specifier 'n'";
                            }
                            if (has_precision) {
                                break :fail "precision used with conversion specifier 'n'";
                            }
                            const have = features.int_length_modifiers;
                            const Arg: type = m: switch (modifier) {
                                .none => *c_int,
                                .hh => if (!have.hh) continue :m .j else *i8,
                                .h => if (!have.h) continue :m .j else *c_short,
                                .l => if (!have.l) continue :m .j else *c_long,
                                .ll => if (!have.ll) continue :m .j else *c_longlong,
                                .z => if (!have.z) continue :m .j else *isize,
                                .w => |bits| b: switch (bits) {
                                    8 => if (!have.w8) continue :b 0 else *i8,
                                    16 => if (!have.w16) continue :b 0 else *i16,
                                    32 => if (!have.w32) continue :b 0 else *i32,
                                    64 => if (!have.w64) continue :b 0 else *i64,
                                    else => break :fail "unsupported bit width",
                                },
                                .j, .t, .wf => break :fail "unsupported conversion specifier '" ++ format[modifier_start..(i + 1)] ++ "'",
                                else => break :fail null,
                            };
                            Args = Args ++ .{Arg};
                        },
                        else => if (std.ascii.isPrint(specifier[0]) and specifier[0] != '%') {
                            break :fail null;
                        } else {
                            break :fail "missing conversion specifier";
                        },
                    }
                    continue :next_directive;
                };

                const specification: []const u8 = if (std.ascii.isPrint(format[i]) and format[i] != '%')
                    format[specification_start..(i + 1)]
                else
                    format[specification_start..i];

                const invalid_specification: []const u8 = if (note) |details|
                    "invalid conversion specification '" ++ specification ++ "': " ++ details
                else
                    "invalid conversion specification '" ++ specification ++ "'";

                @compileError(invalid_specification);
            },
            0 => @compileError("format contains embedded null byte(s)"),
            else => {},
        };
    }
    var tuple_fields: [Args.len]std.builtin.Type.StructField = undefined;
    for (&tuple_fields, Args, 0..) |*field, Arg, i| {
        field.* = .{
            .name = stringFromInt(i),
            .type = Arg,
            .default_value_ptr = null,
            .is_comptime = false,
            .alignment = 0,
        };
    }
    return @Type(.{ .@"struct" = .{
        .layout = .auto,
        .fields = &tuple_fields,
        .decls = &.{},
        .is_tuple = true,
    } });
}

test PrintfArgs {
    const Args = PrintfArgs(.c99, "All your %ld codebase(s) are belong to %s.");
    const args_info = @typeInfo(Args).@"struct";
    try std.testing.expect(args_info.is_tuple);
    try std.testing.expectEqual(2, args_info.fields.len);
    try std.testing.expectEqual(c_long, args_info.fields[0].type);
    try std.testing.expectEqual([*:0]const u8, args_info.fields[1].type);
}

fn parseFormatStringInt(format: [:0]const u8, i: *usize) ?c_int {
    var result: c_uint = 0;
    check_digit: switch (format[i.*]) {
        '0'...'9' => |x| {
            result *|= 10;
            result +|= x - '0';
            i.* += 1;
            continue :check_digit format[i.*];
        },
        else => {},
    }
    return if (result <= std.math.maxInt(c_int)) @intCast(result) else null;
}

inline fn stringFromInt(comptime n: comptime_int) [:0]const u8 {
    return comptime result: {
        var s: [:0]const u8 = "";
        var a = @abs(n);
        while (true) {
            const digit = a % 10;
            a /= 10;
            s = .{'0' + digit} ++ s;
            if (a == 0) {
                if (n < 0) {
                    s = "-" ++ s;
                }
                break :result s;
            }
        }
    };
}
