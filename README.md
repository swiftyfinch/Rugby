<h3 align="center">
  Rugby 🏈<br>
  <sup>"Like Ruby but with g"</sup>
</h3>
<p align="center">
  <img src="https://github.com/swiftyfinch/Rugby/blob/main/Assets/Demo.gif" width="600"/>
</p>
<p align="center">
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?color=orange&label=Swift&logo=swift&logoColor=white&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dswift-versions" /></a>
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?label=Platform&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dplatforms" /></a>
  <br>
  <a href="https://github.com/yonaskolb/Mint"><img src="https://img.shields.io/badge/Mint-darkgreen?logo=leaflet&logoColor=white" /></a>
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/badge/Swift_Package_Index-red?logo=swift&logoColor=white" /></a>
  <a href="https://twitter.com/swiftyfinch"><img src="https://img.shields.io/badge/@swiftyfinch-blue?logo=twitter&logoColor=white" /></a>
</p>

### `Motivation`

Working on a project with a huge amount of remote pods I had some troubles:\
`-` Slow and unnecessary indexing of remote pods targets, which implementation I rarely try to edit;\
`-` Redundant rebuild time, probably as a result of problems `CocoaPods` hooks or Xcode build system;\
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

You can read more about 🏈 Rugby in [`discussions`](https://github.com/swiftyfinch/Rugby/discussions) section.\
Feel free to report any issues or suggest some new feature requests.

<br>

## Quick start with <a href="https://github.com/yonaskolb/Mint">Mint</a> 🌱

```bash
mint install swiftyfinch/rugby
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

- [ ] Unit tests
- [ ] [Improve Cache command](https://github.com/apple/swift-argument-parser/pull/317)

### `Author`

Vyacheslav Khorkov\
Twitter: [@SwiftyFinch](https://twitter.com/swiftyfinch)\
Blog: [swiftyfinch.github.io](https://swiftyfinch.github.io/en)\
Feel free to contact me for any questions.
