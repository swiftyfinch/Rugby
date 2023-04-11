[< 📚 Commands Help](README.md)

# 🎯 Use

```sh
> rugby use --help
```

```sh

 > Use already built binaries instead of sources.

 Options:
╭────────────────────────────────────────────────────────────────────────────────╮
│ -t, --targets []           * Targets for building.                             │
│ -r, --targets-as-regex []  * Targets for building as a RegEx pattern.          │
│ -e, --except []            * Exclude targets from building.                    │
│ -x, --except-as-regex []   * Exclude targets from building as a RegEx pattern. │
│ -o, --output               * Output mode: fold, multiline, quiet.              │
╰────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭────────────────────────────────────────────────────────╮
│ --delete-sources  * Delete target groups from project. │
│ --strip           * Build without debug symbols.       │
│ -v, --verbose []  * Log level.                         │
│ -h, --help        * Show help information.             │
╰────────────────────────────────────────────────────────╯
```

## Discussion

The command replaces selected targets with binaries.\
Be sure that you pass the same flags and options that you passed to the build command.\
Be careful because it doesn't check if binaries exist in `~/.rugby/bin`.

Read about the [build](build.md) command for a better understanding of basic Rugby usage.

<br>

### Delete sources

If you don't want to keep the source code of binaries in your Pods project, you can use this flag:
```sh
> rugby use --delete-sources
```
It can significantly reduce the size of a huge project.
