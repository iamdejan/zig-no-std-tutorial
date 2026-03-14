# Debugging

In this repository, we don't have Zig installed in local machine. Instead, Zig executable is managed by Pixi, which is why in [pixi.toml](../../pixi.toml) under `[dependencies]` section you will have `zig` listed as dependency.

The consequence is that every Zig command you want to run should be run under `pixi run` command. I will list some of the examples here:
- Check Zig version: Instead of `zig version`, you should run `pixi run zig version`.
- Run all unit tests: Instead of `zig build test`, you should run `pixi run zig build test`.
  - In the case of running all unit tests, you should follow the rule under [code_validation.md](./code_validation.md).
- Run the program: Instead of `zig build run`, you should run `pixi run zig build run`.
  - In the case of running the program (or the main function), you should execute `pixi run start` instead, following the task defined in [pixi.toml](../../pixi.toml).
