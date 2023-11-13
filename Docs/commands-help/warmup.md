[< 📚 Commands Help](README.md)

# 🐳 Warmup

```sh
> rugby warmup --help
```

```sh

 > Download remote binaries for targets from Pods project.

 Arguments:
╭─────────────────────────────────────────────────────────────────────────────╮
│ endpoint  * Endpoint for your binaries storage (s3.eu-west-2.amazonaws.com) │
╰─────────────────────────────────────────────────────────────────────────────╯
 Options:
╭───────────────────────────────────────────────────────────────────────────────────╮
│ -s, --sdk                  * Build SDK: sim or ios.                               │
│ -a, --arch                 * Build architecture: auto, x86_64 or arm64.           │
│ -c, --config               * Build configuration. (Debug)                         │
│ -t, --targets []           * Targets for building. Empty means all targets.       │
│ -g, --targets-as-regex []  * Targets for building as a RegEx pattern.             │
│ -e, --except []            * Exclude targets from building.                       │
│ -x, --except-as-regex []   * Exclude targets from building as a RegEx pattern.    │
│ -o, --output               * Output mode: fold, multiline, silent, raw.           │
│ --timeout                  * Timeout for requests in seconds. (60)                │
│ --max-connections          * The maximum number of simultaneous connections. (10) │
╰───────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭─────────────────────────────────────────────────────────────────────────────────────────────╮
│ --analyse         * Run only in analyse mode without downloading. The endpoint is optional. │
│ --strip           * Build without debug symbols.                                            │
│ -v, --verbose []  * Increase verbosity level.                                               │
│ -q, --quiet []    * Decrease verbosity level.                                               │
│ -h, --help        * Show help information.                                                  │
╰─────────────────────────────────────────────────────────────────────────────────────────────╯
```

## Discussion

The command will try to download binaries from `https://${endpoint}/${module_name}/${config}-${sdk}-${arch}/${hash}`.\
It should be a zip archive for each module. And the archive should contain a product folder.\
For example, `https://s3.eu-west-2.amazonaws.com/Alamofire/Debug-iphonesimulator-x86_64/f38484e`.
```
f38484e (zip)
├─ f38484e.yml
└─ Alamofire.framework
```
And after unzipping the binary is moved to `~/.rugby/bin/Alamofire/Debug-iphonesimulator-x86_64/f38484e`.
<br><br>

## 🦮 Guides

- 🐳 [Remote Cache](../remote-cache.md)
