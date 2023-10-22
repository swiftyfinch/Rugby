[< 📚 Commands Help](README.md)

# ♻️ Rollback

```sh
> rugby rollback --help
```

```sh

 > Restore projects state before the last Rugby usage.

 Options:
╭────────────────────────────────────────────────────────────╮
│ -o, --output  * Output mode: fold, multiline, silent, raw. │
╰────────────────────────────────────────────────────────────╯
 Flags:
╭───────────────────────────────────────────────╮
│ -v, --verbose []  * Increase verbosity level. │
│ -q, --quiet []    * Decrease verbosity level. │
│ -h, --help        * Show help information.    │
╰───────────────────────────────────────────────╯
```

## Discussion

🏈 Rugby always must be used after `pod install` command.\
But in huge projects, this command can take several minutes.

If you just want to deintegrate Rugby, call this:
```sh
> rugby rollback
```
It takes several seconds. Your projects will be reset to state before the last Rugby use.

Be careful, if you add some changes to your project after using Rugby, you lose them after calling `rollback`.\
Use `pod install` instead of `rollback` in such cases.




