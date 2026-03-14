const UART0_DR = @as(*volatile u32, @ptrFromInt(0x4000C000));

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

export fn _start() noreturn {
    const msg = "Hello LM3S6965 from Zig!\n";
    for (msg) |c| {
        UART0_DR.* = @as(u32, c);
    }

    // Instead of while(true), call exit
    exitQemu();
}
