[< 📚 Commands Help](README.md)

# ✈️ Plan

```sh
> rugby plan --help
```

```sh

 > Run sequence of Rugby commands.

 Arguments:
╭──────────────────────────────╮
│ name  * Name of plan to run. │
╰──────────────────────────────╯
 Options:
╭────────────────────────────────────────────────────────╮
│ -p, --path    * Path to plans yaml. (.rugby/plans.yml) │
│ -o, --output  * Output mode: fold, multiline, quiet.   │
╰────────────────────────────────────────────────────────╯
 Flags:
╭────────────────────────────────────────────╮
│ -v, --verbose []  * Log level.             │
│ -h, --help        * Show help information. │
╰────────────────────────────────────────────╯
```

# Discussion

The command allows you to write a plan (combination of commands) in YAML format:
```yml
cache_plan_name:
- command: warmup
  argument: s3.eu-west-2.amazonaws.com
  except: SomePod
  arch: x86_64
- command: build
  except: SomePod
  arch: x86_64
- command: use
  except: SomePod
```

It's equal to this sequence of commands:
```sh
> warmup s3.eu-west-2.amazonaws.com --except SomePod --arch x86_64
> build --except SomePod --arch x86_64
> use --except SomePod
```

Then you need to save YAML to `.rugby/plans.yml` file or in another place.\
You can use this command to create a file:
```sh
> touch .rugby/plans.yml
```
Then add to it your plans.

<br>

When you are ready, call it using the command plan:
```sh
> rugby plan cache_plan_name --path your_plans_file_path
```

If you save plans to default location `.rugby/plans.yml`, you can use the shorter command:
```sh
> rugby plan cache_plan_name
```

Or even shorter:
```sh
> rugby cache_plan_name
```
Read more about [umbrella](shortcuts/umbrella.md) command.

<br>

### Several plans

You can write many plans in one file or different ones.\
Also, you can use already existing plans in your plans file.
```yml
# .rugby/plans.yml
usual:
- command: shell
  argument: pod install
- command: plan
  argument: base # Use base plan from different file
  path: another_path.yml

not_usual: # The second plan
- command: delete
  targets:
  - BrokenPod
  - NotMyTeamTestsPod
- command: plan
  argument: base
  path: another_path.yml
```
```yml
# another_path.yml
base: # The 3rd plan
- command: cache
  except: [SomePod]
```

And then you can choose which one you need to call:
```sh
> rugby not_usual
```

Or you can call a plan from another file:
```sh
> rugby -p another_path.yml
```
It's not necessary to pass a plan name if it's the first plan in a file.

And also, if you want to call the first plan from the default plans file:
```sh
> rugby
```
Yeah, it's not a mistake. Just call the command without any arguments.

<br>

### Syntax

Each plans file should be a dictionary where you describe plans names as keys.\
The value for each key should be an array with commands.
```yml
key1: # It's a plan name
- command: build # It's a command name
- command: use

key2:
- command: shell
```

Each command can contain arguments, options, and flags.\
Arguments should be written in YAML with keyword `argument`.
```yml
usual:
- command: shell
  argument: pod install
```
For example, the [shell](shell.md) command has an argument with the name `command`.\
But you need to change all names of arguments just to the `argument` keyword.

Options should be written in YAML without prefixes `--` and `-`.\
And use only the long version of an option name.
```yml
usual:
- command: cache
  arch: x86_64
```
For example, the [cache](shortcuts/cache.md) command has an option `arch`.\
You can't use `a: x86_64` in your plans.

Flags should be written in YAML also without prefixes `--` and `-`.\
Use only the long version of a flag name. The value should be `true` or `false`.
```yml
usual:
- command: cache
  strip: true
```
For example, the [cache](shortcuts/cache.md) command has a flag `strip`.
