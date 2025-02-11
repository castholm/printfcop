// © 2025 Carl Åstholm
// SPDX-License-Identifier: MIT

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("printfcop", .{
        .root_source_file = b.path("printfcop.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = mod;

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("printfcop.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    const run_tests = b.addRunArtifact(tests);

    const compile_errors = b.addExecutable(.{
        .name = "compile_errors",
        .root_module = b.createModule(.{
            .root_source_file = b.path("printfcop_compile_errors.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    compile_errors.expect_errors = .{
        .exact = comptime exact: {
            var exact: []const []const u8 = &.{};
            // toPrintfArgs
            exact = exact ++ .{
                ": error: expected a tuple, found 'printfcop_compile_errors.S'",
                ": error: expected 4 format argument(s), found 2",
            };
            // PrintfArgs
            // zig fmt: off
            for (.{
                "'%-+ #09.9lf'"                                     ++ ": unsupported flag '-'",
                "'%-+-+9.9lf'"                                      ++ ": duplicate flag '-'",
                "'%-+ 09.9lf'"                                      ++ ": flag ' ' ignored with flag '+'",
                "'%-09.9lf'"                                        ++ ": flag '0' ignored with flag '-'",
                "'%*.9lf'"                                          ++ ": argument-supplied field width not supported",
                "'%1.9lf'"                                          ++ ": field width not supported",
                "'%-101.9lf'"                                       ++ ": field width exceeds maximum allowed value 100",
                "'%-9999999999999999999999999999999999999999.9lf'"  ++ ": field width not representable by type 'c_int'",
                "'%-.9lf'"                                          ++ ": flag '-' redundant without field width",
                "'%.*f'"                                            ++ ": argument-supplied precision not supported",
                "'%-9.00lf'"                                        ++ ": precision has leading zero(s)",
                "'%.f'"                                             ++ ": precision not supported",
                "'%-9.101lf'"                                       ++ ": precision exceeds maximum allowed value 100",
                "'%-9.9999999999999999999999999999999999999999lf'"  ++ ": precision not representable by type 'c_int'",
                "'%-9.9w00d'"                                       ++ ": bit width has leading zero(s)",
                "'%-9.9w0d'"                                        ++ ": bit width is 0",
                "'%-9.9w9999999999999999999999999999999999999999d'" ++ ": bit width not representable by type 'c_int'",
                "'%-9.9wd'"                                         ++ ": missing bit width",
                "'%d'"                                              ++ ": unsupported conversion specifier 'd'",
                "'%-#9.9ld'"                                        ++ ": flag '#' used with conversion specifier 'd'",
                "'%-9.9lld'"                                        ++ ": unsupported conversion specifier 'lld'",
                "'%-9.9w64d'"                                       ++ ": unsupported bit width",
                "'%-9.9w99d'"                                       ++ ": unsupported bit width",
                "'%-9.9jd'"                                         ++ ": unsupported conversion specifier 'jd'",
                "'%-9.9td'"                                         ++ ": unsupported conversion specifier 'td'",
                "'%-9.9wf32d'"                                      ++ ": unsupported conversion specifier 'wf32d'",
                "'%-9.9Hd'",
                "'%-#9.9lu'"                                        ++ ": flag '#' used with conversion specifier 'u'",
                "'%- 9.9lu'"                                        ++ ": flag ' ' used with conversion specifier 'u'",
                "'%-9.9llu'"                                        ++ ": unsupported conversion specifier 'llu'",
                "'%-9.9w64u'"                                       ++ ": unsupported bit width",
                "'%-9.9w99u'"                                       ++ ": unsupported bit width",
                "'%-9.9ju'"                                         ++ ": unsupported conversion specifier 'ju'",
                "'%-9.9tu'"                                         ++ ": unsupported conversion specifier 'tu'",
                "'%-9.9wf32u'"                                      ++ ": unsupported conversion specifier 'wf32u'",
                "'%-9.9Hu'",
                "'%-9.9Lf'"                                         ++ ": unsupported conversion specifier 'Lf'",
                "'%-9.9Hf'"                                         ++ ": unsupported conversion specifier 'Hf'",
                "'%-9.9Df'"                                         ++ ": unsupported conversion specifier 'Df'",
                "'%-9.9DDf'"                                        ++ ": unsupported conversion specifier 'DDf'",
                "'%-9.9jf'",
                "'%-# 9.9lc'"                                       ++ ": flag ' ' used with conversion specifier 'c'",
                "'%-9.9lc'"                                         ++ ": precision used with conversion specifier 'c'",
                "'%-9lc'"                                           ++ ": unsupported conversion specifier 'lc'",
                "'%-9jc'",
                "'%-# 9.9ls'"                                       ++ ": flag ' ' used with conversion specifier 's'",
                "'%-9.9ls'"                                         ++ ": unsupported conversion specifier 'ls'",
                "'%-9.9js'",
                "'%-# 9.9lp'"                                       ++ ": flag ' ' used with conversion specifier 'p'",
                "'%-9.9lp'"                                         ++ ": precision used with conversion specifier 'p'",
                "'%-9jp'",
                "'%-9.9ln'"                                         ++ ": flag(s) used with conversion specifier 'n'",
                "'%9.9ln'"                                          ++ ": field width used with conversion specifier 'n'",
                "'%.9ln'"                                           ++ ": precision used with conversion specifier 'n'",
                "'%lln'"                                            ++ ": unsupported conversion specifier 'lln'",
                "'%w64n'"                                           ++ ": unsupported bit width",
                "'%w99n'"                                           ++ ": unsupported bit width",
                "'%jn'"                                             ++ ": unsupported conversion specifier 'jn'",
                "'%tn'"                                             ++ ": unsupported conversion specifier 'tn'",
                "'%wf32n'"                                          ++ ": unsupported conversion specifier 'wf32n'",
                "'%Hn'",
                "'%-9.9l'"                                          ++ ": missing conversion specifier",
                "'%'"                                               ++ ": missing conversion specifier",
                "'%'"                                               ++ ": missing conversion specifier",
                "'%Z'",
            }) |s| {
                exact = exact ++ .{
                    ": error: invalid conversion specification " ++ s,
                    ": note: called from here",
                };
            }
            // zig fmt: on
            exact = exact ++ .{
                ": error: format contains embedded null byte(s)",
                ": note: called from here",
                ": error: format contains embedded null byte(s)",
                ": note: called from here",
            };
            break :exact exact;
        },
    };

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
    test_step.dependOn(&compile_errors.step);
}
