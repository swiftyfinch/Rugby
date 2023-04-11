[< 📚 Commands Help](README.md)

# 🐚 Shell

```sh
> rugby shell --help
```

```sh

 > Run shell command from Rugby.

 Arguments:
╭──────────────────────────────────╮
│ command  * Shell script command. │
╰──────────────────────────────────╯
 Options:
╭──────────────────────────────────────────────────────╮
│ -o, --output  * Output mode: fold, multiline, quiet. │
╰──────────────────────────────────────────────────────╯
 Flags:
╭────────────────────────────────────────────╮
│ -v, --verbose []  * Log level.             │
│ -h, --help        * Show help information. │
╰────────────────────────────────────────────╯
```

## Discussion

This command is useful if you want to run some project configuration scripts before each build.\
Describe a sequence of commands and you can run all of them at once with just the `rugby` command.
```yml
# For example
basic:
- command: shell
  argument: xcodegen
- command: shell
  argument: pod install
- command: cache
```
This is equivalent to:
```sh
> xcodegen && pod install && rugby cache
```
Call it:
```sh
> rugby basic
```
If it is the first plan in your plans file, call it just as:
```sh
> rugby
```
You can find more information about plan command in 📖 [Plan Help](plan.md).

