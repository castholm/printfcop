// © 2025 Carl Åstholm
// SPDX-License-Identifier: MIT

const printfcop = @import("printfcop.zig");

pub fn main() void {
    testToPrintfArgs("abc xyz", @as(S, .{}));
    testToPrintfArgs("%d %d %d %d", .{ 1, 2 });

    testPrintfArgs(p0, "%-+ #09.9lf");
    testPrintfArgs(p1, "%-+-+9.9lf");
    testPrintfArgs(p1, "%-+ 09.9lf");
    testPrintfArgs(p1, "%-09.9lf");
    testPrintfArgs(p0, "%*.9lf");
    testPrintfArgs(p0, "%1.9lf");
    testPrintfArgs(p1, "%-101.9lf");
    testPrintfArgs(p1, "%-9999999999999999999999999999999999999999.9lf");
    testPrintfArgs(p1, "%-.9lf");
    testPrintfArgs(p0, "%.*f");
    testPrintfArgs(p1, "%-9.00lf");
    testPrintfArgs(p0, "%.f");
    testPrintfArgs(p1, "%-9.101lf");
    testPrintfArgs(p1, "%-9.9999999999999999999999999999999999999999lf");
    testPrintfArgs(p1, "%-9.9w00d");
    testPrintfArgs(p1, "%-9.9w0d");
    testPrintfArgs(p1, "%-9.9w9999999999999999999999999999999999999999d");
    testPrintfArgs(p1, "%-9.9wd");
    testPrintfArgs(p0, "%d");
    testPrintfArgs(p1, "%-#9.9ld");
    testPrintfArgs(p1, "%-9.9lld");
    testPrintfArgs(p1, "%-9.9w64d");
    testPrintfArgs(p1, "%-9.9w99d");
    testPrintfArgs(p1, "%-9.9jd");
    testPrintfArgs(p1, "%-9.9td");
    testPrintfArgs(p1, "%-9.9wf32d");
    testPrintfArgs(p1, "%-9.9Hd");
    testPrintfArgs(p1, "%-#9.9lu");
    testPrintfArgs(p1, "%- 9.9lu");
    testPrintfArgs(p1, "%-9.9llu");
    testPrintfArgs(p1, "%-9.9w64u");
    testPrintfArgs(p1, "%-9.9w99u");
    testPrintfArgs(p1, "%-9.9ju");
    testPrintfArgs(p1, "%-9.9tu");
    testPrintfArgs(p1, "%-9.9wf32u");
    testPrintfArgs(p1, "%-9.9Hu");
    testPrintfArgs(p1, "%-9.9Lf");
    testPrintfArgs(p1, "%-9.9Hf");
    testPrintfArgs(p1, "%-9.9Df");
    testPrintfArgs(p1, "%-9.9DDf");
    testPrintfArgs(p1, "%-9.9jf");
    testPrintfArgs(p1, "%-# 9.9lc");
    testPrintfArgs(p1, "%-9.9lc");
    testPrintfArgs(p1, "%-9lc");
    testPrintfArgs(p1, "%-9jc");
    testPrintfArgs(p1, "%-# 9.9ls");
    testPrintfArgs(p1, "%-9.9ls");
    testPrintfArgs(p1, "%-9.9js");
    testPrintfArgs(p1, "%-# 9.9lp");
    testPrintfArgs(p1, "%-9.9lp");
    testPrintfArgs(p1, "%-9jp");
    testPrintfArgs(p1, "%-9.9ln");
    testPrintfArgs(p1, "%9.9ln");
    testPrintfArgs(p1, "%.9ln");
    testPrintfArgs(p1, "%lln");
    testPrintfArgs(p1, "%w64n");
    testPrintfArgs(p1, "%w99n");
    testPrintfArgs(p1, "%jn");
    testPrintfArgs(p1, "%tn");
    testPrintfArgs(p1, "%wf32n");
    testPrintfArgs(p1, "%Hn");
    testPrintfArgs(p1, "%-9.9l%");
    testPrintfArgs(p1, "%");
    testPrintfArgs(p1, "%あ");
    testPrintfArgs(p1, "%Z");
    testPrintfArgs(p1, "abc\x00xyz");
    testPrintfArgs(p1, "abc%\x00xyz");
}

fn testToPrintfArgs(comptime format: [:0]const u8, args: anytype) void {
    _ = printfcop.toPrintfArgs(p1, format, args);
}

fn testPrintfArgs(comptime features: printfcop.PrintfFeatures, comptime format: [:0]const u8) void {
    _ = printfcop.PrintfArgs(features, format);
}

fn testToScanfArgs(comptime format: [:0]const u8, args: anytype) void {
    _ = printfcop.toScanfArgs(s1, format, args);
}

fn testScanfArgs(comptime features: printfcop.ScanfFeatures, comptime format: [:0]const u8) void {
    _ = printfcop.ScanfArgs(features, format);
}

const p0: printfcop.PrintfFeatures = .{};

const p1: printfcop.PrintfFeatures = features: {
    var features: printfcop.PrintfFeatures = .c23;
    features.max_field_width = 100;
    features.max_precision = 100;
    features.int_length_modifiers.ll = false;
    features.int_length_modifiers.w64 = false;
    features.float_length_modifiers.L = false;
    break :features features;
};

const s0: printfcop.ScanfFeatures = .{};

const s1: printfcop.ScanfFeatures = features: {
    var features: printfcop.ScanfFeatures = .c23;
    features.max_field_width = 100;
    features.int_length_modifiers.ll = false;
    features.int_length_modifiers.w64 = false;
    features.float_length_modifiers.L = false;
    break :features features;
};

const S = struct {};
