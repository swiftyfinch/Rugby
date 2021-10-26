<p align="center">
  <img src="https://user-images.githubusercontent.com/64660122/138951283-9e69195f-6dda-4a5c-a6bf-66be0cb3d2bb.jpeg" width="600"/>
</p>
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
  <br>
  <img src="https://img.shields.io/badge/Press_star_for_pay_respect-gray?logo=github" />
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/64660122/138950621-9432e44e-9413-4f6a-ac11-774199f68e9e.mov" />
</p>


### `Motivation`

Working on a project with a huge amount of pods I had some troubles:\
`-` Slow and unnecessary indexing of pods targets, which implementation I rarely try to edit;\
`-` Redundant rebuild time, probably as a result of problems `CocoaPods` hooks or Xcode build system;\
`-` Freezing UI during navigation.

You can read 📖 [full story](https://swiftyfinch.github.io/en/2021-03-09-rugby-story/) on my blog.

### `Description`

🏈 `Rugby` is CLI tool that was developed to solve the above problems:\
`+` Cache all pods dependencies and remove their targets from the Pods project;\
`+` Rebuild only changed pods;\
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
brew install mint
mint install swiftyfinch/rugby

# Now on Mint 0.17.0 you'll need to add ~/.mint/bin to your $PATH
# For example, add this to your ~/.zshrc file and relaunch terminal
export PATH=$HOME/.mint/bin:$PATH
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
🏈 [`Cache`](Docs/Cache.md) | Convert pods to prebuilt dependencies.
✈️ [`Plans`](Docs/Plans.md) | Run a predefined sequence of commands.
🔍 [`Focus`](Docs/Focus.md) | Keep only selected targets and all their dependencies.
🗑 [`Drop`](Docs/Drop.md) | Remove any targets by RegEx.

<br>

### `Maybe Roadmap`

- [ ] [Optional arrays #317](https://github.com/apple/swift-argument-parser/pull/317)

### `Author`

Vyacheslav Khorkov\
Twitter: [@SwiftyFinch](https://twitter.com/swiftyfinch)\
Blog: [swiftyfinch.github.io](https://swiftyfinch.github.io/en)\
Feel free to contact me
