[< 📍 Shortcuts](../Shortcuts.md)

### 🏈 Cache

```sh
> rugby shortcuts cache --help
```

```sh

 > Run the build and use commands.

 Options:
╭────────────────────────────────────────────────────────────────────────────────╮
│ -s, --sdk                  * Build SDK: sim or ios.                            │
│ -a, --arch                 * Build architecture: auto, x86_64 or arm64.        │
│ -c, --config               * Build configuration. (Debug)                      │
│ -t, --targets []           * Targets for building.                             │
│ -r, --targets-as-regex []  * Targets for building as a RegEx pattern.          │
│ -e, --except []            * Exclude targets from building.                    │
│ -x, --except-as-regex []   * Exclude targets from building as a RegEx pattern. │
│ -o, --output               * Output mode: fold, multiline, quiet.              │
╰────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭────────────────────────────────────────────╮
│ --ignore-cache    * Ignore shared cache.   │
│ -v, --verbose []  * Log level.             │
│ -h, --help        * Show help information. │
╰────────────────────────────────────────────╯
```
