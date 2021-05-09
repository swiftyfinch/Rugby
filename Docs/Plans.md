
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

---

### 🗺 Generate example

Generate example at `.rugby/plans.yml`:\
`$ rugby example`

```yml
# The first plan in the file always run by default
- usual:
  # 🐚 Optionally you can generate project if you use Xcodegen or something like that
  - command: shell
    run: xcodegen

  # 🐚 Also, you can install pods before each rugby call right here
  - command: shell
    run: bundle exec pod install # Or you can use any shell command

  # 🏈 The first Rugby command without arguments like: $ rugby cache
  - command: cache
    # Optional parameters with default values:
    skipParents: false
    arch: null # By default x86_64 if sdk == sim
    sdk: sim
    keepSources: false
    exclude: []
    hideMetrics: false
    ignoreCache: false
    verbose: false

  # 🗑 The second command: $ rugby drop "Test"
  - command: drop
    targets:
      - Test
    exclude: # Optional
      - Pods-TestProject # It's just for example
    # Optional parameters with default values:
    invert: false
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


# Also, you can use another custom plan: $ rugby --plan unit
- unit:
  - command: cache
    exclude: [Alamofire]
  - command: drop
    targets: [Test]
    exclude: [MyFeatureTests]
```

---

### 📍 Select plan

Run the plan with name `usual`:\
`$ rugby` or\
`$ rugby plans` or\
`$ rugby plans --plan usual`

<img src="https://github.com/swiftyfinch/Rugby/blob/main/Imgs/Plans.png" width="360"/>