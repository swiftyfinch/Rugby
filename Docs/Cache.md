
### 🏈 `Cache`

```
OVERVIEW: Convert pods to prebuilt dependencies.

OPTIONS:
  -s, --sdk <sdk>         Build sdks: sim/ios or both. (default: sim)
  -a, --arch <arch>       Build architectures. (default: [sim x86_64], [ios arm64].
                          In particular, [sim auto] means x86_64 on x86 mac, arm64 on arm64 mac.
                          In some case, build sim with arch wouldn't work properly. You can use [sim generic].)
  -c, --config <config>   Build configuration. (default: Debug)
  --bitcode               Add bitcode for archive builds.
  -k, --keep-sources      Keep Pods group in project.
  -e, --exclude <exclude> Exclude pods from cache.
  --include <include>     Include local pods.
  --focus <focus>         Keep selected local pods and cache others.
  --graph/--no-graph      Build changed pods parents. (default: true)
  --use-relative-paths    Use relative paths to cache folder.
  --off-debug-symbols     Build without debug symbols.
  --ignore-checksums      Ignore already cached pods checksums.
  --use-content-checksums (Beta) Use content checksums instead of
                          modification date.

  --bell/--no-bell        Play bell sound on finish. (default: true)
  --hide-metrics          Hide metrics.
  -v, --verbose           Print more information.
  -q, --quiet             Print nothing.
  --non-interactive       Print non-interactive output.
  --version               Show the version.
  -h, --help              Show help information.
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

## Build both sdks (sim x86_64, ios arm64)

It's all the same:

```bash
rugby -s sim ios
```

```bash
rugby --sdk sim ios --arch x86_64 arm64
```

## Build for specific configuration

```bash
rugby --config Debug
```

## Build for AppStore (for example)

```bash
rugby --config Release --sdk ios --bitcode
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

## Relative to Pods paths

Without passing this flag we have such default behaviour, for example:
```diff
- CONFIGURATION_BUILD_DIR = $PODS_CONFIGURATION_BUILD_DIR/Alamofire
+ CONFIGURATION_BUILD_DIR = ~/absolute_path_to_project/.rugby/build/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}/Alamofire
```

If you pass this flag it replaces paths in all CocoaPods config files with relative ones. ([#153](https://github.com/swiftyfinch/Rugby/issues/153))<br>
For example:
```bash
rugby --use-relative-paths
```

```diff
- CONFIGURATION_BUILD_DIR = $PODS_CONFIGURATION_BUILD_DIR/Alamofire
+ CONFIGURATION_BUILD_DIR = ${PODS_ROOT}/../.rugby/build/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}/Alamofire
```

## Disable debug symbols generation

With this flag, Rugby will off debug symbols generation and strip all already generated symbols.

It can be valuable in enormous projects. Usually, we don't need to debug binaries. It will be better to focus on a group of pods developing currently.
In some cases, it speeds up debugger attachment by 16x (147s vs 9s) in my work project.
Also, it slightly speeds up app launch time.

```bash
rugby --off-debug-symbols
```

## Checksums Algorithm

By default Rugby calculate checksums of file modification dates. But there are some issues with such method. As an alternative you can use file content checksums calculation ([#181](https://github.com/swiftyfinch/Rugby/pull/181)).

```bash
rugby --use-content-checksums
```
