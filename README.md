<p align="center">
   <img src="https://user-images.githubusercontent.com/64660122/194708589-7331a02a-6d6e-4c0f-a7ec-e367f7228080.gif" width="600"/>
</p>

<p align="center">
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?color=orange&label=Swift&logo=swift&logoColor=white&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dswift-versions" /></a>
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?label=Platform&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dplatforms" /></a>
  <br>
  <a href="https://brew.sh"><img src="https://img.shields.io/badge/🍺_Homebrew-8B4513" /></a>
  <a href="https://github.com/yonaskolb/Mint"><img src="https://img.shields.io/badge/Mint-darkgreen?logo=leaflet&logoColor=white" /></a>
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/badge/Swift_Package_Index-red?logo=swift&logoColor=white" /></a>
  <br>
  <img src="https://img.shields.io/badge/Press_★_to_pay_respects-44494E?logo=github&logoColor=white" />
  <a href="https://twitter.com/swiftyfinch"><img src="https://img.shields.io/badge/SwiftyFinch-blue?logo=twitter&logoColor=white" /></a>
  <br>
  <a href="https://github.com/swiftyfinch/Rugby/releases/tag/2.0.0b6"><img src="https://img.shields.io/badge/Release_Candidate_Available-4BA057" /></a>
</p>


# Motivation

Working on a project with a huge amount of pods I had some troubles:\
`-` Slow and unnecessary indexing of pods targets, which implementation I rarely try to edit;\
`-` Redundant rebuild time, probably as a result of problems [CocoaPods](https://cocoapods.org) hooks or Xcode build system;\
`-` Freezing UI during navigation.

You can read 📖 [full story](https://swiftyfinch.github.io/en/2021-03-09-rugby-story/) on my blog.

## Description

🏈 `Rugby` is CLI tool that was developed to solve the above problems:\
`+` Cache all pods dependencies and remove their targets from the Pods project;\
`+` Rebuild only changed pods;\
`+` Remove unnecessary sources from a project and reduce project size;\
`+` Drop any unneeded targets with sources and resources by RegEx.

## What makes it different?

🕊 Not a dependency, just an optional step\
🔒 Doesn't change Podfile and Podfile.lock\
🛠 [Custom steps](Docs/Plans.md)\
📈 Metrics after each command\
✨ Fancy log output\
🚀 Swiftish!

Ruby alternatives: [PodBuilder](https://github.com/Subito-it/PodBuilder) | [CocoaPods Binary Cache](https://github.com/grab/cocoapods-binary-cache) | [CocoaPods Binary](https://github.com/leavez/cocoapods-binary)

### Discussions

You can read more about 🏈 Rugby in [discussions](https://github.com/swiftyfinch/Rugby/discussions) section.\
Feel free to report any issues or suggest some new feature requests.

<br>

# Install using [Homebrew](https://brew.sh) 🍺

```shell
brew tap swiftyfinch/Rugby https://github.com/swiftyfinch/Rugby.git
brew install rugby
```
More information 🎬 [here](https://github.com/swiftyfinch/Rugby/discussions/71).

## 🏈 Rugby Remastered <a href="https://github.com/swiftyfinch/Rugby/releases/tag/2.0.0b6"><img src="https://img.shields.io/badge/Release_Candidate_Available-4BA057" /></a>

You can find all information in the [readme](https://github.com/swiftyfinch/Rugby/tree/beta#readme).<br>
📦 The latest pre-release is [here](https://github.com/swiftyfinch/Rugby/releases/tag/2.0.0b6).

<br>

# How to use 🏈

Run in your project directory after each pod install:
```shell
pod install && rugby
```
Watch 🎬 [Basic Usage Demo](https://github.com/swiftyfinch/Rugby/discussions/72).<br>
Read more [about advanced usage](Docs/Plans.md#-generate-example).

## Documentation 📚

| Command | Description |
| :----- | :------ |
🚑 [Help](Docs/README.md) | General Rugby documentation.
🏈 [Cache](Docs/Cache.md) | Convert pods to prebuilt dependencies.
✈️ [Plans](Docs/Plans.md) | Run a predefined sequence of commands.
🔍 [Focus](Docs/Focus.md) | Keep only selected targets and all their dependencies.
🗑 [Drop](Docs/Drop.md) | Remove any targets by RegEx.

| 🎓 How To |
| :----- |
🎬 [Installation Demo](https://github.com/swiftyfinch/Rugby/discussions/71)
🎬 [Basic Usage Demo](https://github.com/swiftyfinch/Rugby/discussions/72)
🎬 [Debug Demo](https://github.com/swiftyfinch/Rugby/discussions/142)

###### Known limitations

`-` Not supported WatchOS SDK

<br>

###### 📮 Support

If you want to support this project, you can do some of these:\
`1)` <ins><b>Press</b></ins> ⭐️. It's a great sign that Rugby is useful;\
`2)` <ins><b>Share</b></ins> the project 🌍 somewhere with anybody;\
`3)` <ins><b>Leave feedback</b></ins> in the discussions 💬 section.

If you have any questions or feature requests, feel free to open a discussion or an issue.
