
## 🏈 `Drop`

Remove any targets by `RegEx`.\
`-` Use backward slashes `\` for escaping special characters;\
`-` Add `""` for safer use (without shell's interpretation).

### General usage

```bash
$ rugby drop "Unit-Tests" "Keyboard\+LayoutGuide"
```

### Dry run

It's useful when you need to print all project targets by `RegEx`.

```bash
$ rugby drop ".*" --test-flight --verbose

# short
$ rugby drop ".*" -tv
```

##### Keep sources and resources

```bash
$ rugby drop --keep-sources

# short
$ rugby drop -k
```

### Invert RegEx

```bash
$ rugby drop --invert "MainTarget"

# short
$ rugby drop -i "MainTarget"
```

### Exclude targets

```bash
$ rugby drop "Unit-Tests" --exclude MyFavourite-Unit-Tests

# short
$ rugby drop "Unit-Tests" -e MyFavourite-Unit-Tests
```

### Select project (default: Pods/Pods.xcodeproj)

```bash
$ rugby drop "Unit-Tests" --project Main.xcodeproj

# short
$ rugby drop "Unit-Tests" -p Main.xcodeproj
```