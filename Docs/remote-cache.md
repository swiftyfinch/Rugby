[< Documentation](README.md)

# 🐳 Remote Cache

#### Preconditions:

1. If you use Objective-C in your project, be sure that you import modules correctly.\
   Use `@import Something` instead of `#import "Something.h"`.\
   Because Rugby will include built frameworks in your project;
2. Before using Rugby you should be sure that your project source code is finalized.\
   🔸 For example: if you use `SwiftGen`, run it before calling Rugby.\
   Otherwise, your source code will be modified during building with Rugby. Then the hashes of binaries will not be suited;
3. Be sure that all your pods (including development) are ready to build standalone.\
   Otherwise, you can get a state when one of them can't be reused correctly without the source of its dependencies.\
   As a temporary workaround, you can exclude some pods like `rugby -e BadPod`.\
   🔸 For example: if some of your pods use incorrect headers;
4. You need cloud object storage.\
   🔸 For example: I've tested only with AWS S3.

<br>

## 🐳 Upload Cache

After each [`rugby build`](commands-help/build.md) (or [`rugby cache`](commands-help/shortcuts/cache.md), which includes `build`) command, 🏈 Rugby creates the file with changes.\
You can find it here: `~/.rugby/bin/+latest`.

This file contains something like:
```
/Users/swiftyfinch/.rugby/bin/Alamofire/Debug-iphonesimulator-x86_64/f38484e
/Users/swiftyfinch/.rugby/bin/AutoMate/Debug-iphonesimulator-x86_64/dfcf69f
/Users/swiftyfinch/.rugby/bin/KeyboardLayoutGuide/Debug-iphonesimulator-x86_64/f44e1b4
```

All you need is just to parse this file after each building and upload binaries from these paths to your remote storage.

<br>

## 🐳 Download Cache

If you can download binaries from your remote storage via HTTPS, you can use the [`rugby warmup`](commands-help/warmup.md) command.

```shell
rugby warmup s3.eu-west-2.amazonaws.com
rugby cache

# or in one line
rugby cache --warmup s3.eu-west-2.amazonaws.com
```

Also, you can write a more flexible plan:

```yml
default:
# Download cache for x86_64
- command: warmup
  warmup: s3.eu-west-2.amazonaws.com
  arch: x86_64
# Build the remaining part of the project for x86_64
- command: build
  arch: x86_64

# Download cache for arm64
- command: warmup
  warmup: s3.eu-west-2.amazonaws.com
  arch: arm64
# Build the remaining part of the project for arm64
- command: build
  arch: arm64

# Use binaries
- command: use
```

<br>

### Custom way

If you have a more complex workflow with your remote storage, you can use the command [`rugby warmup --analyse`](commands-help/warmup.md).\
The command with this flag analyses local binaries and then you can grep it like so:
```shell
rugby warmup --analyse --quiet --output raw | grep "^-\s"
```

You will get output in such way:
```shell
- /Users/swiftyfinch/.rugby/bin/AutoMate/Debug-iphonesimulator-x86_64/dfcf69f
- /Users/swiftyfinch/.rugby/bin/Moya/Debug-iphonesimulator-x86_64/185feed
```

Then you can download these binaries from your remote storage and put them to these paths before calling any build command.
