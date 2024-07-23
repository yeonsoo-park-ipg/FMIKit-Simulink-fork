const std: type = @import("std");
const builtin: type = @import("builtin");
const Dir: type = std.fs.Dir;
const Walker: type = Dir.Walker;
const ResolvedTarget: type = std.Build.ResolvedTarget;
const OptimizeMode: type = std.builtin.OptimizeMode;
const InstallArtifact: type = std.Build.Step.InstallArtifact;
const InstallFile: type = std.Build.Step.InstallFile;
const Run: type = std.Build.Step.Run;
const Compile: type = std.Build.Step.Compile;
const Query: type = std.Target.Query;
const Tag: type = std.Target.Os.Tag;
const Step: type = std.Build.Step;
const MatlabVersion: type = enum {
    R2016a,
    R2016b,
    R2017a,
    R2017b,
    R2018a,
    R2018b,
    R2019a,
    R2019b,
    R2020a,
    R2020b,
    R2021a,
    R2021b,
    R2022a,
    R2022b,
    R2023a,
    R2023b,
};

fn search_and_append(b: *std.Build, sub_path: []const u8, files: *std.ArrayListAligned([]const u8, null)) !void {
    const dir: Dir = try Dir.openDir(
        std.fs.cwd(),
        sub_path,
        .{
            .iterate = true,
        },
    );
    var walker: Walker = try dir.walk(b.allocator);
    while (try walker.next()) |entry| {
        const name: []const u8 = b.fmt("{s}", .{entry.basename});
        if (std.mem.endsWith(u8, name, ".c")) {
            try files.*.append(b.fmt("{s}/{s}", .{ sub_path, name }));
        }
    }
}

fn addMatlabIncludePath(b: *std.Build, c: *Compile, mat_ver_str: []const u8) void {
    c.addIncludePath(b.path(b.fmt("../{s}/extern/include", .{mat_ver_str})));
    c.addIncludePath(b.path(b.fmt("../{s}/simulink/include", .{mat_ver_str})));
    c.addIncludePath(b.path(b.fmt("../{s}/rtw/c/src", .{mat_ver_str})));
}

fn addSimscapeIncludePath(b: *std.Build, c: *Compile, mat_ver_enum: MatlabVersion, mat_ver_str: []const u8, os_arch: []const u8) void {
    switch (mat_ver_enum) {
        .R2016a, .R2016b, .R2017a, .R2017b, .R2018a, .R2018b, .R2019a, .R2019b => {
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/sli/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/compiler/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/pm_math/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/network_engine/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/math/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/lang/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/foundation/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/external/library/c/{s}", .{ mat_ver_str, os_arch })));
        },
        .R2020a, .R2020b, .R2021a, .R2021b => {
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/sli/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/compiler/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/network_engine/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/math/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/lang/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/foundation/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/external/library/c/{s}", .{ mat_ver_str, os_arch })));
        },
        .R2022a => {
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/simtypes/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/sli/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/ds/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/compiler/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/math/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/logging/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/lang/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/foundation/core/c/{s}", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/toolbox/physmod/common/external/library/c/{s}", .{ mat_ver_str, os_arch })));
        },
        .R2022b, .R2023a, .R2023b => {
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_st/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_sli/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_ds/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_core/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_comp/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/pm_log/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/pm/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/mc/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/lang/include", .{ mat_ver_str, os_arch })));
            c.addIncludePath(b.path(b.fmt("../{s}/extern/physmod/{s}/ex/include", .{ mat_ver_str, os_arch })));
        },
    }
}

pub fn build(b: *std.Build) !void {
    // FMU Configurations //
    const opt: OptimizeMode = b.standardOptimizeOption(.{});
    const querys: []const Query = &.{
        .{ .cpu_arch = .x86_64, .os_tag = .windows, .abi = .gnu },
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
    };

    // Replacements from make_rtw_hook
    const model_name: []const u8 = "@MODELNAME@";
    const fmi_version: comptime_int = @FMIVERSION@;
    const mat_ver_enum: MatlabVersion = .@RMATLABVERSION@;
    const mat_ver_str: []const u8 = "@RMATLABVERSION@";
    const use_simscape: bool = @SIMSCAPE@;
    const fmu_name: []const u8 = "@MODELNAME@.fmu";

    var del_err: Dir.DeleteDirError = error.Unexpected;
    _ = Dir.deleteDir(std.fs.cwd(), b.fmt("../{s}", .{mat_ver_str})) catch |err| {
        del_err = err;
    };

    const clone: *Run = switch (del_err) {
        error.DirNotEmpty => b.addSystemCommand(&.{
            "git",
            "-C",
            b.fmt("../{s}", .{mat_ver_str}),
            "pull",
        }),
        error.Unexpected, error.FileNotFound => b.addSystemCommand(&.{
            "git",
            "clone",
            b.fmt("https://github.com/ypark54/{s}.git", .{mat_ver_str}),
            b.fmt("../{s}", .{mat_ver_str}),
        }),
        else => unreachable,
    };

    var steps: std.ArrayListAligned(*Step, null) = std.ArrayList(*Step).init(b.allocator);
    for (querys) |query| {
        const target: ResolvedTarget = b.resolveTargetQuery(query);
        const target_os: Tag = target.result.os.tag;
        const os_arch: []const u8 = switch (target_os) {
            .windows => "win64",
            .linux => "glnxa64",
            .macos => unreachable,
            else => unreachable,
        };
        const lib: *Compile = b.addSharedLibrary(.{
            .name = model_name,
            .target = target,
            .optimize = opt,
            .link_libc = true,
            .pic = true,
        });
        lib.step.dependOn(&clone.step);
        // Includes
        lib.addIncludePath(b.path("."));
        lib.addIncludePath(b.path("./include"));
        addMatlabIncludePath(b, lib, mat_ver_str);

        if (use_simscape) {
            addSimscapeIncludePath(b, lib, mat_ver_enum, mat_ver_str, os_arch);

            const matlab_lib_suffix: []const u8 = switch (target_os) {
                .windows => "mingw64",
                .linux => "std",
                .macos => unreachable,
                else => unreachable,
            };

            // Library path for simscape
            switch (mat_ver_enum) {
                .R2016a, .R2016b, .R2017a, .R2017b, .R2018a, .R2018b, .R2019a, .R2019b => {
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/sli/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/pm_math/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/network_engine/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/math/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/foundation/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/external/library/lib/{s}", .{ mat_ver_str, os_arch })));
                },
                .R2020a, .R2020b, .R2021a, .R2021b => {
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/sli/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/network_engine/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/math/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/foundation/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/external/library/lib/{s}", .{ mat_ver_str, os_arch })));
                },
                .R2022a => {
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/simtypes/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/sli/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/simscape/engine/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/math/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/foundation/core/lib/{s}", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/toolbox/physmod/common/external/library/lib/{s}", .{ mat_ver_str, os_arch })));
                },
                .R2022b, .R2023a, .R2023b => {
                    lib.addLibraryPath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_st/lib", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_sli/lib", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/extern/physmod/{s}/ssc_core/lib", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/extern/physmod/{s}/mc/lib", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/extern/physmod/{s}/pm/lib", .{ mat_ver_str, os_arch })));
                    lib.addLibraryPath(b.path(b.fmt("../{s}/extern/physmod/{s}/ex/lib", .{ mat_ver_str, os_arch })));
                },
            }
            // Link library for simscape
            switch (mat_ver_enum) {
                .R2016a, .R2016b, .R2017a, .R2017b, .R2018a, .R2018b, .R2019a, .R2019b => {
                    lib.linkSystemLibrary(b.fmt("ssc_sli_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ssc_core_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("pm_math_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ne_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("mc_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("pm_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ex_{s}", .{matlab_lib_suffix}));
                },
                .R2020a, .R2020b, .R2021a, .R2021b => {
                    lib.linkSystemLibrary(b.fmt("ssc_sli_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ssc_core_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ne_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("mc_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("pm_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ex_{s}", .{matlab_lib_suffix}));
                },
                .R2022a, .R2022b, .R2023a, .R2023b => {
                    lib.linkSystemLibrary(b.fmt("ssc_st_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ssc_sli_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ssc_core_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("mc_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("pm_{s}", .{matlab_lib_suffix}));
                    lib.linkSystemLibrary(b.fmt("ex_{s}", .{matlab_lib_suffix}));
                },
            }
        }

        // C Flags and Defines
        var flags: std.ArrayListAligned([]const u8, null) = std.ArrayList([]const u8).init(b.allocator);
        try flags.append("-Wall");
        try flags.append("-Wextra");
        try flags.append("-DRT");
        try flags.append("-DRT_MALLOC");
        try flags.append("-DUSE_RTMODEL");
        try flags.append("-DNO_FMI_FUNCTION_PREFIX");
        try flags.append("-DGRTFMI");

        // C Source Files
        var files: std.ArrayListAligned([]const u8, null) = std.ArrayList([]const u8).init(b.allocator);
        try search_and_append(b, ".", &files);
        try files.append(b.fmt("../{s}/rtw/c/src/rt_matrx.c", .{mat_ver_str}));
        for (files.items) |item| {
            std.debug.print("{s}\n", .{item});
        }
        lib.addCSourceFiles(.{
            .files = files.items,
            .flags = flags.items,
        });
        const dir_os_arch: []const u8 = switch (fmi_version) {
            1, 2 => switch (target_os) {
                .windows => "win64",
                .linux => "linux64",
                .macos => "darwin64",
                else => unreachable,
            },
            3 => switch (target_os) {
                .windows => "x86_64-windows",
                .linux => "x86_64-linux",
                .macos => "x86_64-darwin",
                else => unreachable,
            },
            else => unreachable,
        };
        const ext: []const u8 = target.result.dynamicLibSuffix();
        const dir_path: []const u8 = b.fmt("binaries/{s}", .{dir_os_arch});
        const file_name: []const u8 = b.fmt("{s}{s}", .{ model_name, ext });
        const copy_lib: *InstallArtifact = b.addInstallArtifact(
            lib,
            .{ .dest_dir = .{
                .override = .{
                    .custom = dir_path,
                },
            }, .dest_sub_path = file_name },
        );
        copy_lib.step.dependOn(&lib.step);
        try steps.append(&copy_lib.step);
    }

    // Copy modelDescription
    const copy_xml: *InstallFile = b.addInstallFile(b.path("./modelDescription.xml"), "./modelDescription.xml");
    // Copy model image
    const copy_img: *InstallFile = b.addInstallFile(b.path("./model.png"), "./model.png");

    // Zip to fmu
    const zip: *Run = b.addSystemCommand(&.{
        "tar",
        "-cf",
        fmu_name,
        "--format=zip",
        "-C",
        "zig-out",
        ".",
    });
    for (steps.items) |item| {
        zip.step.dependOn(item);
    }
    zip.step.dependOn(&copy_xml.step);
    zip.step.dependOn(&copy_img.step);
    b.getInstallStep().dependOn(&zip.step);
}
