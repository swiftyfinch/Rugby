<h3 align="center">
  Rugby 🏈<br>
  <sup>(<ins>like Ruby but with g</ins>)</sup>
</h3>
<p align="center">
    <img src="https://github.com/swiftyfinch/Rugby/blob/main/Demo.gif" width="400"/>
</p>
<p align="center">
    <img src="https://img.shields.io/badge/version-0.1.0-008800.svg" />
    <img src="https://img.shields.io/badge/Xcode_CLTool-12+-blue.svg" />
</p>

### `Motivation`

Working on a project with a huge amount of remote pods I had some troubles:\
`-` Slow and unnecessary indexing of remote pods targets, which implementation I rarely try to edit;\
`-` Reduntant rebuild time, probably as a result of problems in the project, CocoaPods hooks or Xcode build system;\
`-` Freezing UI during navigation.

`Rugby` is CLI tool that was developed to solve the above problems.
In the current version, `Rugby` can cache all remote pods dependencies and remove their targets from the Pods project.
Also, `Rugby` smart enough to rebuild only changed remote pods.

### ✈️ Test flight with `Homebrew`

```bash
$ brew tap swiftyfinch/Rugby https://github.com/swiftyfinch/Rugby.git
$ brew install rugby
```

##### Get new version

```bash
$ brew upgrade rugby
```

### `Usage`

```bash
$ pod install && rugby
```

##### Build for simulator

```bash
$ rugby

# or the same:
$ rugby cache

# or the same:
$ rugby cache --sdk sim

# or the same:
$ rugby cache --sdk sim --arch x86_64
```

##### Build for device (arm64)

```bash
$ rugby --sdk ios
```

##### After switch between sdks or in any unclear situation (ignore cache)

```bash
$ rugby --rebuild
```

### `Beta`

```bash
# Remove Pods group from project.
$ rugby --drop-sources

# Exclude pods from cache.
$ rugby --exclude Alamofire SnapKit
```

### `Maybe Roadmap`

- [x] Optionally remove source groups from project
- [ ] New commands: Reduce & Focus
- [ ] Custom build systems
- [ ] Open source

### `Author`

Vyacheslav Khorkov\
Twitter: [@SwiftyFinch](https://twitter.com/swiftyfinch)\
Blog: [swiftyfinch.github.io](https://swiftyfinch.github.io/en)\
Feel free to contact me for any questions.