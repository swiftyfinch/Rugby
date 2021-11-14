
### 🚑 `Help`

```
OVERVIEW: Shake up pods project, build and throw away part of it.

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

## Doctor

If you encourage any problems, please call `rugby doctor` and follow suggestions.

<img src="https://user-images.githubusercontent.com/64660122/141672978-c6a8b0bf-973e-4f70-9b67-c76daf66e731.png" width="700"/>