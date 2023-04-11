[< 📚 Commands Help](README.md)

# 🚑 Doctor

```sh
> rugby doctor --help
```

```sh

 > Heal your wounds after using Rugby (or not).

 Flags:
╭──────────────────────────────────────╮
│ -h, --help  * Show help information. │
╰──────────────────────────────────────╯
```

## Discussion

The command contains some receipts for investigating 🏈 Rugby issues.\
Call it if you are in trouble.

```
🚑 If you have any problems, please try these solutions.
After each one, you need to repeat your usual workflow.
(⌘ + double click on the url) to open it in a browser.

1. Update 🏈 Rugby to the latest version: rugby update
   github.com/swiftyfinch/Rugby2/blob/next/docs/commands-help/update.md
2. Check that you're building the proper configuration.
   Sometimes projects don't have the default Debug config.
   rugby cache --config Your-Not-Debug-Config
   github.com/swiftyfinch/Rugby2/blob/next/docs/commands-help/shortcuts/cache.md
3. Add ignore option: rugby cache --ignore-cache.
   Be careful, you can't pass this option to plan command this way.
   github.com/swiftyfinch/Rugby2/blob/next/docs/commands-help/shortcuts/cache.md
4. Try rugby clear before repeating your usual workflow.
   github.com/swiftyfinch/Rugby2/blob/next/docs/commands-help/clear.md
5. Try to clean up your DerivedData and use rugby clear together.
6. Check that the Pods project builds successfully without 🏈 Rugby.

By the way, you can try to investigate building logs by yourself.
Last ones saved in folder: ~/.rugby/logs/09.04.2023T17.13.54 (example)

Open an issue/discussion on GitHub or by any convenient support channel.
Attach the last logs, but be sure that there are no sensitive data.
github.com/swiftyfinch/Rugby2/issues
github.com/swiftyfinch/Rugby2/discussions
```

Bless you 🍀
