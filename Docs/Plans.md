
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

<img src="https://github.com/swiftyfinch/Rugby/blob/main/Assets/Plans-list.png" width="800"/>

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
    arch: null # By default x86_64 if sdk == sim
    config: null # By default Debug
    sdk: sim
    keepSources: false
    exclude: []
    include: []
    focus: []
    hideMetrics: false
    ignoreChecksums: false
    verbose: false

  # 🔍 The second command: $ rugby focus "Pods-Main"
  - command: focus
    targets:
      - Pods-Main
    project: "Pods/Pods.xcodeproj"
    testFlight: false
    keepSources: false
    hideMetrics: false
    verbose: false

  # 🗑 And so on: $ rugby drop -i "TestProject" -p TestProject/TestProject.xcodeproj
  - command: drop
    targets: [^TestProject$] # Alternative array syntax
    invert: true
    project: TestProject/TestProject.xcodeproj


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

<img src="https://github.com/swiftyfinch/Rugby/blob/main/Assets/Plans.png" width="360"/>
