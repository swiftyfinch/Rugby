<h3 align="center">
  Rugby 🏈<br>
  <sup>"Like Ruby but with g"</sup>
</h3>
<p align="center">
    <img src="https://github.com/swiftyfinch/Rugby/blob/main/Demo.gif" width="600"/>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Swift-orange.svg?logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/12+-blue.svg?logo=xcode&logoColor=white" />
  <img src="https://img.shields.io/badge/Brew-8B4513?logo=homebrew&logoColor=white" />
  <img src="https://img.shields.io/badge/CocoaPods-red?logo=cocoapods&logoColor=white" />
</p>

### `Motivation`

Working on a project with a huge amount of remote pods I had some troubles:\
`-` Slow and unnecessary indexing of remote pods targets, which implementation I rarely try to edit;\
`-` Redundant rebuild time, probably as a result of problems CocoaPods hooks or Xcode build system;\
`-` Freezing UI during navigation.

You can read 📖 [full story](https://swiftyfinch.github.io/en/2021-03-09-rugby-story/) on my blog.

### `Description`

🏈 `Rugby` is CLI tool that was developed to solve the above problems:\
`+` Cache all remote pods dependencies and remove their targets from the Pods project;\
`+` Rebuild only changed remote pods;\
`+` Remove unnecessary sources from a project and reduce project size;\
`+` Drop any unneeded targets with sources and resources by RegEx.

### `What makes it different?`

🕊 Not a dependency\
🔒 Doesn't change Podfile\
🛠 [Custom steps](Docs/Plans.md)\
📈 Metrics after each command\
✨ Fancy log output\
🚀 Swiftish!

Ruby alternatives:\
`-` [CocoaPods Binary](https://github.com/leavez/cocoapods-binary)\
`-` [PodBuilder](https://github.com/Subito-it/PodBuilder)\
`-` [CocoaPods Binary Cache](https://github.com/grab/cocoapods-binary-cache)

### `Discussions`

You can read more about 🏈 Rugby in `discussions` section.\
Feel free to report any issues or suggest some new feature requests.

<br>

## Quick start with <a href="https://brew.sh">Homebrew</a>🍺

```bash
brew tap swiftyfinch/Rugby https://github.com/swiftyfinch/Rugby.git
brew install rugby
```

Get new version:
```bash
brew upgrade rugby
```

## How to use 🏈

Run in your project directory after each pod install:
```bash
pod install && rugby
```
Or read more [about Plans](Docs/Plans.md#-generate-example) ✈️

## Documentation 📚

| Command | Description |
| :----- | :------ |
🚑 [`Help`](Docs/README.md) | General Rugby documentation.
🏈 [`Cache`](Docs/Cache.md) | Convert remote pods to prebuilt dependencies.
✈️ [`Plans`](Docs/Plans.md) | Run a predefined sequence of commands.
🔍 [`Focus`](Docs/Focus.md) | Keep only selected targets and all their dependencies.
🗑 [`Drop`](Docs/Drop.md) | Remove any targets by RegEx.

<br>

### `Maybe Roadmap`

- [x] New command - Focus
- [ ] Optimization
- [ ] Improve Cache command
- [ ] Open source

### `Author`

Vyacheslav Khorkov\
Twitter: [@SwiftyFinch](https://twitter.com/swiftyfinch)\
Blog: [swiftyfinch.github.io](https://swiftyfinch.github.io/en)\
Feel free to contact me for any questions.
