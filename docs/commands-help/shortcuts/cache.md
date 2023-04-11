[< 📍 Shortcuts](../shortcuts.md)

# 🏈 Cache

```sh
> rugby shortcuts cache --help
```

```sh

 > Run the build and use commands.

 Options:
╭────────────────────────────────────────────────────────────────────────────────╮
│ -s, --sdk                  * Build SDK: sim or ios.                            │
│ -a, --arch                 * Build architecture: arm64 or x86_64.              │
│ -c, --config               * Build configuration. (Debug)                      │
│ -t, --targets []           * Targets for building.                             │
│ -r, --targets-as-regex []  * Targets for building as a RegEx pattern.          │
│ -e, --except []            * Exclude targets from building.                    │
│ -x, --except-as-regex []   * Exclude targets from building as a RegEx pattern. │
│ -o, --output               * Output mode: fold, multiline, quiet.              │
│ --warmup                   * Warmup cache with this endpoint.                  │
╰────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭────────────────────────────────────────────────────────╮
│ --ignore-cache    * Ignore shared cache.               │
│ --delete-sources  * Delete target groups from project. │
│ --strip           * Build without debug symbols.       │
│ -v, --verbose []  * Log level.                         │
│ -h, --help        * Show help information.             │
╰────────────────────────────────────────────────────────╯
```

## Discussion

It just a combination of exist commands. You can call them separately:
```sh
> warmup s3.eu-west-2.amazonaws.com --except SomePod --arch x86_64
> build --except SomePod --arch x86_64
> use --except SomePod
```

Or just use cache shortcut:
```sh
> cache --warmup s3.eu-west-2.amazonaws.com --except SomePod --arch x86_64
```

When you use cache or [plan](../plan.md) commands Rugby tries to reuse project cache.\
In huge projects it can save tens of seconds.
