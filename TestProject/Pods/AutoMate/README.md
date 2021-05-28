<div align="center">
    <img src="assets/logo.png" alt="AutoMate, made by PGS Software" />
    <br />
    <img src="assets/made-with-love-by-PGS.png" />
    <p>
      <b>AutoMate</b> &bull;
      <a href="https://github.com/PGSSoft/AutoMate-AppBuddy">AppBuddy</a> &bull;
      <a href="https://github.com/PGSSoft/AutoMate-Templates">Templates</a> &bull;
      <a href="https://github.com/PGSSoft/AutoMate-ModelGenie">ModelGenie</a>
    </p>
</div>

# AutoMate

`AutoMate` is a Swift framework containing a set of helpful `XCTest` extensions for writing UI automation tests.
It provides strongly typed, extensible wrapper around launch arguments and environment variables, which can be used for language, locale and keyboard type configuration on the device.
With the [`AutoMate-AppBuddy`](https://github.com/PGSSoft/AutoMate-AppBuddy) it can also disable animations in the application and manage events, reminders and contacts.

[![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat)](https://swift.org)
[![Travis](https://img.shields.io/travis/PGSSoft/AutoMate.svg)](https://travis-ci.org/PGSSoft/AutoMate)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/AutoMate.svg)](https://cocoapods.org/pods/AutoMate)
[![Documentation](https://img.shields.io/badge/docs-100%25-D15B45.svg?style=flat)](https://pgssoft.github.io/AutoMate/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/cocoapods/p/AutoMate.svg)](https://cocoapods.org/pods/AutoMate)
[![License](https://img.shields.io/github/license/PGSSoft/AutoMate.svg)](https://github.com/PGSSoft/AutoMate/blob/master/LICENSE)

![AutoMate](assets/AutoMate.gif)

## Installation

There are three convinient ways to install AutoMate:

* using [CocoaPods](https://cocoapods.org) with Podfile:

	```ruby
	pod 'AutoMate'
	```

* using [Carthage](https://github.com/Carthage/Carthage) and add a line to `Cartfile.private`:
	
	```
	github "PGSSoft/AutoMate"
	```

	`Cartfile.private` should be used because AutoMate framework will be used by UI Tests target only not by the tested application.

* using Swift Package Manager, either via [Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) or in `Package.swift`: 
	
	```swift
	.package(url: "https://github.com/PGSSoft/AutoMate", from: "1.8.0"),
	```

## Usage

Full documentation is available at [https://pgssoft.github.io/AutoMate/](https://pgssoft.github.io/AutoMate/).

1. Create a new UI test case class.
2. Import `AutoMate` framework to UI tests files:

    ```swift
    import AutoMate
    ```

3. Use `TestLauncher` in the `setup()` method to configure application settings and launch the application:

    ```swift
    let app = XCUIApplication()
    TestLauncher(options: [
        SystemLanguages([.English, .German]),
        SystemLocale(language: .English, country: .Canada),
        SoftwareKeyboards([.EnglishCanada, .GermanGermany])
    ]).configure(app).launch()
    ```

4. Use AutoMate's extensions in your tests. For example:

    ```swift
    func testSomething() {
        let app = XCUIApplication()
        let button = app.button.element

        // helper for waiting until element is visible
        waitForVisibleElement(button, timeout: 20)
        button.tap()

        // isVisible - helper to check that element both exists and is hittable
        XCTAssertFalse(button.isVisible)
    }
    ```

## Features (or ToDo)

- [x] Set keyboards
- [x] Set locale
- [x] Set languages
- [x] Custom arguments
- [x] Custom keyboards, locales and languages
- [x] `XCTest` extensions
- [x] Added CoreData launch arguments
- [x] Disable UIView animations (with `AutoMate-AppBuddy`)
- [x] Strong-typed helpers: locators, page object templates (with `AutoMate-Templates`)
- [x] Base XCTestCase template (with `AutoMate-Templates`)
- [x] Most permissions alerts (like: `LocationWhenInUseAlert`, `CalendarAlert`, `PhotosAlert`) (with `AutoMate-ModelGenie`)
- [x] Managing events, reminders and contacts (with `AutoMate-AppBuddy`)
- [x] Companion library for the application (`AutoMate-AppBuddy`)
- [x] Improve launch options type safety
- [x] Smart coordinates
- [x] Check if application is running in UI test environment (with `AutoMate-AppBuddy`)
- [ ] Stubbing network requests
- [ ] Stubbing contacts, events and reminders
- [ ] Taking screenshots
- [ ] Clearing application data
- [ ] Stubbing notifications

## Example application

Repository contains example application under `AutoMateExample` directory.
Structure of the application is simple, but the project contains extensive suite of UI tests to showcase capabilities of the library.

## Development

Full documentation is available at [https://pgssoft.github.io/AutoMate/](https://pgssoft.github.io/AutoMate/).

If you want to provide your custom launch argument or launch environment you have to implement `LaunchOption` protocol or one of its extensions, such as `LaunchArgumentWithSingleValue`:

```swift
enum CustomParameter: String, LaunchArgumentWithSingleValue, LaunchArgumentValue {
    var key: String {
        return "AppParameter"
    }
    case value1
    case value2
}
```

Then, you can pass it to the `TestBuilder`:

```swift
let launcher = TestLauncher(options: [
    CustomParameter.value1
])
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/PGSSoft/AutoMate](https://github.com/PGSSoft/AutoMate).

## License

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About
The project maintained by software development agency [PGS Software](https://www.pgs-soft.com).
See our other [open-source projects](https://github.com/PGSSoft) or [contact us](https://www.pgs-soft.com/contact-us) to develop your product.

## Follow us

[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/PGSSoft/AutoMate)  
[![Twitter Follow](https://img.shields.io/twitter/follow/pgssoftware.svg?style=social&label=Follow)](https://twitter.com/pgssoftware)
