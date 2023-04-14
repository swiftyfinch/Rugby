<p align="center">
   <img src="https://user-images.githubusercontent.com/64660122/194708589-7331a02a-6d6e-4c0f-a7ec-e367f7228080.gif" width="600"/>
</p>

<p align="center">
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dswift-versions" /></a>
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dplatforms" /></a>
  <br>
  <img src="https://img.shields.io/badge/Press_★_to_pay_respects-44494E?logo=github&logoColor=white" />
  <a href="https://twitter.com/swiftyfinch"><img src="https://img.shields.io/badge/SwiftyFinch-blue?logo=twitter&logoColor=white" /></a>
</p>


### 🏈 Rugby Remastered

> You can find all information in the [RC3 Readme](https://github.com/swiftyfinch/Rugby/tree/beta#readme).<br>
📦 The latest pre-release is [here](https://github.com/swiftyfinch/Rugby/releases/tag/2.0.0b8).


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

# How to install 📦

You can download 🏈 Rugby as a binary:
```sh
> curl -LO https://github.com/swiftyfinch/Rugby/releases/download/1.22.0/rugby.zip
> unzip rugby.zip
> sudo mkdir -p /usr/local/bin && sudo cp rugby/bin/rugby /usr/local/bin
```

Or you can build it from source, but be sure that you selected Xcode CLT (Preferences → Locations):
```sh
> git clone --depth 1 --branch 1.22.0 https://github.com/swiftyfinch/Rugby.git
> cd Rugby
> swift build -c release
> sudo mkdir -p /usr/local/bin && sudo cp `swift build -c release --show-bin-path`/rugby /usr/local/bin
```

If you look for the 🏈 Rugby Remastered, please visit [the last pre-release page](https://github.com/swiftyfinch/Rugby/releases/tag/2.0.0b9).

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

## 🐛 Contribution

> **Note**<br>
> Rugby 1.x is frozen for new feature requests. Please, open only requests with bug fixes.\
That's because there is [the new Rugby2.x version](https://github.com/swiftyfinch/Rugby/releases/tag/2.0.0b7) and it will be released soon.\
This new version isn't back-compatible with the first one and has an absolutely different code base.\
Also, Rugby2.x will be a closed code for the first time. And then I will open source after all preparations.\
Sorry for that freeze time, I hope we continue to develop this product together in the nearest future.

<br>

###### 📮 Support

If you want to support this project, you can do some of these:\
`1)` <ins><b>Press</b></ins> ⭐️. It's a great sign that Rugby is useful;\
`2)` <ins><b>Share</b></ins> the project 🌍 somewhere with anybody;\
`3)` <ins><b>Leave feedback</b></ins> in the discussions 💬 section.

If you have any questions or feature requests, feel free to open a discussion or an issue.
