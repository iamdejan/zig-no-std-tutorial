# AGENTS.md

## Code Generation

Make sure you adhere to the guide on this file to generate the code.

### Rules of engagement

1. You're allowed to create functions, structs, and impl blocks to generate the code.
2. Explain the flow of the program using comments. Make sure that you write not only what the program is doing, but why. It will help me to judge your work.
3. You have to add documentation in the form of Zig doc comments (`///`) for public functions, structs, and types. The documentation should contain what the function is for (basically the description), a brief summary of the steps, and input and output parameters. If your function has the ability to panic, please state it in the documentation as well.
4. Follow Zig idioms and best practices:
   - Use `std.mem.Allocator` for memory management when needed, but if not used then don't put it as a parameter in constructor.
   - Use `std.log` for logging
   - Use Zig's built-in testing with `const testing = std.testing`
   - Prefer value types over pointers where appropriate
   - Use `zig fmt` for code formatting conventions

### Debugging

In this repository, we don't have Zig installed in local machine. Instead, Zig executable is managed by Pixi, which is why in [pixi.toml](pixi.toml) under `[dependencies]` section you will have `zig` listed as dependency.

The consequence is that every Zig command you want to run should be run under `pixi run` command. I will list some of the examples here:
- Check Zig version: Instead of `zig version`, you should run `pixi run zig version`.
- Run all unit tests: Instead of `zig build test`, you should run `pixi run zig build test`.
  - In the case of running all unit tests, you should execute `pixi run test` instead, following the task defined in [pixi.toml](pixi.toml).
- Run the program: Instead of `zig build run`, you should run `pixi run zig build run`.
  - In the case of running the program (or the main function), you should execute `pixi run start` instead, following the task defined in [pixi.toml](pixi.toml).

## Code Validation

After generating the code, make sure you validate the code you generated.

### Steps to Validate

Run these commands in sequence:
1. `pixi run fmt`: format your code. This ensures that the code written by human and by you (coding agent) are consistent, following the style that Zig has provided.
2. `pixi run lint-ci`: ensure no linter errors.
3. `pixi run lint-fix`: if there is any linter error, fix it with this command.
4. `pixi run lint-ci`: recheck again, maybe there are linter errors that need manual fix.
5. `pixi run test`: build the code, then run all unit tests. This ensures that the code you generate pass all the unit tests.
6. `pixi run start`: run the code.

## Update Documentation

After the validation is finished, update the project tree structure and file descriptions in README.md if needed. This is to ensure we always have updated documentation.
