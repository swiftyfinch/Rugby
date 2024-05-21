<p align="center">
  <img src="https://user-images.githubusercontent.com/64660122/140398205-9328806e-897d-483d-a898-c90f66840196.png" width=600 />
  <br>
  <img src="https://img.shields.io/badge/Platform-macOS-2679eb" />
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dswift-versions" /></a>
  <br>
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby/main/documentation/rugbyfoundation"><img src="https://img.shields.io/badge/Docs-4BA057?logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB2ZXJzaW9uPSIxLjEiIHZpZXdCb3g9IjAgMCAxNiAxNiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB4PSIxLjQiIHk9IjIuMzUiIHdpZHRoPSIxMy4yIiBoZWlnaHQ9IjkuOCIgc3R5bGU9ImZpbGw6ICNkZmRiZjM7IG9wYWNpdHk6IDAuMzMzMzM7Ii8%2BPHBhdGggc3R5bGU9ImZpbGw6ICNmZmY7IiBkPSJNMCwxLjc1YzAsLTAuNCAwLjM1LC0wLjg1IDAuNzUsLTAuODVjMi43LDAgNS4yNSwtMC42IDcuMjUsMS40YzIsLTIgNC4yNSwtMS40IDcuMjUsLTEuNGMwLjQsMCAwLjc1LDAuNCAwLjc1LDAuODV2MTAuNWMwLDAuNCAtMC4zNSwwLjc1IC0wLjc1LDAuNzVjLTIuNSwwIC00LjgsLTAuNiAtNi43NSwxLjNjLTAuMjUsMC4yNSAtMC43NSwwLjI1IC0xLDBjLTEuNzUsLTEuNyAtNC40NSwtMS4zIC02Ljc1LC0xLjNjLTAuNCwwIC0wLjc1LC0wLjM1IC0wLjc1LC0wLjc1em03LjI1LDEwLjI1di03LjI1Yy0wLjA4LC0yLjk1IC0zLjYsLTIuMjUgLTUuNzUsLTIuMjV2OWMxLjk1LDAgMy45NSwtMC4zIDUuNzUsMC41em0xLjUsLTcuMjV2Ny4yNWMxLjc1LC0wLjg1IDMuODUsLTAuNSA1Ljc1LC0wLjV2LTljLTIuMjUsMCAtNS43NSwtMC43IC01Ljc1LDIuMjV6Ii8%2BPC9zdmc%2BCg%3D%3D" /></a>
  <a href="https://app.codecov.io/gh/swiftyfinch/Rugby"><img src="https://img.shields.io/codecov/c/github/swiftyfinch/rugby/main?label=Coverage"></a>
  <a href="https://tooomm.github.io/github-release-stats/?username=swiftyfinch&repository=Rugby"><img src="https://img.shields.io/github/downloads/swiftyfinch/Rugby/total?label=Downloads&logo=github"></a>
  <a href="https://github.com/withfig/autocomplete/pull/2105"><img src="https://img.shields.io/badge/Fig-fff?logo=fig&logoColor=black" /></a>
  <br>
  <img src="https://img.shields.io/badge/Press_★_to_pay_respects-fff?logo=github&logoColor=black" />
  <a href="https://twitter.com/swiftyfinch"><img src="https://img.shields.io/badge/SwiftyFinch-blue?logo=twitter&logoColor=white" /></a>
</h1>

<h1></h1>

<p align="center">
  <img src="https://user-images.githubusercontent.com/64660122/230763146-d467dafb-252c-46ce-93d6-f2309e5aabc8.gif" width=600>
</p>

# Motivation

Why do we need some optimizations while working on huge projects with [CocoaPods](https://github.com/CocoaPods/CocoaPods)?\
`-` Slow and unnecessary indexing of pods targets, which implementation we rarely try to edit;\
`-` Redundant rebuild time, probably as a result of problems, related to CocoaPods or Xcode;\
`-` Freezing UI during navigating through a project or editing it;\
`-` Broken or extremely slow autocompletion;\
`-` Noisy laptop turbines, heated aluminum, and infinite spinning pinwheel.

More in the 📖 [foundation](https://swiftyfinch.github.io/en/2021-03-09-rugby-story/) and [remastering](https://swiftyfinch.github.io/en/2023-04-22-rugby-remastered/) stories.

## Description

🏈 `Rugby` is CLI tool that was developed to solve the above problems:\
`+` Cache all pods dependencies and remove their targets from the Pods project;\
`+` Rebuild only changed pods or even download them;\
`+` Delete any unneeded targets with sources from a project and reduce its size.

## What makes it different?

🕊 Not a project dependency, just an optional step;\
🌱 Doesn't change Podfile and Podfile.lock;\
✈️ Can run [a sequence of commands from a YAML file](Docs/commands-help/plan.md);\
🕹️ Single command usage;\
🐳 Ready for [remote cache](Docs/remote-cache.md);\
🧣 Cozy log output;\
🚀 Swiftish and uses native Xcode build system.

Ruby alternatives: [PodBuilder](https://github.com/Subito-it/PodBuilder) | [CocoaPods Binary Cache](https://github.com/grab/cocoapods-binary-cache) | [CocoaPods Binary](https://github.com/leavez/cocoapods-binary)

<br>

# How to install 📦

First of all, if you have the first version `Rugby 1.x`, you need to delete it.\
Then call `where rugby` command and be sure that there are no any of paths to rugby.

### First Install

```sh
curl -Ls https://swiftyfinch.github.io/rugby/install.sh | bash
```

### Self-Update

If you already have Rugby, which version is at least `2.0.0b2`, you can use such a command.

```sh
> rugby update
```

### Full Guide

Read more in the guide [how to install](Docs/how-to-install.md) it.\
If you look for the legacy `Rugby 1.x`, visit [this page](https://github.com/swiftyfinch/Rugby/tree/1.23.0#how-to-install-).

## How to use 🏈

<details><summary>Preconditions</summary>
<p>

1. If you use Objective-C in your project, be sure that you import modules correctly.\
   Use `@import Something` instead of `#import "Something.h"`.\
   Because Rugby will include built frameworks in your project;
2. Before using Rugby you should be sure that your project source code is finalized.\
   🔸 For example: if you use `SwiftGen`, run it before calling Rugby.\
   Otherwise, your source code will be modified during building with Rugby. Then the hashes of binaries will not be suited.\
   If you encounter a problem, try to use [`rugby build pre`](Docs/commands-help/build/pre.md) to prebuild your project and finalize source code;
3. Be sure that all your pods (including development) are ready to build standalone.\
   Otherwise, you can get a state when one of them can't be reused correctly without the source of its dependencies.\
   As a temporary workaround, you can exclude some pods like `rugby -e BadPod`.\
   🔸 For example: if some of your pods use incorrect headers.

<hr>
</p>
</details>

Then run this command in your project directory after each `pod install`.\
It will build all targets by default:
```sh
> rugby
```

Deintegrate it with the [rollback](Docs/commands-help/rollback.md) command:
```sh
> rugby rollback
```

Also, you can write a custom [plan](Docs/commands-help/plan.md) (sequence of commands).\
Use 🏈 [RugbyPlanner](https://github.com/swiftyfinch/RugbyPlanner) for visualizing changes in your project without applying them.\
For advanced usage, please read the documentation below.

## 📚 Documentation

📦 [How to Install](Docs/how-to-install.md)\
📖 [Commands Help](Docs/commands-help/README.md)\
🚏 [Migration Guide](Docs/migration-guide.md)\
🐳 [Remote Cache](Docs/remote-cache.md)

<br>

## 🤝 Contribution

Feel free [to open a pull request](https://github.com/swiftyfinch/rugby/contribute) or [a discussion](https://github.com/swiftyfinch/Rugby/discussions).

| Known Issues 🐞 |
| :--- |
| [#394](https://github.com/swiftyfinch/Rugby/discussions/394) Unable to run tests via Xcode (via `make test` they run perfectly) |

## 📮 Support

If you want to support this project, you can do some of these:\
`1)` <ins><b>Press</b></ins> ⭐️. It's a nice mark which means that Rugby is useful;\
`2)` <ins><b>Share</b></ins> the project 🌍 somewhere with somebody;\
`3)` <ins><b>Leave feedback</b></ins> in the discussions 💬 section.

Let's Roll-oll 🏈
<br>

<img title="Views since 30.11.2023 + 6k after migration" src="https://komarev.com/ghpvc/?username=swiftyfinch-rugby&label=Views&format=true&base=6000">
