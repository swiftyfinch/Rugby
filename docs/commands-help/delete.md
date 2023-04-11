[< 📚 Commands Help](README.md)

# 🗑️ Delete

```sh
> rugby delete --help
```

```sh

 > Delete targets from the project.

 Options:
╭────────────────────────────────────────────────────────────────────────────────╮
│ -p, --path                 * Project location. (Pods/Pods.xcodeproj)           │
│ -t, --targets []           * Targets for building.                             │
│ -r, --targets-as-regex []  * Targets for building as a RegEx pattern.          │
│ -e, --except []            * Exclude targets from building.                    │
│ -x, --except-as-regex []   * Exclude targets from building as a RegEx pattern. │
│ -o, --output               * Output mode: fold, multiline, quiet.              │
╰────────────────────────────────────────────────────────────────────────────────╯
 Flags:
╭────────────────────────────────────────────────────────────╮
│ --safe            * Keep dependencies of excepted targets. │
│ --delete-sources  * Delete target groups from project.     │
│ -v, --verbose []  * Log level.                             │
│ -h, --help        * Show help information.                 │
╰────────────────────────────────────────────────────────────╯
```

## Discussion

Usually, you don't need to delete targets from projects.\
But if you work in a huge one, it can be useful to focus on a few of them.

For example, I delete tests of different development teams when I'm pretty sure I won't break them.\
BTW, these targets will be present in a final pipeline on CI.
```sh
> rugby delete --targets-as-regex ".*Tests" --except "MyDevelopmentTeamTests"
```
This call will keep only test target `MyDevelopmentTeamTests` and will remove all targets with suffix `Tests`.

<br>

Also, you can select not only the Pods project. For example, if right now I don't care about tests there:
```sh
> rugby delete --path MyMainProject.xcodeproj --targets UITests UnitTests
```
But be careful, this trick is useful if you use some Xcode project generator and don't keep your project under git.
