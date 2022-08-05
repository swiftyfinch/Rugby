
### 🔍 `Focus`

```
OVERVIEW: Keep only selected targets and all their dependencies.

ARGUMENTS:
  <targets>               RegEx targets for focusing.
                          - Use backward slashes \ for escaping special characters;
                          - Add "" for safer use (without shell's interpretation). 

OPTIONS:
  -t, --test-flight       Show output without any changes.
  -p, --project <project> Project location. (default: Pods/Pods.xcodeproj)
  -k, --keep-sources      Keep sources & resources in project.

  --bell/--no-bell        Play bell sound on finish. (default: true)
  --hide-metrics          Hide metrics.
  -v, --verbose           Print more information.
  -q, --quiet             Print nothing.
  --non-interactive       Print non-interactive output.
  --version               Show the version.
  -h, --help              Show help information.
```

<br>

## General usage

```bash
rugby focus "Pods-Main"
```

## Dry run

```bash
rugby focus "Pods-Main" --test-flight
```

## Keep sources and resources

```bash
rugby focus "Pods-Main" --keep-sources
```

## Select project (default: Pods/Pods.xcodeproj)

```bash
rugby focus "Main" --project Main.xcodeproj
```
