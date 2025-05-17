// © 2025 Carl Åstholm
// SPDX-License-Identifier: MIT

const printfcop = @import("printfcop.zig");

const NotATuple = struct {};
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

// zig fmt: off
const printf_invalid_specifier_cases = .{
    .{ "unsupported flag '-'",                           p0, "%-+ #09.9lf"                                     },
    .{ "duplicate flag '-'",                             p1, "%-+-+9.9lf"                                      },
    .{ "flag ' ' ignored with flag '+'",                 p1, "%-+ 09.9lf"                                      },
    .{ "flag '0' ignored with flag '-'",                 p1, "%-09.9lf"                                        },
    .{ "argument-supplied field width not supported",    p0, "%*.9lf"                                          },
    .{ "field width not supported",                      p0, "%1.9lf"                                          },
    .{ "field width exceeds maximum allowed value 100",  p1, "%-101.9lf"                                       },
    .{ "field width not representable by type 'c_int'",  p1, "%-9999999999999999999999999999999999999999.9lf"  },
    .{ "flag '-' redundant without field width",         p1, "%-.9lf"                                          },
    .{ "argument-supplied precision not supported",      p0, "%.*f"                                            },
    .{ "precision has leading zero(s)",                  p1, "%-9.00lf"                                        },
    .{ "precision not supported",                        p0, "%.f"                                             },
    .{ "precision exceeds maximum allowed value 100",    p1, "%-9.101lf"                                       },
    .{ "precision not representable by type 'c_int'",    p1, "%-9.9999999999999999999999999999999999999999lf"  },
    .{ "bit width has leading zero(s)",                  p1, "%-9.9w00d"                                       },
    .{ "bit width is 0",                                 p1, "%-9.9w0d"                                        },
    .{ "bit width not representable by type 'c_int'",    p1, "%-9.9w9999999999999999999999999999999999999999d" },
    .{ "missing bit width",                              p1, "%-9.9wd"                                         },
    .{ "unsupported conversion specifier 'd'",           p0, "%d"                                              },
    .{ "flag '#' used with conversion specifier 'd'",    p1, "%-#9.9ld"                                        },
    .{ "unsupported conversion specifier 'lld'",         p1, "%-9.9lld"                                        },
    .{ "unsupported bit width",                          p1, "%-9.9w64d"                                       },
    .{ "unsupported bit width",                          p1, "%-9.9w99d"                                       },
    .{ "unsupported conversion specifier 'jd'",          p1, "%-9.9jd"                                         },
    .{ "unsupported conversion specifier 'td'",          p1, "%-9.9td"                                         },
    .{ "unsupported conversion specifier 'wf32d'",       p1, "%-9.9wf32d"                                      },
    .{ "",                                               p1, "%-9.9Hd"                                         },
    .{ "flag '#' used with conversion specifier 'u'",    p1, "%-#9.9lu"                                        },
    .{ "flag ' ' used with conversion specifier 'u'",    p1, "%- 9.9lu"                                        },
    .{ "unsupported conversion specifier 'llu'",         p1, "%-9.9llu"                                        },
    .{ "unsupported bit width",                          p1, "%-9.9w64u"                                       },
    .{ "unsupported bit width",                          p1, "%-9.9w99u"                                       },
    .{ "unsupported conversion specifier 'ju'",          p1, "%-9.9ju"                                         },
    .{ "unsupported conversion specifier 'tu'",          p1, "%-9.9tu"                                         },
    .{ "unsupported conversion specifier 'wf32u'",       p1, "%-9.9wf32u"                                      },
    .{ "",                                               p1, "%-9.9Hu"                                         },
    .{ "unsupported conversion specifier 'Lf'",          p1, "%-9.9Lf"                                         },
    .{ "unsupported conversion specifier 'Hf'",          p1, "%-9.9Hf"                                         },
    .{ "unsupported conversion specifier 'Df'",          p1, "%-9.9Df"                                         },
    .{ "unsupported conversion specifier 'DDf'",         p1, "%-9.9DDf"                                        },
    .{ "",                                               p1, "%-9.9jf"                                         },
    .{ "flag ' ' used with conversion specifier 'c'",    p1, "%-# 9.9lc"                                       },
    .{ "precision used with conversion specifier 'c'",   p1, "%-9.9lc"                                         },
    .{ "unsupported conversion specifier 'lc'",          p1, "%-9lc"                                           },
    .{ "",                                               p1, "%-9jc"                                           },
    .{ "flag ' ' used with conversion specifier 's'",    p1, "%-# 9.9ls"                                       },
    .{ "unsupported conversion specifier 'ls'",          p1, "%-9.9ls"                                         },
    .{ "",                                               p1, "%-9.9js"                                         },
    .{ "flag ' ' used with conversion specifier 'p'",    p1, "%-# 9.9lp"                                       },
    .{ "precision used with conversion specifier 'p'",   p1, "%-9.9lp"                                         },
    .{ "",                                               p1, "%-9jp"                                           },
    .{ "flag(s) used with conversion specifier 'n'",     p1, "%-9.9ln"                                         },
    .{ "field width used with conversion specifier 'n'", p1, "%9.9ln"                                          },
    .{ "precision used with conversion specifier 'n'",   p1, "%.9ln"                                           },
    .{ "unsupported conversion specifier 'lln'",         p1, "%lln"                                            },
    .{ "unsupported bit width",                          p1, "%w64n"                                           },
    .{ "unsupported bit width",                          p1, "%w99n"                                           },
    .{ "unsupported conversion specifier 'jn'",          p1, "%jn"                                             },
    .{ "unsupported conversion specifier 'tn'",          p1, "%tn"                                             },
    .{ "unsupported conversion specifier 'wf32n'",       p1, "%wf32n"                                          },
    .{ "",                                               p1, "%Hn"                                             },
    .{ "missing conversion specifier",                   p1, "%-9.9l"                                          },
    .{ "missing conversion specifier",                   p1, "%"                                               },
};
// zig fmt: on

pub const expected_lines: []const []const u8 = x: {
    var lines: []const []const u8 = &.{};
    // toPrintfArgs
    lines = lines ++ .{
        ": error: expected a tuple, found 'printfcop_compile_errors.NotATuple'",
        ": error: expected 4 format argument(s), found 2",
    };
    // PrintfArgs
    for (printf_invalid_specifier_cases) |case| {
        var line: []const u8 = ": error: invalid conversion specification '" ++ case[2] ++ "'";
        if (case[0].len != 0) line = line ++ ": " ++ case[0];
        lines = lines ++ .{ line, ": note: called from here" };
    }
    lines = lines ++ .{
        ": error: invalid conversion specification '%': missing conversion specifier",
        ": note: called from here",
        ": error: invalid conversion specification '%Z'",
        ": note: called from here",
        ": error: format contains embedded null byte(s)",
        ": note: called from here",
        ": error: format contains embedded null byte(s)",
        ": note: called from here",
    };
    break :x lines;
};

pub fn main() void {
    testToPrintfArgs("abc xyz", @as(NotATuple, .{}));
    testToPrintfArgs("%d %d %d %d", .{ 1, 2 });

    inline for (printf_invalid_specifier_cases) |case| {
        testPrintfArgs(case[1], case[2]);
    }
    testPrintfArgs(p1, "%あいうえお");
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
