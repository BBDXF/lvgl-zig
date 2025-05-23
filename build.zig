const std = @import("std");

fn collectCFiles(allocator: std.mem.Allocator, path: []const u8) !std.ArrayList([]const u8) {
    var result = std.ArrayList([]const u8).init(allocator);
    var dir_iter = try std.fs.openDirAbsolute(path, .{ .iterate = true });
    defer dir_iter.close();

    var it = dir_iter.iterate();
    while (try it.next()) |entry| {
        const full_path = try std.fs.path.join(allocator, &.{ path, entry.name });
        defer allocator.free(full_path);

        if (entry.kind == .directory) {
            // 递归处理子目录
            var sub_files = try collectCFiles(allocator, full_path);
            defer sub_files.deinit();

            for (sub_files.items) |file| {
                try result.append(try allocator.dupe(u8, file));
            }
        } else if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".c")) {
            // 收集C文件
            try result.append(try allocator.dupe(u8, full_path));
        }
    }

    return result;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // lvgl source
    const lvgl_lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    lvgl_lib_mod.addIncludePath(b.path("src"));
    lvgl_lib_mod.addIncludePath(b.path("."));

    // collect c files
    // .s file is for blend
    const path_src = b.path("lvgl/src").getPath(b);
    std.log.warn("root: {s}\n", .{path_src});
    var c_files = collectCFiles(b.allocator, path_src) catch {
        std.log.err("collect files failed!", .{});
        return;
    };
    defer {
        for (c_files.items) |file| {
            b.allocator.free(file);
        }
        c_files.deinit();
    }
    // add source
    const cwd = b.path(".").getPath(b);
    for (c_files.items) |c_file| {
        if (std.fs.path.relative(b.allocator, cwd, c_file)) |c_cwd| {
            std.log.warn("=> add {s}, {s}", .{ c_file, c_cwd });
            lvgl_lib_mod.addCSourceFile(.{
                .file = b.path(c_cwd),
            });
        } else |_| {}
    }
    lvgl_lib_mod.addCSourceFiles(.{
        .files = &.{
            "src/main.c",
            "src/lv_demo_widgets.c",
        },
    });
    // add header
    lvgl_lib_mod.addIncludePath(b.path("lvgl"));
    lvgl_lib_mod.addIncludePath(b.path("src"));
    lvgl_lib_mod.addIncludePath(b.path("."));

    const lvgl_lib = b.addLibrary(.{
        .name = "lvgl",
        .root_module = lvgl_lib_mod,
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
    });
    lvgl_lib.linkLibC();
    lvgl_lib.linkSystemLibrary("SDL2");

    // // test
    // const demo_exe = b.addExecutable(.{
    //     .name = "demo",
    //     .target = target,
    //     .optimize = optimize,
    //     .root_source_file = b.path("tests/demo.zig"),
    // });
    // demo_exe.addIncludePath(b.path("src"));
    // demo_exe.addIncludePath(b.path("quickjs"));
    // demo_exe.linkLibrary(lvgl_lib);

    // // install
    // b.installArtifact(demo_exe);
    b.installArtifact(lvgl_lib);
}
