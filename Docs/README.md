
### 🚑 `Help`

```
OVERVIEW: 🏈 Shake up pods project, build and throw away part of it.

OPTIONS:
  --version          Show the version.
  -h, --help         Show help information.

SUBCOMMANDS:
  plans (default)    • Run selected plan from .rugby/plans.yml
                       or use cache command if file not found.
  cache              • Convert pods to prebuilt dependencies.
                       Call it after each pod install.
  focus              • Keep only selected targets and all their dependencies.
  drop               • Remove any targets by RegEx.
  rollback           • Deintegrate Rugby from your project.
  log                • Print last command log verbosely.
  doctor             • Show troubleshooting suggestions.
  clean              • Remove cache except plans.yml and logs.
```

<br>

## Default command

By default 🏈 **Rugby** runs the `plans` command if you have `.rugby/plans.yml` file.\
Otherwise `cache` command will be run.

## Hide interactive animations

Format output for non-interactive terminal sessions. It reduces output of loading spinner, e.g on CI (#183).

```bash
rugby --non-interactive
```

## Log

If you run any command without `--verbose` flag you still can get verbosity output of the last 🏈 **Rugby** run:

```bash
rugby log
```

## Doctor

If you encourage any problems, please call `rugby doctor` and follow suggestions.

<img width="729" alt="Screenshot 2021-11-30 at 21 08 47" src="https://user-images.githubusercontent.com/64660122/144104545-84c7ac6f-2c39-4812-bdba-511b10b8194d.png">
