// © 2025 Carl Åstholm
// SPDX-License-Identifier: MIT

const std = @import("std");
const printfcop = @import("printfcop.zig");

comptime {
    _ = printfcop;
}

test "escape sequences" {
    const printf_args = printfcop.toPrintfArgs(.c23, "%% %% %%", .{});
    try std.testing.expect(@typeInfo(@TypeOf(printf_args)).@"struct".is_tuple);
    try std.testing.expectEqual(0, printf_args.len);
}

test "all supported specifiers" {
    var n: c_int = 0;
    var hhn: i8 = 0;
    var hn: c_short = 0;
    var ln: c_long = 0;
    var lln: c_longlong = 0;
    var zn: isize = 0;
    var w8n: i8 = 0;
    var w16n: i16 = 0;
    var w32n: i32 = 0;
    var w64n: i64 = 0;
    const format =
        "%d%hhd%hd%ld%lld%zd%w8d%w16d%w32d%w64d" ++
        "%i%hhi%hi%li%lli%zi%w8i%w16i%w32i%w64i" ++
        "%b%hhb%hb%lb%llb%zb%w8b%w16b%w32b%w64b" ++
        "%B%hhB%hB%lB%llB%zB%w8B%w16B%w32B%w64B" ++
        "%o%hho%ho%lo%llo%zo%w8o%w16o%w32o%w64o" ++
        "%u%hhu%hu%lu%llu%zu%w8u%w16u%w32u%w64u" ++
        "%x%hhx%hx%lx%llx%zx%w8x%w16x%w32x%w64x" ++
        "%X%hhX%hX%lX%llX%zX%w8X%w16X%w32X%w64X" ++
        "%f%lf%Lf%F%lF%LF" ++
        "%e%le%Le%E%lE%LE" ++
        "%g%lg%Lg%G%lG%LG" ++
        "%a%la%La%A%lA%LA" ++
        "%c%s%p" ++
        "%n%hhn%hn%ln%lln%zn%w8n%w16n%w32n%w64n";
    // zig fmt: off
    const args =
        .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 } ++
        .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 } ++
        .{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 } ++
        .{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 } ++
        .{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 } ++
        .{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 } ++
        .{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 } ++
        .{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 } ++
        .{ 0.5, 0.5, 0.5, 0.5, 0.5, 0.5 } ++
        .{ 0.5, 0.5, 0.5, 0.5, 0.5, 0.5 } ++
        .{ 0.5, 0.5, 0.5, 0.5, 0.5, 0.5 } ++
        .{ 0.5, 0.5, 0.5, 0.5, 0.5, 0.5 } ++
        .{ 'A', "ABC", null } ++
        .{ &n, &hhn, &hn, &ln, &lln, &zn, &w8n, &w16n, &w32n, &w64n };
    // zig fmt: on

    // zig fmt: off
    const expected_printf_args =
        .{ @as(c_int, -1), @as(i8, -1), @as(c_short, -1), @as(c_long, -1), @as(c_longlong, -1) } ++
        .{ @as(isize, -1), @as(i8, -1), @as(i16,     -1), @as(i32,    -1), @as(i64,        -1) } ++
        .{ @as(c_int, -1), @as(i8, -1), @as(c_short, -1), @as(c_long, -1), @as(c_longlong, -1) } ++
        .{ @as(isize, -1), @as(i8, -1), @as(i16,     -1), @as(i32,    -1), @as(i64,        -1) } ++
        .{ @as(c_uint, 255), @as(u8, 255), @as(c_ushort, 255), @as(c_ulong, 255), @as(c_ulonglong, 255) } ++
        .{ @as(usize,  255), @as(u8, 255), @as(u16,      255), @as(u32,     255), @as(u64,         255) } ++
        .{ @as(c_uint, 255), @as(u8, 255), @as(c_ushort, 255), @as(c_ulong, 255), @as(c_ulonglong, 255) } ++
        .{ @as(usize,  255), @as(u8, 255), @as(u16,      255), @as(u32,     255), @as(u64,         255) } ++
        .{ @as(c_uint, 255), @as(u8, 255), @as(c_ushort, 255), @as(c_ulong, 255), @as(c_ulonglong, 255) } ++
        .{ @as(usize,  255), @as(u8, 255), @as(u16,      255), @as(u32,     255), @as(u64,         255) } ++
        .{ @as(c_uint, 255), @as(u8, 255), @as(c_ushort, 255), @as(c_ulong, 255), @as(c_ulonglong, 255) } ++
        .{ @as(usize,  255), @as(u8, 255), @as(u16,      255), @as(u32,     255), @as(u64,         255) } ++
        .{ @as(c_uint, 255), @as(u8, 255), @as(c_ushort, 255), @as(c_ulong, 255), @as(c_ulonglong, 255) } ++
        .{ @as(usize,  255), @as(u8, 255), @as(u16,      255), @as(u32,     255), @as(u64,         255) } ++
        .{ @as(c_uint, 255), @as(u8, 255), @as(c_ushort, 255), @as(c_ulong, 255), @as(c_ulonglong, 255) } ++
        .{ @as(usize,  255), @as(u8, 255), @as(u16,      255), @as(u32,     255), @as(u64,         255) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(f64, 0.5), @as(f64, 0.5), @as(c_longdouble, 0.5) } ++
        .{ @as(u8, 'A'), @as([*:0]const u8, "ABC"), @as(?*const anyopaque, null) } ++
        .{ @as(*c_int, &n),  @as(*i8, &hhn), @as(*c_short, &hn),   @as(*c_long, &ln),   @as(*c_longlong, &lln)  } ++
        .{ @as(*isize, &zn), @as(*i8, &w8n), @as(*i16,     &w16n), @as(*i32,    &w32n), @as(*i64,        &w64n) };
    // zig fmt: on

    const printf_args = printfcop.toPrintfArgs(.c23, format, args);
    try std.testing.expect(@typeInfo(@TypeOf(printf_args)).@"struct".is_tuple);
    try std.testing.expectEqual(expected_printf_args.len, printf_args.len);
    inline for (expected_printf_args, printf_args) |expected, actual| {
        try std.testing.expectEqual(expected, actual);
        try std.testing.expectEqual(@TypeOf(expected), @TypeOf(actual));
    }
}
