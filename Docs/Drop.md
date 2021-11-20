
### 🗑 `Drop`

```
OVERVIEW: Remove any targets by RegEx.

ARGUMENTS:
  <targets>                   RegEx targets for removing.
                              - Use backward slashes \ for escaping special characters;
                              - Add "" for safer use (without shell's interpretation). 

OPTIONS:
  -i, --invert                Invert regEx.
  -e, --exclude <exclude>     Exclude targets. (not RegEx)
  -t, --test-flight           Show output without any changes.
  -p, --project <project>     Project location. (default: Pods/Pods.xcodeproj)
  -k, --keep-sources          Keep sources & resources in project.

  --bell/--no-bell            Play bell sound on finish. (default: true)
  --hide-metrics              Hide metrics.
  -v, --verbose               Print more information.
  --version                   Show the version.
  -h, --help                  Show help information.
```

<br>

## General usage

```bash
rugby drop "Unit-Tests" "Keyboard\+LayoutGuide"
```

## Dry run

It's useful when you need to print all project targets by `RegEx`:

```bash
rugby drop ".*" --test-flight
```

## Keep sources and resources

```bash
rugby drop "MainTarget" --keep-sources
```

## Invert RegEx

```bash
rugby drop --invert "MainTarget"
```

## Exclude targets

```bash
rugby drop "Unit-Tests" --exclude MyFavourite-Unit-Tests
```

## Select project (default: Pods/Pods.xcodeproj)

```bash
rugby drop "Unit-Tests" --project Main.xcodeproj
```
