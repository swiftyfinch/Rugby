<h3 align="center">
  Rugby 🏈<br>
  <sup>(<ins>like Ruby but with g</ins>)</sup>
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

`Rugby` is CLI tool that was developed to solve the above problems:\
`+` Cache all remote pods dependencies and remove their targets from the Pods project;\
`+` Rebuild only changed remote pods;\
`+` Remove unnecessary sources from a project and reduce project size;\
`+` Drop any unneeded targets with sources and resources by RegEx.

### ✈️ Quick start with [`Homebrew`](https://brew.sh)

```bash
# First install
$ brew tap swiftyfinch/Rugby https://github.com/swiftyfinch/Rugby.git
$ brew install rugby

# Or get new version
$ brew upgrade rugby
```

### `How to use`

```bash
# For basic usage just run one command in your project directory
$ rugby
```

| Command | Description |
| :----- | :------ |
🏈 [`Cache`](Docs/Cache.md) | Convert remote pods to prebuilt dependencies.
🏈 [`Drop`](Docs/Drop.md) | Remove any targets by RegEx.

### `Maybe Roadmap`

- [x] Output metrics
- [ ] Rugby plans
- [ ] New command
- [ ] Open source

### `Author`

Vyacheslav Khorkov\
Twitter: [@SwiftyFinch](https://twitter.com/swiftyfinch)\
Blog: [swiftyfinch.github.io](https://swiftyfinch.github.io/en)\
Feel free to contact me for any questions.