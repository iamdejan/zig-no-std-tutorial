# Code Generation

Hi Kilo Code agent! Whatever model you are using, make sure you adhere to the guide on this file to generate the code.

## Rules of engagement

1. You're allowed to create functions, structs, and impl blocks to generate the code.
2. Explain the flow of the program using comments. Make sure that you write not only what the program is doing, but why. It will help me to judge your work.
3. You have to add documentation in the form of Zig doc comments (`///`) for public functions, structs, and types. The documentation should contain what the function is for (basically the description), a brief summary of the steps, and input and output parameters. If your function has the ability to panic, please state it in the documentation as well.
4. Follow Zig idioms and best practices:
   - Use `std.mem.Allocator` for memory management when needed, but if not used then don't put it as a parameter in constructor.
   - Use `std.log` for logging
   - Use Zig's built-in testing with `const testing = std.testing`
   - Prefer value types over pointers where appropriate
   - Use `zig fmt` for code formatting conventions
