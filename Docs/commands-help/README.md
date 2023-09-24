[< Documentation](../README.md)

# 📖 Commands Help

```sh
> rugby --help
```

```sh
 Subcommands:
╭──────────────────────────────────────────────────────────────────────╮
│ shortcuts  * Set of base commands combinations.                      │
│ build      * Build targets from Pods project.                        │
│ use        * Use already built binaries instead of sources.          │
│ delete     * Delete targets from the project.                        │
│ warmup     * Download remote binaries for targets from Pods project. │
│ rollback   * Restore projects state before the last Rugby usage.     │
│ plan       * Run sequence of Rugby commands.                         │
│ clear      * Clear modules cache.                                    │
│ update     * Update Rugby version.                                   │
│ doctor     * Heal your wounds after using Rugby (or not).            │
│ shell      * Run shell command from Rugby.                           │
│ env        * Print Rugby environment.                                │
╰──────────────────────────────────────────────────────────────────────╯
 Flags:
╭──────────────────────────────────────╮
│ --version   * Show the version.      │
│ -h, --help  * Show help information. │
╰──────────────────────────────────────╯
```

| [Basic](#basic) | [Mixed](#mixed) | [Utils](#utils) |
| :---: | :---: | :---: |
| 🏗️ [Build](build.md) | 📍 [Shortcuts](shortcuts.md) | 🧼 [Clear](clear.md) |
| 🎯 [Use](use.md) | ⛱️ [Umbrella](shortcuts/umbrella.md) | 📦 [Update](update.md) |
| 🗑️ [Delete](delete.md) | 🏈 [Cache](shortcuts/cache.md) | 🚑 [Doctor](doctor.md) |
| 🐳 [Warmup](warmup.md) | ✈️ [Plan](plan.md) | 🐚 [Shell](shell.md) |
| ♻️ [Rollback](rollback.md) | | 🌍 [Env](env.md) |

## Basic

```mermaid
flowchart LR
    S((("Rugby")))
    S --> A("Basic")

    A --> AA(["🏗️ Build"]) -.-> AAA["
    Build targets from Pods project
    "]
    style AA color:#539bf5
    click AA "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/build.md" _blank

    A --> AB(["🎯 Use"]) -.-> ABA["
    Use already built binaries
    instead of sources
    "]
    style AB color:#539bf5
    click AB "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/use.md" _blank

    A --> AC(["🗑️ Delete"]) -.-> ACA["
    Delete targets from the project
    "]
    style AC color:#539bf5
    click AC "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/delete.md" _blank

    A --> AD(["🐳 Warmup"]) -.-> ADA["
    Download remote binaries
    for targets from Pods project
    "]
    style AD color:#539bf5
    click AD "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/warmup.md" _blank

    A --> AE(["♻️ Rollback"]) -.-> AEA["
    Restore projects state
    before the last Rugby usage
    "]
    style AE color:#539bf5
    click AE "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/rollback.md" _blank
```

## Mixed

```mermaid
flowchart LR
    A((("Rugby")))
    A --> B("
   📍 Shortcuts
   (default)
   ")
    B --> BA("🏈 Cache")
    BA --> BAA("
    ♻️ Rollback
    🐳 Warmup
    🏗️ Build
    🎯 Use
    ")
    B --> BB("
    ⛱️ Umbrella
    (default)
    ")
    BB --> BA
    BB --> D
    A --> D("✈️ Plan")
    D --> DA("
    Any combination
    of commands
    ")
    A --> F("🏗️ Build")
    A --> G("🎯 Use")
    A --> H("🗑️ Delete")
    A --> E("🐳 Warmup")
    A --> J("♻️ Rollback")
    click B "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/shortcuts.md" _blank
```

```mermaid
flowchart TD
    S((("Rugby")))
    S --> A("Mixed")

    A --> AA["
    📍 Shortcuts (default)<hr>Set of base commands
    combinations
    "]
    style AA color:#539bf5
    click AA "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/shortcuts.md" _blank

    AA --> AAB["
    🏈 Cache<hr>Run the build and use commands
    "]
    style AAB color:#539bf5
    click AAB "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/shortcuts/cache.md" _blank

    AA --> AAA["
    ⛱️ Umbrella (default)<hr>Run the plan command
    if plans file exists or
    run the cache command
    "]
    style AAA color:#539bf5
    click AAA "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/shortcuts/umbrella.md" _blank

    AAA --> AAB
    AAA --> AB

    A --> AB["
    ✈️ Plan<hr>Run sequence of Rugby commands
    "]
    style AB color:#539bf5
    click AB "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/plan.md" _blank
```

## Utils

```mermaid
flowchart LR
    S((("Rugby")))
    S --> A("Utils")

    A --> AA(["🧼 Clear"]) -.-> AAA["
    Clear modules cache
    "]
    style AA color:#539bf5
    click AA "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/clear.md" _blank

    A --> AB(["📦 Update"]) -.-> ABA["
    Update Rugby version
    "]
    style AB color:#539bf5
    click AB "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/update.md" _blank

    A --> AC(["🚑 Doctor"]) -.-> ACA["
    Heal your wounds
    after using Rugby (or not)
    "]
    style AC color:#539bf5
    click AC "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/doctor.md" _blank

    A --> AE(["🐚 Shell"]) -.-> AEA["
    Run shell command from Rugby
    "]
    style AE color:#539bf5
    click AE "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/shell.md" _blank

    A --> AF(["🌍 Env"]) -.-> AFA["
    Print Rugby environment
    "]
    style AF color:#539bf5
    click AF "https://github.com/swiftyfinch/Rugby/blob/main/Docs/commands-help/env.md" _blank
```
