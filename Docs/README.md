
### 🚑 `Help`

```
OVERVIEW: Shake up pods project, build and throw away part of it.

OPTIONS:
  --version          Show the version.
  -h, --help         Show help information.

SUBCOMMANDS:
  plans (default)    • Run selected plan from .rugby/plans.yml
                       or use cache command if file not found.
  cache              • Convert remote pods to prebuilt dependencies.
                       Call it after each pod install.
  focus              • Keep only selected targets and all their dependencies.
  drop               • Remove any targets by RegEx.
  log                • Print last command log verbosely.
```

<br>

## Default command

By default **Rugby** runs the `plans` command if you have `.rugby/plans.yml` file.\
Otherwise `cache` command will be run.

## Log

If you run any command without `--verbose` flag you still can get verbosity output of the last **Rugby** run:

```bash
rugby log
```
