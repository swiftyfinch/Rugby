
## 🏈 `Cache`

Convert remote pods to prebuilt dependencies.\
Call it after each `pod install` or `pod update`.

### General usage

```bash
$ pod install && rugby
```

##### Build for simulator (by default)

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

##### Keep Pods group in project

```bash
$ rugby --keep-sources

# short
$ rugby -k
```

##### Exclude pods from cache

```bash
$ rugby --exclude Alamofire SnapKit

# short
$ rugby -e Alamofire SnapKit
```

##### Build for device (arm64)

```bash
$ rugby --sdk ios

# short
$ rugby -s ios
```