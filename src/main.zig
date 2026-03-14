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

export fn _start() noreturn {
    const msg = "Hello LM3S6965 from Zig!\n";
    for (msg) |c| {
        UART0_DR.* = @as(u32, c);
    }

    while (true) {
        asm volatile ("wfi");
    }
}

pub fn panic(_: []const u8, _: ?*anyopaque, _: ?usize) noreturn {
    while (true) {}
}
