const UART0_DR = @as(*volatile u32, @ptrFromInt(0x4000C000));

// Import the format module
const format = @import("format.zig");

// Change 'struct' to 'extern struct' to ensure C-compatible memory layout
pub const VectorTable = extern struct {
    initial_stack_pointer: *anyopaque,
    reset_handler: *const fn () callconv(.c) noreturn,
};

export var vector_table linksection(".vectors") = VectorTable{
    .initial_stack_pointer = @ptrFromInt(0x20010000),
    .reset_handler = _start,
};

// Semihosting operation codes
const SYS_EXIT = 0x18;
const ADP_Stopped_ApplicationExit = 0x20026;

fn exitQemu() noreturn {
    // Register R0: Operation (SYS_EXIT = 0x18)
    // Register R1: Parameter (ADP_Stopped_ApplicationExit = 0x20026)
    asm volatile (
        \\ mov r0, %[op]
        \\ mov r1, %[arg]
        \\ bkpt 0xab
        :
        : [op] "r" (@as(u32, SYS_EXIT)),
          [arg] "r" (@as(u32, ADP_Stopped_ApplicationExit)),
        : .{ .r0 = true, .r1 = true });

    while (true) {}
}

/// Exit function that can be called from user code
pub fn exit() noreturn {
    exitQemu();
}

export fn _start() noreturn {
    // Print simple string using printlnStr
    format.printlnStr("Hello, world!");

    // Print formatted integer with type specifier
    const x: u8 = 42;
    format.println("x={=u8}", .{x});

    // Print formatted integer with simple placeholder
    const y: u16 = 123;
    format.println("y={}", .{y});

    // Print negative integer
    const neg: i32 = -456;
    format.println("neg={}", .{neg});

    // Print multiple integer values
    const a: u8 = 10;
    const b: u16 = 20;
    format.println("a={}, b={}", .{ a, b });

    // Instead of while(true), call exit
    exitQemu();
}
