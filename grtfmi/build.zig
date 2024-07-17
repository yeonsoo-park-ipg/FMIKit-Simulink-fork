const std: type = @import("std");
const Dir: type = std.fs.Dir;
const Walker: type = Dir.Walker;
const LazyPath: type = std.Build.LazyPath;
const ResolvedTarget: type = std.Build.ResolvedTarget;
const OptimizeMode: type = std.builtin.OptimizeMode;
const InstallArtifact: type = std.Build.Step.InstallArtifact;
const InstallFile: type = std.Build.Step.InstallFile;
const Run: type = std.Build.Step.Run;
const Compile: type = std.Build.Step.Compile;

fn search_and_append(allocator: std.mem.Allocator, sub_path: []const u8, files: *std.ArrayListAligned([]const u8, null)) !void {
    const dir: Dir = try Dir.openDir(
        std.fs.cwd(),
        sub_path,
        .{
            .iterate = true,
        },
    );
    var walker: Walker = try dir.walk(allocator);
    while (try walker.next()) |entry| {
        const name: []const u8 = try std.fmt.allocPrint(allocator, "{s}", .{entry.basename});
        if (std.mem.endsWith(u8, name, ".c")) {
            try files.*.append(name);
        }
    }
}

pub fn build(b: *std.Build) !void {
    var arena = std.heap.ArenaAllocator.init(b.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    // FMU Configurations //
    const target: ResolvedTarget = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .x86_64,
            .os_tag = .windows,
            .abi = .gnu,
        },
    });
    const opt: OptimizeMode = b.standardOptimizeOption(.{});
    const model_name: []const u8 = "MODELNAME";
    const fmu_name: []const u8 = try std.fmt.allocPrint(allocator, "{s}.fmu", .{model_name});
    const lib: *Compile = b.addSharedLibrary(.{
        .name = model_name, // get from tlc
        .target = target,
        .optimize = opt,
        .link_libc = true,
        .pic = true,
    });

    // Includes
    const matlab: LazyPath = LazyPath{ .cwd_relative = "C:/Program Files/MATLAB/R2023b" }; // get from tlc
    const fmikit_simulink: LazyPath = LazyPath{ .cwd_relative = "C:/FMI/FMIKit-Simulink-fork" }; // get from tlc
    lib.addIncludePath(matlab.path(b, "extern/include"));
    lib.addIncludePath(matlab.path(b, "simulink/include"));
    lib.addIncludePath(matlab.path(b, "rtw/c/src"));
    lib.addIncludePath(fmikit_simulink.path(b, "include"));
    lib.addIncludePath(b.path("."));

    // C Flags and Defines
    var flags: std.ArrayListAligned([]const u8, null) = std.ArrayList([]const u8).init(allocator);
    try flags.append("-Wall");
    try flags.append("-Wextra");
    try flags.append("-DRT");
    try flags.append("-DRT_MALLOC");
    try flags.append("-DUSE_RTMODEL");
    try flags.append("-DNO_FMI_FUNCTION_PREFIX");
    try flags.append("-DGRTFMI");

    // C Source Files
    var files: std.ArrayListAligned([]const u8, null) = std.ArrayList([]const u8).init(allocator);
    try search_and_append(allocator, ".", &files);
    try search_and_append(allocator, "../slprj", &files);
    lib.addCSourceFiles(.{
        .files = files.items,
        .flags = flags.items,
    });

    // FMU Version dependant structure setup
    const fmi_version: comptime_int = 2;
    const os_arch = switch (fmi_version) {
        1, 2 => try std.fmt.allocPrint(
            allocator,
            "{s}{s}",
            .{
                switch (target.result.os.tag) {
                    .windows => "win",
                    .linux => "linux",
                    .macos => "darwin",
                    else => "unknown",
                },
                switch (target.result.cpu.arch) {
                    .x86_64 => "64",
                    .x86 => "32",
                    else => "unknown",
                },
            },
        ),
        3 => try std.fmt.allocPrint(
            allocator,
            "{s}-{s}",
            .{
                switch (target.result.cpu.arch) {
                    .x86_64 => "x86-64",
                    .x86 => "i686",
                    else => "unknown",
                },
                switch (target.result.os.tag) {
                    .windows => "windows",
                    .linux => "linux",
                    .macos => "darwin",
                    else => "unknown",
                },
            },
        ),
        else => "",
    };
    const ext = target.result.dynamicLibSuffix();
    const dir_path: []const u8 = try std.fmt.allocPrint(allocator, "binaries/{s}", .{os_arch});
    const file_name: []const u8 = try std.fmt.allocPrint(allocator, "{s}{s}", .{ model_name, ext });

    // Installation Steps
    // Copy library
    const copy_lib: *InstallArtifact = b.addInstallArtifact(
        lib,
        .{
            .dest_dir = .{
                .override = .{
                    .custom = dir_path,
                },
            },
            .dest_sub_path = file_name,
        },
    );
    copy_lib.step.dependOn(&lib.step);
    b.getInstallStep().dependOn(&copy_lib.step);

    // Copy modelDescription
    const copy_xml: *InstallFile = b.addInstallFile(b.path("./modelDescription.xml"), "./modelDescription.xml");
    b.getInstallStep().dependOn(&copy_xml.step);

    // Copy model image
    const copy_img: *InstallFile = b.addInstallFile(b.path("./model.png"), "./model.png");
    b.getInstallStep().dependOn(&copy_img.step);

    // Zip to fmu
    const cmd: *Run = b.addSystemCommand(&.{
        "tar",
        "-cf",
        fmu_name,
        "--format=zip",
        "-C",
        "zig-out",
        ".",
    });
    cmd.step.dependOn(&copy_lib.step);
    cmd.step.dependOn(&copy_xml.step);
    b.getInstallStep().dependOn(&cmd.step);
}
