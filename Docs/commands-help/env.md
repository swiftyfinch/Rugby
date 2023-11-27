[< 📚 Commands Help](README.md)

# 🌍 Env

```sh
> rugby env --help
```

```sh

 > Print Rugby environment.

 Flags:
╭──────────────────────────────────────╮
│ -h, --help  * Show help information. │
╰──────────────────────────────────────╯
```

## Discussion

This command prints the Rugby environment. For example:
```yml
Rugby version: 2.3.0
Swift: 5.9
CLT: Xcode 15.0.1 (Build version 15A507)
CPU: Apple M1 (arm64)
Project: Example
Git branch: main
RUGBY_KEEP_HASH_YAMLS: NO
RUGBY_PRINT_MISSING_BINARIES: NO
RUGBY_SHARED_DIR_ROOT: /Users/swiftyfinch
```

You can find the same environment output in the head of each Rugby log file.

<br>

### Keep hash YAML files

A flag to keep YAML files with target hash in the binaries folder.
```objc
RUGBY_KEEP_HASH_YAMLS=YES rugby
```
```sh
~/.rugby/bin
└─ Debug-iphonesimulator-arm64
   └─ 85d4367
      ├─ 85d4367.yml # Hash yml file
      └─ Alamofire.framework
```

### Print missing binaries as a tree

A flag to print missing binaries as a tree during an analysing process.
```objc
RUGBY_PRINT_MISSING_BINARIES=YES rugby
```
```
. Missing Binaries (3)
├─ Kingfisher-framework (1a1f878)
└─ Moya-framework (a4a42b2)
   └─ Alamofire-framework (85d4367)
```

### Set a custom path to shared folder root

A path to the root of shared folder (without `.rugby` folder name).
By default:
```objc
RUGBY_SHARED_DIR_ROOT=$HOME rugby
```
```sh
~
└─ .rugby # shared folder
   ├─ bin
   └─ logs
```

You can set a different one. For example, a current directory:
```objc
RUGBY_SHARED_DIR_ROOT=$PWD rugby
```
```sh
.
└─ .rugby # shared folder combined with local one
   ├─ backup
   ├─ bin
   ├─ build
   └─ logs
```
