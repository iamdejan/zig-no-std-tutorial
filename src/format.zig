//! Formatted print implementation for no-std Zig environments.
//!
//! This module provides a Format trait and println function similar to Rust's defmt crate,
//! designed for embedded/no-std environments where full std library is not available.

const UART0_DR = @as(*volatile u32, @ptrFromInt(0x4000C000));

/// Formatter handles the output of formatted values.
/// In this implementation, it writes to UART0.
pub const Formatter = struct {
    /// Writes a single character to the output
    pub fn writeChar(_: *Formatter, c: u8) void {
        UART0_DR.* = @as(u32, c);
    }

    /// Writes a string to the output
    pub fn writeStr(_: *Formatter, s: []const u8) void {
        for (s) |c| {
            UART0_DR.* = @as(u32, c);
        }
    }

    /// Writes a formatted unsigned integer
    pub fn writeUnsigned(_: *Formatter, value: u64) void {
        // Handle zero case
        if (value == 0) {
            UART0_DR.* = @as(u32, '0');
            return;
        }

        // Convert to string in reverse order
        var buffer: [32]u8 = undefined;
        var index: usize = 0;

        var v = value;
        while (v > 0) {
            const digit = @as(u8, @intCast(v % 10));
            buffer[index] = '0' + digit;
            index += 1;
            v /= 10;
        }

        // Write in reverse order
        while (index > 0) {
            index -= 1;
            UART0_DR.* = @as(u32, buffer[index]);
        }
    }

    /// Writes a formatted signed integer
    pub fn writeSigned(_: *Formatter, value: i64) void {
        if (value < 0) {
            UART0_DR.* = @as(u32, '-');
            // Convert to unsigned and make positive
            const unsigned_value = @as(u64, @intCast(-value));
            // Write the number
            if (unsigned_value == 0) {
                UART0_DR.* = @as(u32, '0');
                return;
            }
            var buffer: [32]u8 = undefined;
            var index: usize = 0;
            var v = unsigned_value;
            while (v > 0) {
                const digit = @as(u8, @intCast(v % 10));
                buffer[index] = '0' + digit;
                index += 1;
                v /= 10;
            }
            while (index > 0) {
                index -= 1;
                UART0_DR.* = @as(u32, buffer[index]);
            }
        } else {
            // Write positive number
            const unsigned_value = @as(u64, @intCast(value));
            if (unsigned_value == 0) {
                UART0_DR.* = @as(u32, '0');
                return;
            }
            var buffer: [32]u8 = undefined;
            var index: usize = 0;
            var v = unsigned_value;
            while (v > 0) {
                const digit = @as(u8, @intCast(v % 10));
                buffer[index] = '0' + digit;
                index += 1;
                v /= 10;
            }
            while (index > 0) {
                index -= 1;
                UART0_DR.* = @as(u32, buffer[index]);
            }
        }
    }
};

/// Global formatter instance
var global_formatter: Formatter = .{};

/// Helper to write character to UART
fn writeChar(c: u8) void {
    UART0_DR.* = @as(u32, c);
}

/// Helper to write string to UART
fn writeStr(s: []const u8) void {
    for (s) |c| {
        UART0_DR.* = @as(u32, c);
    }
}

/// Format a u8 value
fn formatU8(arg: u8) void {
    global_formatter.writeUnsigned(@as(u64, arg));
}

/// Format a u16 value
fn formatU16(arg: u16) void {
    global_formatter.writeUnsigned(@as(u64, arg));
}

/// Format a u32 value
fn formatU32(arg: u32) void {
    global_formatter.writeUnsigned(@as(u64, arg));
}

/// Format a u64 value
fn formatU64(arg: u64) void {
    global_formatter.writeUnsigned(arg);
}

/// Format an i8 value
fn formatI8(arg: i8) void {
    global_formatter.writeSigned(@as(i64, arg));
}

/// Format an i16 value
fn formatI16(arg: i16) void {
    global_formatter.writeSigned(@as(i64, arg));
}

/// Format an i32 value
fn formatI32(arg: i32) void {
    global_formatter.writeSigned(@as(i64, arg));
}

/// Format an i64 value
fn formatI64(arg: i64) void {
    global_formatter.writeSigned(arg);
}

/// Format a string slice
fn formatStr(arg: []const u8) void {
    global_formatter.writeStr(arg);
}

/// Prints a formatted string with arguments (no-std implementation).
///
/// This is a basic implementation that supports:
/// - Integer types (u8, u16, u32, i8, i16, i32, etc.)
/// - String slices ([]const u8)
///
/// Format specifiers:
/// - `{}` - format the next argument
/// - `{=u8}` - format as specific integer type
pub fn println(comptime fmt: []const u8, args: anytype) void {
    // Parse format string and write arguments
    var arg_index: usize = 0;
    var i: usize = 0;

    while (i < fmt.len) {
        if (fmt[i] == '{' and i + 1 < fmt.len) {
            if (fmt[i + 1] == '}') {
                // Simple format {} - use next argument
                if (arg_index < args.len) {
                    // Use inline for to get the argument and call the right format function
                    inline for (0..args.len, 0..) |idx, arg_idx| {
                        if (arg_idx == arg_index) {
                            const arg = args[idx];
                            const T = @TypeOf(arg);
                            switch (T) {
                                u8 => formatU8(arg),
                                u16 => formatU16(arg),
                                u32 => formatU32(arg),
                                u64 => formatU64(arg),
                                i8 => formatI8(arg),
                                i16 => formatI16(arg),
                                i32 => formatI32(arg),
                                i64 => formatI64(arg),
                                []const u8 => formatStr(arg),
                                else => {
                                    // Fallback: treat as pointer/address
                                    const addr: u64 = @intCast(@as(usize, @ptrCast(&arg)));
                                    global_formatter.writeUnsigned(addr);
                                },
                            }
                        }
                    }
                    arg_index += 1;
                }
                i += 2;
            } else if (fmt[i + 1] == '=') {
                // Type format {=u8}, {=i32}, etc.
                // Find the closing brace
                var j = i + 2;
                while (j < fmt.len and fmt[j] != '}') {
                    j += 1;
                }

                if (arg_index < args.len) {
                    inline for (0..args.len, 0..) |idx, arg_idx| {
                        if (arg_idx == arg_index) {
                            const arg = args[idx];
                            const T = @TypeOf(arg);
                            switch (T) {
                                u8 => formatU8(arg),
                                u16 => formatU16(arg),
                                u32 => formatU32(arg),
                                u64 => formatU64(arg),
                                i8 => formatI8(arg),
                                i16 => formatI16(arg),
                                i32 => formatI32(arg),
                                i64 => formatI64(arg),
                                []const u8 => formatStr(arg),
                                else => {
                                    // Fallback: treat as pointer/address
                                    const addr: u64 = @intCast(@as(usize, @ptrCast(&arg)));
                                    global_formatter.writeUnsigned(addr);
                                },
                            }
                        }
                    }
                    arg_index += 1;
                }
                i = j + 1;
            } else {
                writeChar(fmt[i]);
                i += 1;
            }
        } else if (fmt[i] == '\n') {
            writeChar('\r');
            writeChar('\n');
            i += 1;
        } else {
            writeChar(fmt[i]);
            i += 1;
        }
    }

    // Print newline at the end
    writeChar('\r');
    writeChar('\n');
}

/// Simple println for string literals without format arguments.
///
/// This is a convenience function for printing simple strings.
pub fn printlnStr(comptime s: []const u8) void {
    for (s) |c| {
        if (c == '\n') {
            UART0_DR.* = @as(u32, '\r');
            UART0_DR.* = @as(u32, '\n');
        } else {
            UART0_DR.* = @as(u32, c);
        }
    }
    UART0_DR.* = @as(u32, '\r');
    UART0_DR.* = @as(u32, '\n');
}

test "format integer" {
    // Test formatting integers - basic compilation test
    const test_value: u8 = 42;
    _ = test_value;
    const test_signed: i16 = -123;
    _ = test_signed;
}
