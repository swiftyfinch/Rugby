[< 🏗️ Build](../build.md)

# 🏗️ Pre

```sh
> rugby build pre --help
```

```sh

 > Prebuild targets ignoring sources.

 Options:
╭───────────────────────────────────────────────────────────────────────────────╮
│ -s, --sdk                  * Build SDK: sim or ios.                           │
│ -a, --arch                 * Build architecture: auto, x86_64 or arm64.       │
│ -c, --config               * Build configuration. (Debug)                     │
│ -t, --targets []           * Target names to select. Empty means all targets. │
│ -g, --targets-as-regex []  * Regular expression patterns to select targets.   │
│ -e, --except []            * Target names to exclude.                         │
│ -x, --except-as-regex []   * Regular expression patterns to exclude targets.  │
│ -o, --output               * Output mode: fold, multiline, silent, raw.       │
╰───────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭──────────────────────────────────────────────────╮
│ --strip           * Build without debug symbols. │
│ -v, --verbose []  * Increase verbosity level.    │
│ -q, --quiet []    * Decrease verbosity level.    │
│ -h, --help        * Show help information.       │
╰──────────────────────────────────────────────────╯
```

## Discussion

The command keeps only phases before `Sources` and then builds the project.\
Sometimes targets have "Generate something" build phases going before `Sources`.\
And it's important to finalize source code before running full build process.\
Otherwise, we will encounter the situation when target hashes are changed during building.\
And 🏈 Rugby will not be able to reuse them.
