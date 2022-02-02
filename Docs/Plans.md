
### ✈️ `Plans`

```
OVERVIEW: Run selected plan from .rugby/plans.yml or use cache command if file not found.

OPTIONS:
  --plan <plan>     Plan name. (default: the first plan)

  --version         Show the version.
  -h, --help        Show help information.

SUBCOMMANDS:
  example           Generate example .rugby/plans.yml
```

<br>

## 🗒 Print all plans and select one if needed

```bash
rugby list
```

<img src="https://user-images.githubusercontent.com/64660122/141672938-9332dc97-21a1-4242-9124-c3706cbe696d.png" width="800"/>

<br>

## 🗺 Generate example

Generate example at `.rugby/plans.yml`:

```bash
rugby example
```

```yml
# The first plan in the file always run by default
- usual:
  # Reuse another plan from this file
  - command: plans
    name: base

  # 🏈 The first Rugby command without arguments like: $ rugby cache
  - command: cache
    # Optional parameters with default values:
    graph: true
    arch: [] # By default: sim x86_64, ios arm64
    config: null # By default Debug
    sdk: [sim]
    bitcode: false
    keepSources: false
    exclude: []
    include: []
    focus: []
    hideMetrics: false
    ignoreChecksums: false
    verbose: false
    quiet: false

  # 🔍 The second command: $ rugby focus "Pods-Main"
  - command: focus
    targets:
      - Pods-Main
    project: "Pods/Pods.xcodeproj"
    testFlight: false
    keepSources: false
    hideMetrics: false
    verbose: false
    quiet: false

  # 🗑 And so on: $ rugby drop -i "TestProject" -p TestProject/TestProject.xcodeproj
  - command: drop
    targets: [^TestProject$] # Alternative array syntax
    invert: true
    project: TestProject/TestProject.xcodeproj
    quiet: false


# Base plan which you can use in other plans
- base:
  # 🐚 Optionally you can generate project if you use Xcodegen or something like that
  #- command: shell
  #  run: xcodegen
  #  verbose: false

  # 🐚 Also, you can install pods before each rugby call right here
  - command: shell
    run: pods -q # github.com/swiftyfinch/Pods or you can use any shell command
    verbose: true


# Also, you can use another custom plan: $ rugby --plan unit
- unit:
  - command: plans
    name: base
  - command: cache
    exclude: [Alamofire]
  - command: drop
    targets: [Test]
    exclude: [MyFeatureTests]
```

<br>

## 📍 Select plan

Run the plan with name `usual` (It's all the same):

```bash
rugby
```

```bash
rugby plans
```

```bash
rugby plans --plan usual
```

<img src="https://user-images.githubusercontent.com/64660122/141672640-211a505d-3505-49be-87b0-bf90098128a0.png" width="360"/>
