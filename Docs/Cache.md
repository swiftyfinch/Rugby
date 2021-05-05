
### 🏈 `Cache`

```
OVERVIEW: Convert remote pods to prebuilt dependencies.

OPTIONS:
  -a, --arch <arch>           Build architechture. 
  -s, --sdk <sdk>             Build sdk: sim or ios. (default: sim)
  -k, --keep-sources          Keep Pods group in project. 
  -e, --exclude <exclude>     Exclude pods from cache. 
  --ignore-cache              Ignore already cached pods checksums. 
  --skip-parents              Skip building parents of changed pods.
                               
  --bell/--no-bell            Play bell sound on finish. (default: true)
  --hide-metrics              Hide metrics. 
  -v, --verbose               Print more information. 
  --version                   Show the version.
  -h, --help                  Show help information.
```

---

### General usage

Call it after each `pod install` or `pod update`.
```bash
$ pod install && rugby
```

---

### Build for simulator (by default)

```bash
$ rugby

# or the same:
$ rugby cache

# or the same:
$ rugby cache -s sim

# or the same:
$ rugby cache --sdk sim

# or the same:
$ rugby cache -s sim -a x86_64

# or the same:
$ rugby cache --sdk sim --arch x86_64
```

---

### Keep Pods group in project

```bash
$ rugby --keep-sources

# short
$ rugby -k
```

---

### Exclude pods from cache

```bash
$ rugby --exclude Alamofire SnapKit

# short
$ rugby -e Alamofire SnapKit
```

---

### Build for device (arm64)

```bash
$ rugby --sdk ios

# short
$ rugby -s ios
```