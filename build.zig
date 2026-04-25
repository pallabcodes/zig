const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // --- L7 Masterclass: Custom Build Step ---
    // We create a step that generates a Zig file at build time.
    const gen_step = b.addWriteFiles();
    const version_path = gen_step.add("version.zig", 
        \\pub const build_time = "2026-04-23T18:55:00";
        \\pub const author = "L7-Engineer";
    );

    // We turn this generated file into a module that can be imported.
    const version_mod = b.addModule("version", .{
        .root_source_file = version_path,
    });

    // We define our core logic as a module.
    const lib_mod = b.addModule("zig-kb-lib", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "version", .module = version_mod },
        },
    });
    
    // Add C source file to the library module.
    lib_mod.addCSourceFile(.{
        .file = b.path("src/ffi/math.c"),
        .flags = &[_][]const u8{"-std=c99"},
    });
    lib_mod.link_libc = true;

    // The main executable
    const exe = b.addExecutable(.{
        .name = "zig-kb",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "lib", .module = lib_mod },
            },
        }),
    });
    
    exe.root_module.link_libc = true;
    b.installArtifact(exe);

    // Run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the knowledge base demonstrator");
    run_step.dependOn(&run_cmd.step);

    // Test step
    const lib_tests = b.addTest(.{
        .root_module = lib_mod,
    });
    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run all library tests");
    test_step.dependOn(&run_lib_tests.step);
}
