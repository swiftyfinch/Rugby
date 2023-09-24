[< 📍 Shortcuts](../shortcuts.md)

# ⛱️ Umbrella

```sh
> rugby shortcuts umbrella --help
```

```sh

 > Run the plan command if plans file exists or run the cache command.

 Arguments:
╭──────────────────────────────────────────────────────────╮
│ arguments []  * Any arguments of plan or cache commands. │
╰──────────────────────────────────────────────────────────╯
 Flags:
╭──────────────────────────────────────╮
│ -h, --help  * Show help information. │
╰──────────────────────────────────────╯
```

# Discussion

The command checks if you have `.rugby/plans.yml` file or you passed `-p`, `--path` options with path to plans file.\
If file is found, Rugby will call [plan](../plan.md) command and pass all arguments.\
If isn't, Rugby will call [cache](cache.md) command and pass all arguments.

It allows to use Rugby in short way:
```sh
> rugby your_plan_name -p path_to_your_plans
```

Or shorter:
```sh
> rugby your_plan_name
```

Or even:
```sh
> rugby
```
If you want to use the first plan from `.rugby/plans.yml` file.\
Or if you don't have plans, it will call [cache](cache.md) command with default arguments.

<br>

### Cache

Also, you can pass [cache](cache.md) arguments if you don't have `.rugby/plans.yml`.
```sh
> rugby --arch x86_64
```

If you want to use [cache](cache.md) command, even if you have plans file:
```sh
> rugby cache
```
