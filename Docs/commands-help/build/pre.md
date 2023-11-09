[< 📚 Commands Help](README.md)

# 🏗️ Pre

```sh
> rugby build pre --help
```

```sh

 > Prebuild targets ignoring sources.

 Options:
╭────────────────────────────────────────────────────────────────────────────────╮
│ -s, --sdk                  * Build SDK: sim or ios.                            │
│ -a, --arch                 * Build architecture: auto, x86_64 or arm64.        │
│ -c, --config               * Build configuration. (Debug)                      │
│ -t, --targets []           * Targets for building. Empty means all targets.    │
│ -g, --targets-as-regex []  * Targets for building as a RegEx pattern.          │
│ -e, --except []            * Exclude targets from building.                    │
│ -x, --except-as-regex []   * Exclude targets from building as a RegEx pattern. │
│ -o, --output               * Output mode: fold, multiline, silent, raw.        │
╰────────────────────────────────────────────────────────────────────────────────╯
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
Otherwise, we will encounter with situation when target hashes will be changed during building.\
And 🏈 Rugby will not be able to reuse them.
