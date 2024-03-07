[< 🧪 Test](../test.md)

# 🧪 Pass

```sh
> rugby _test pass --help
```

```sh

 > (Experimental) Mark test targets as passed.

 Options:
╭──────────────────────────────────────────────────────────────────────────────────────────╮
│ -u, --up-to-date-branch    * Skip if the current branch is not up-to-date to target one. │
│ -s, --sdk                  * Build SDK: sim or ios.                                      │
│ -a, --arch                 * Build architecture: auto, x86_64 or arm64.                  │
│ -c, --config               * Build configuration. (Debug)                                │
│ -t, --targets []           * Target names to select. Empty means all targets.            │
│ -g, --targets-as-regex []  * Regular expression patterns to select targets.              │
│ -e, --except []            * Target names to exclude.                                    │
│ -x, --except-as-regex []   * Regular expression patterns to exclude targets.             │
│ -o, --output               * Output mode: fold, multiline, silent, raw.                  │
╰──────────────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭──────────────────────────────────────────────────╮
│ --strip           * Build without debug symbols. │
│ --skip-signing    * Disable code signing.        │
│ -v, --verbose []  * Increase verbosity level.    │
│ -q, --quiet []    * Decrease verbosity level.    │
│ -h, --help        * Show help information.       │
╰──────────────────────────────────────────────────╯
```

## Discussion

To determine the affected test targets, it is necessary to fix the state in which all tests are green.\
Let's call this state is **the baseline**.

This command allows you to mark tests as passed (sets **the baseline**).\
You can mark all tests at once or do it selectively.

Then we are ready to make changes to the project targets.\
And finally, we can analyse which test targets have been changed or have changed dependencies compared to **the baseline state**.\
To do this, please check out the documentation of the [`rugby _test impact`](impact.md) command.

### Examples

```sh
> rugby _test pass
```

<img width="389" alt="Screenshot 2024-02-10 at 23 29 28" src="https://github.com/swiftyfinch/Rugby/assets/64660122/c7097732-7910-498e-94be-526bc5bce427">
