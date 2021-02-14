# Rugby 🏈
![](https://img.shields.io/badge/version-0.0.3-008800.svg?style=flat)
![](https://img.shields.io/badge/Xcode_CLI-12+-blue.svg?style=flat)

<img src="https://github.com/swiftyfinch/Rugby/blob/main/Preview.jpg" width="400"/>

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
$ brew install swiftyfinch/Rugby/rugby
```

### Usage

```
$ pod install
$ rugby
```

### Demo

<img src="https://github.com/swiftyfinch/Rugby/blob/main/Demo.gif" width="320"/>

### `Maybe Roadmap`

`-` Build for device\
`-` Speed up build with additional arguments\
`-` New commands: Reduce & Focus

### `Author`

Vyacheslav Khorkov\
Twitter: [@SwiftyFinch](https://twitter.com/swiftyfinch)\
Blog: [swiftyfinch.github.io](https://swiftyfinch.github.io/en)\
Feel free to contact me for any questions.