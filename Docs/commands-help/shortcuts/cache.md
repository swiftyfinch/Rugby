[< 📍 Shortcuts](../shortcuts.md)

# 🏈 Cache

```sh
> rugby shortcuts cache --help
```

```sh

 > Run the build and use commands.

 Options:
╭─────────────────────────────────────────────────────────────────────────────────────────────╮
│ -s, --sdk                  * Build SDK: sim or ios.                                         │
│ -a, --arch                 * Build architecture: auto, x86_64 or arm64.                     │
│ -c, --config               * Build configuration. (Debug)                                   │
│ -t, --targets []           * Target names to select. Empty means all targets.               │
│ -g, --targets-as-regex []  * Regular expression patterns to select targets.                 │
│ -e, --except []            * Target names to exclude.                                       │
│ -x, --except-as-regex []   * Regular expression patterns to exclude targets.                │
│ --result-bundle-path       * Path to xcresult bundle.                                       │
│ --warmup                   * Warmup cache with this endpoint.                               │
│ --headers []               * Extra HTTP header fields for warmup ("s3-key: my-secret-key"). │
│ --max-connections          * The maximum number of simultaneous connections. (10)           │
│ --archive-type             * Binary archive file type to use: zip or 7z.                    │
│ -o, --output               * Output mode: fold, multiline, silent, raw.                     │
╰─────────────────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭──────────────────────────────────────────────────────────────────────────────────╮
│ -r, --rollback    * Restore projects state before the last Rugby usage.          │
│ --prebuild        * Prebuild targets ignoring sources.                           │
│ --strip           * Build without debug symbols.                                 │
│ --try             * Run command in mode where only selected targets are printed. │
│ --ignore-cache    * Ignore shared cache.                                         │
│ --delete-sources  * Delete target groups from project.                           │
│ -v, --verbose []  * Increase verbosity level.                                    │
│ -q, --quiet []    * Decrease verbosity level.                                    │
│ -h, --help        * Show help information.                                       │
╰──────────────────────────────────────────────────────────────────────────────────╯
```

## Discussion

It just a combination of exist commands. You can call them separately:
```sh
> rugby rollback
> rugby build pre --except SomePod --arch x86_64
> rugby warmup s3.eu-west-2.amazonaws.com --except SomePod --arch x86_64
> rugby build full --except SomePod --arch x86_64
> rugby use --except SomePod
```

Or just use cache shortcut:
```sh
> rugby cache --rollback --prebuild --warmup s3.eu-west-2.amazonaws.com --except SomePod --arch x86_64
```

When you use cache or [plan](../plan.md) commands Rugby tries to reuse project cache.\
In huge projects it can save tens of seconds.
