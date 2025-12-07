const std = @import("std");
const expect = std.testing.expect;
const print = std.debug.print;

var in_buf: [1024 * 1024]u8 = undefined;
var out_buf: [1024 * 1024]u8 = undefined;

pub fn main() !void {
   const stdin = std.fs.File.stdin();
   const cwd = std.fs.cwd();
   var args = std.process.args();

    _ = args.next();

   const file_name_bytes = args.next() orelse {
      return error.MissingArgument;
   };

   const file_name: []const u8 = file_name_bytes;

   const file = try cwd.createFile(file_name, .{ .read=true });

   while (true) {
      var reader = stdin.readerStreaming(&in_buf);
      var writer = std.io.Writer.fixed(&out_buf);

      const bytes = reader.interface.peekDelimiterExclusive('\n') catch |err| {
         if (err == error.EndOfStream) {
            break;
         }
         return err;
      };

      if (bytes.len == 0) {
         _ = try file.write("\n");
         continue;
      }

      const len = try reader.interface.streamDelimiter(&writer, '\n');
      print(":{d}::", .{ len });

      const buffered = writer.buffered();
      try expect(buffered.len == len);

      _ = try file.write(buffered);

      for (buffered) |byte| {
         print("{c}", .{ byte });
      }

      _ = try file.write("\n");

      print("\n", .{ });
      try writer.flush();
   }

   print("\\\\EOF", .{ });
   file.close();
}
