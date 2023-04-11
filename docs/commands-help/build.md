[< 📚 Commands Help](README.md)

# 🏗️ Build

```sh
> rugby build --help
```

```sh

 > Build targets from Pods project.

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
╰────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭──────────────────────────────────────────────────╮
│ --ignore-cache    * Ignore shared cache.         │
│ --strip           * Build without debug symbols. │
│ -v, --verbose []  * Log level.                   │
│ -h, --help        * Show help information.       │
╰──────────────────────────────────────────────────╯
```

## Discussion

In the new 🏈 Rugby, you can build your Pods project without the step of integrating binaries into the project.\
It allows us to build many times with different configurations and in the end use them all at once.
```sh
> rugby build --arch arm64 --sdk sim
> rugby build --arch arm64 --sdk ios
> rugby use
```

If it’s not necessary for you, use the [`cache`](shortcuts/cache.md) command which is the combination of `build` and [`use`](use.md).
```sh
> rugby build && rugby use
```

Or just:
```sh
> rugby cache
```

<br>

The command will create a build target and add existing ones as dependencies based on passed options.\
Then Rugby will build this target with the `xcodebuild`. And finally, move all binaries to `~/.rugby/bin` folder.\
You can find build logs in `~/.rugby/logs` folder.

Also, this command doesn't rebuild targets if you already built them earlier. Rugby kept them in `~/.rugby/bin` folder.\
You can skip this behavior by passing a specific flag:
```sh
> rugby build --ignore-cache
```

<br>

### Disable debug symbols generation

With this flag, Rugby will off debug symbols generation and strip all already generated symbols in selected targets.
```sh
> rugby build --strip
```

It can be valuable in enormous projects. Usually, we don't need to debug binaries.\
It will be better to focus on a group of pods developing currently.\
In some cases, it speeds up debugger attachment by 16x (147s vs 9s) in my work project.\
Also, it slightly speeds up app launch time.
