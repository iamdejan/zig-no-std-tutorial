const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options allow specifying the CPU architecture, OS, etc.
    // The default is the host machine's target.
    const target = b.standardTargetOptions(.{});

    // Create the root module for the executable
    const exe_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .ReleaseSafe,
        .link_libc = true,
        .link_libcpp = true,
    });

    const exe = b.addExecutable(.{
        .name = "zig-no-std-tutorial",
        .root_module = exe_module,
    });

    // Install the artifact
    b.installArtifact(exe);

    // Create a "run" step to easily run the executable with `zig build run`
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Create the root module for tests
    const test_module = b.createModule(.{
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = .ReleaseSafe,
        .link_libc = true,
        .link_libcpp = true,
    });

    // Create a "test" step to run all tests with `zig build test`
    const tests = b.addTest(.{
        .root_module = test_module,
        .test_runner = .{ .path = b.path("src/test_runner.zig"), .mode = .simple },
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
