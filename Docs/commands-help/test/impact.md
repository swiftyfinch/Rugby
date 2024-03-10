[< 🧪 Test](../test.md)

# 🧪 Impact

```sh
> rugby _test impact --help
```

```sh

 > (Experimental) Print affected test targets.

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

To determine the affected test targets, it is necessary to fix the state in which all tests are green.\
Let's call this state is ****the baseline****.\
To do this, please check out the documentation of the [`rugby _test pass`](pass.md) command.

Then we are ready to make changes to the project targets.\
This command allows you to find out which test targets have been changed or have changed dependencies compared to ****the baseline state****.

### Examples

```sh
> rugby _test impact
```

<img width="521" alt="Screenshot 2024-02-10 at 23 28 48" src="https://github.com/swiftyfinch/Rugby/assets/64660122/6dcebf18-0ecd-4ada-9f89-dee74c319a6a">

#### Raw output

```sh
> rugby _test impact --quiet --output raw
```

<img width="498" alt="Screenshot 2024-02-10 at 23 33 39" src="https://github.com/swiftyfinch/Rugby/assets/64660122/865ace27-523e-4852-8155-2a13f85ca262">

