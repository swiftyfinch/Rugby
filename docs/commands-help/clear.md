[< 📚 Commands Help](README.md)

# 🧼 Clear

```sh
> rugby clear --help
```

```sh

 > Clear modules cache.

 Subcommands:
╭───────────────────────────────────────╮
│ build   * Delete .rugby/build folder. │
│ shared  * Delete .rugby/bin folder.   │
╰───────────────────────────────────────╯
 Options:
╭──────────────────────────────────────────────────────────╮
│ -m, --modules []  * List of modules for deletion.        │
│ -o, --output      * Output mode: fold, multiline, quiet. │
╰──────────────────────────────────────────────────────────╯
 Flags:
╭────────────────────────────────────────────╮
│ -v, --verbose []  * Log level.             │
│ -h, --help        * Show help information. │
╰────────────────────────────────────────────╯
```

| Subcommands |
| :---: |
| 🧼 [Build](clear/build.md) |
| 🧼 [Shared](clear/shared.md) |

## Discussion

By default, 🏈 Rugby cleans shared binaries and the build folder if they take about 50 GB.\
If you want to clean them up by yourself, call `clear` command or its subcommands.

You can delete specific modules binaries:
```sh
> rugby clear --modules PodA PodB
```

Or you can delete all binaries:
```sh
> rugby clear shared
```

Also, you can delete just the build folder:
```sh
> rugby clear build
```

And finally, you can delete all binaries and build folder:
```sh
> rugby clear
```
