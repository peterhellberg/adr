const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "adr",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .wasi,
        }),
        .optimize = .ReleaseSmall,
    });

    exe.root_module.addImport("zul", b.dependency("zul", .{}).module("zul"));

    b.installArtifact(exe);

    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "wasmtime",
        "run",
        "zig-out/bin/adr.wasm",
        "--dir",
        ".",
    });
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArg("--");
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run adr.wasm in wasmtime");
    run_step.dependOn(&run_cmd.step);
}
