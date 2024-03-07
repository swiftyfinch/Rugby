[< 🧪 Test](../test.md)

# 🧪 Run

```sh
> rugby _test run --help
```

```sh

 > (Experimental) Run tests by impact or not.

 Options:
╭──────────────────────────────────────────────────────────────────────────────────╮
│ -n, --simulator-name          * A simulator name.                                │
│ -p, --testplan-template-path  * A path to testplan template.                     │
│ --result-bundle-path          * Path to xcresult bundle.                         │
│ -s, --sdk                     * Build SDK: sim or ios.                           │
│ -a, --arch                    * Build architecture: auto, x86_64 or arm64.       │
│ -c, --config                  * Build configuration. (Debug)                     │
│ -t, --targets []              * Target names to select. Empty means all targets. │
│ -g, --targets-as-regex []     * Regular expression patterns to select targets.   │
│ -e, --except []               * Target names to exclude.                         │
│ -x, --except-as-regex []      * Regular expression patterns to exclude targets.  │
│ -o, --output                  * Output mode: fold, multiline, silent, raw.       │
╰──────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭───────────────────────────────────────────────────────────────────────────╮
│ --impact          * Select tests by impact.                               │
│ --pass            * Mark test targets as passed if all tests are succeed. │
│ --strip           * Build without debug symbols.                          │
│ --skip-signing    * Disable code signing.                                 │
│ -v, --verbose []  * Increase verbosity level.                             │
│ -q, --quiet []    * Decrease verbosity level.                             │
│ -h, --help        * Show help information.                                │
╰───────────────────────────────────────────────────────────────────────────╯
```

## Discussion

It's an experimental command to test your CocoaPods project by an impact analysis or not.

First of all, if you want to use an impact analysis you need to fix the state in which all tests are green.\
To do this, please check out the documentation of the [`rugby _test pass`](pass.md) command.

Then you should pass at least two options.\
The first one is a simulator name. For example, `--simulator-name "iPhone 15"`.\
This name will be used in `xcodebuild test -destination "platform=iOS Simulator,name=iPhone 15"`.

And the second one is a relative path to `*.xctestplan` of your project.\
For example, `--testplan-template-path ExampleFrameworks.xctestplan`.\
The configurations of testplan will be copied to a new testplan.\
Then it will be filled with test targets and finally, it will be used as `xcodebuild test -testPlan`.

### Example

Use it with an impact analysis:

```sh
> rugby _test --simulator-name 'iPhone 15' --testplan-template-path ExampleFrameworks.xctestplan --impact

# Short version
> rugby _test -n 'iPhone 15' -p ExampleFrameworks.xctestplan --impact
```

<img width="869" alt="Screenshot 2024-03-04 at 00 40 39" src="https://github.com/swiftyfinch/Rugby/assets/64660122/02f9a024-fb2b-4258-867c-66bac7c61cc6">


#### Without impact

```sh
> rugby _test --simulator-name 'Phone 15' --testplan-template-path ExampleFrameworks.xctestplan
```
