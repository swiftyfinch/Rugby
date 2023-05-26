<p align="center">
  <img src="https://user-images.githubusercontent.com/64660122/230763146-d467dafb-252c-46ce-93d6-f2309e5aabc8.gif" width=600>
</p>

<p align="center">
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?label=Platform&url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dplatforms" /></a>
  <a href="https://swiftpackageindex.com/swiftyfinch/Rugby"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswiftyfinch%2FRugby%2Fbadge%3Ftype%3Dswift-versions" /></a>
  <br>
  <img src="https://img.shields.io/badge/Press_★_to_pay_respects-fff?logo=github&logoColor=black" />
  <a href="https://twitter.com/swiftyfinch"><img src="https://img.shields.io/badge/SwiftyFinch-blue?logo=twitter&logoColor=white" /></a>
</p>

# Motivation

Why do we need some optimizations while working on huge projects with [CocoaPods](https://github.com/CocoaPods/CocoaPods)?\
`-` Slow and unnecessary indexing of pods targets, which implementation we rarely try to edit;\
`-` Redundant rebuild time, probably as a result of problems, related to CocoaPods or Xcode build system;\
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
✈️ Can run [a sequence of commands from a YAML file](docs/commands-help/plan.md);\
🕹️ Single command usage;\
🐳 Ready for [remote cache](docs/remote-cache.md);\
🧣 Cozy log output;\
🚀 Swiftish and uses native Xcode build system.

Ruby alternatives: [PodBuilder](https://github.com/Subito-it/PodBuilder) | [CocoaPods Binary Cache](https://github.com/grab/cocoapods-binary-cache) | [CocoaPods Binary](https://github.com/leavez/cocoapods-binary)

<br>

# How to install 📦

This version of Rugby hasn't opened source yet. I'm going to open it this summer.\
There are still [a lot of preparation steps](README.md#-roadmap) to do.

But you can download a binary, read the guide 🦮 [how to install](docs/how-to-install.md) it.\
If you look for the legacy `Rugby 1.x`, which source is opened, visit [this page](https://github.com/swiftyfinch/Rugby/tree/1.23.0#how-to-install-).

## How to use 🏈

<details><summary>Preconditions</summary>
<p>

1. Before using Rugby you should be sure that your project source code is finalized.\
   🔸 For example: if you use `SwiftGen`, run it before calling Rugby.\
   Otherwise, your source code will be modified during building with Rugby. Then the hashes of binaries will not be suited;
2. Be sure that all your pods (including development) are ready to build standalone.\
   Otherwise, you can get a state when one of them can't be reused correctly without the source of its dependencies.\
   As a temporary workaround, you can exclude some pods like `rugby -e BadPod`.\
   🔸 For example: if some of your pods use incorrect headers.

<hr>
</p>
</details>

Then run this command in your project directory after each `pod install`. It will build all targets by default:
```sh
> rugby
```

Deintegrate it with the [rollback](docs/commands-help/rollback.md) command:
```sh
> rugby rollback
```

Also, you can write a custom [plan](docs/commands-help/plan.md) (sequence of commands).\
Use 🏈 [RugbyPlanner](https://github.com/swiftyfinch/RugbyPlanner) application for visualizing changes in your project without applying them.\
For advanced usage, please read the documentation below.

## 📚 Documentation

📦 [How to Install](docs/how-to-install.md)\
📖 [Commands Help](docs/commands-help/README.md)\
🚏 [Migration Guide](docs/migration-guide.md)\
🐳 [Remote Cache](docs/remote-cache.md)

<br>

# 🎯 Roadmap

- [ ] Refactoring
- [ ] Tests
- [ ] GitHub Actions
- [ ] Open Source

## 🤝 Contribution

Feel free to open a pull request / an issue or a discussion.

## 📮 Support

If you want to support this project, you can do some of these:\
`1)` <ins><b>Press</b></ins> ⭐️. It's a nice mark which means that Rugby is useful;\
`2)` <ins><b>Share</b></ins> the project 🌍 somewhere with somebody;\
`3)` <ins><b>Leave feedback</b></ins> in the discussions 💬 section.

Let's Roll-oll 🏈
