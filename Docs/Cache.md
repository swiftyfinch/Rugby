
### 🏈 `Cache`

```
OVERVIEW: Convert pods to prebuilt dependencies.

OPTIONS:
  -a, --arch <arch>                 Build architechture. (default: x86_64 for sim)
  -c, --config <config>             Build Configuration. (default: Debug)
  -s, --sdk <sdk>                   Build sdk: sim or ios. (default: sim)
  -k, --keep-sources                Keep Pods group in project.
  -e, --exclude <exclude>           Exclude pods from cache.
  --include <include>               Include local pods.
  --focus <focus>                   Keep selected local pods and cache others.
  --ignore-checksums                Ignore already cached pods checksums.
  --graph                           Add parents of changed pods to build process.
                            
  --bell/--no-bell                  Play bell sound on finish. (default: true)
  --hide-metrics                    Hide metrics.
  -v, --verbose                     Print more information.
  --version                         Show the version.
  -h, --help                        Show help information.
```

<br>

## General usage

Call it after each `pod install` or `pod update`:
```bash
pod install && rugby
```

## Build for simulator (by default)

It's all the same:

```bash
rugby
```

```bash
rugby cache
```

```bash
rugby cache -s sim
```

```bash
rugby cache -s sim -a x86_64
```

```bash
rugby cache --sdk sim --arch x86_64
```

## Keep Pods group in project

```bash
rugby --keep-sources
```

## Exclude pods from cache

```bash
rugby --exclude Alamofire SnapKit
```

## Build for device (arm64)

```bash
rugby --sdk ios
```

## Build for specific configuration

```bash
rugby --config Debug
```

## Build local pods

You can include some local pods to cache:

```bash
rugby --include MyLocalPods1 MyLocalPods2
```

If you want to focus on some local pods and cache all others:

```bash
rugby --focus MyFocusedPod1 MyFocusedPod2
```

If you want to cache all local pods ([Maybe someday there will be another solution](https://github.com/apple/swift-argument-parser/pull/317)):

```bash
rugby --focus ""
```

## Ignore checksums

**Rugby** has cache file at `.rugby/cache.yml`. There keep checksums and other build settings. During each run **Rugby** try to save your time and do not pass all targets to Xcode building process. But sometimes something can get wrong. 

If you have troubles with the building process you can try to use that flag. It will ignore CocoaPods checksums and add all targets to Xcode build process. Also will be great if you report about that in the discussions sections. It can help to improve the cache system.

```bash
rugby --ignore-checksums
```

## Graph flag

When checksums of some pods changes, there can be parents whose checksum still unchanged. Sometimes those changes can break the building process. But it's a rare case. On the other hand, the rebuilding all parent spend a lot of time.

Please, report in the discussions section if you have some troubles building in Xcode after using Rugby. And pass this flag as a workaround:

```bash
rugby --graph
```
