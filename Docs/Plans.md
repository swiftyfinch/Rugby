
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
`$ rugby plans example`

```yml
# The first plan in file always run by default.
- usual:
  # The first command without arguments like: rugby cache
  - command: cache
    # Optional parameters:
    skipParents: true
    #arch: null
    #sdk: sim
    #keepSources: false
    #exclude: []
    #hideMetrics: false
    #ignoreCache: false
    #verbose: false
  # The second command: rugby drop "Test"
  - command: drop
    targets:
      - Test
    # Optional parameters:
    #targets: []
    #invert: false
    #project: "Pods/Pods.xcodeproj"
    #testFlight: false
    #keepSources: false
    #exclude: []
    #hideMetrics: false
    #verbose: false
  # And so on: rugby drop -i "TestProject" -p TestProject/TestProject.xcodeproj
  - command: drop
    targets:
      - TestProject$
    invert: true
    project: TestProject/TestProject.xcodeproj

# Also, you can use custom plan: rugby --plan unit
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