const std = @import("std");
const zul = @import("zul");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var args = try std.process.argsAlloc(allocator);

    defer std.process.argsFree(allocator, args);

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    var bw = std.io.bufferedWriter(stdout);

    const action = if (args.len > 1) args[1] else "";

    if (std.mem.eql(u8, action, "create")) {
        try ensureDirsExist();

        const fileList = try getAllFilesInADRDir(allocator);
        defer fileList.deinit();

        const name = std.mem.join(allocator, " ", args[2..]) catch unreachable;
        if (name.len == 0) {
            _ = try stderr.write("No name supplied for the ADR. Command should be: adr create Name of ADR here\n");
        } else {
            try generateADR(allocator, fileList.items.len, name);
            try rebuildReadme(allocator);
        }

        allocator.free(name);
    } else if (std.mem.eql(u8, action, "regen")) {
        try ensureDirsExist();
        try rebuildReadme(allocator);
    } else {
        const help_txt = @embedFile("./templates/help.txt");

        _ = bw.write(help_txt) catch @panic("Unable to write help contents");
    }

    try bw.flush();
}

fn getAllFilesInADRDir(allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    var dir = try std.fs.cwd().openDir("./adr", .{ .iterate = true });
    defer dir.close();

    var files = std.ArrayList([]const u8).init(allocator);

    var iter = dir.iterate();

    while (try iter.next()) |d| {
        if (!std.mem.eql(u8, d.name, "README.md") and
            !std.mem.eql(u8, d.name, "assets"))
        {
            const file = try allocator.dupe(u8, d.name);
            try files.append(file);
        }
    }

    return files;
}

fn generateADR(allocator: std.mem.Allocator, n: u64, name: []u8) !void {
    const safeName = replace(allocator, name, " ", "-");
    defer allocator.free(safeName);

    const paddedNums = try std.fmt.allocPrint(allocator, "{:0>5}", .{
        n,
    });
    defer allocator.free(paddedNums);

    const fileName = try std.fmt.allocPrint(allocator, "./adr/{s}-{s}.md", .{
        paddedNums,
        safeName,
    });
    defer allocator.free(fileName);

    const heading = try std.fmt.allocPrint(allocator, "{s} - {s}", .{
        paddedNums,
        name,
    });
    defer allocator.free(heading);

    const f = try std.fs.cwd().createFile(fileName, .{ .read = true });
    defer f.close();

    const ADR_template = @embedFile("./templates/ADR_template.md");

    const contents = replace(allocator, ADR_template, "{{name}}", heading);
    defer allocator.free(contents);

    try f.writeAll(contents);
}

fn ensureDirsExist() !void {
    const cwd = std.fs.cwd();
    try cwd.makePath("./adr/assets");
}

fn rebuildReadme(allocator: std.mem.Allocator) !void {
    const f = try std.fs.cwd().createFile("./adr/README.md", .{});

    const now = zul.DateTime.now();

    const README_template = @embedFile("./templates/README_template.md");

    var buf: [30]u8 = undefined;

    const date = try std.fmt.bufPrint(&buf, "{s}", .{now});

    const output = replace(allocator, README_template, "{{timestamp}}", date);
    defer allocator.free(output);

    const files = try getAllFilesInADRDir(allocator);
    defer files.deinit();

    var formatted = std.ArrayList([]const u8).init(allocator);
    defer formatted.deinit();

    std.mem.sort([]const u8, files.items, {}, compareStrings);

    for (files.items) |*str| {
        const itemLink = try std.fmt.allocPrint(allocator, " - [{s}](./{s})", .{
            str.*,
            str.*,
        });
        try formatted.append(itemLink);
        allocator.free(str.*);
    }

    const contents = try std.mem.join(allocator, "\n", formatted.items);

    const withContents = replace(allocator, output, "{{contents}}", contents);
    defer allocator.free(withContents);

    _ = try f.write(withContents);
}

fn compareStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}

fn replace(allocator: std.mem.Allocator, input: []const u8, needle: []const u8, replacement: []const u8) []u8 {
    return std.mem.replaceOwned(u8, allocator, input, needle, replacement) catch @panic("out of memory");
}
