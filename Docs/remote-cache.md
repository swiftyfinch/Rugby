[< Documentation](README.md)

# 🐳 Remote Cache

#### Preconditions:

1. If you use Objective-C in your project, be sure that you import modules correctly.\
   Use `@import Something` instead of `#import "Something.h"`.\
   Because Rugby will include built frameworks in your project;
2. Before using Rugby you should be sure that your project source code is finalized.\
   🔸 For example: if you use `SwiftGen`, run it before calling Rugby.\
   Otherwise, your source code will be modified during building with Rugby. Then the hashes of binaries will not be suited.\
   If you encounter a problem, try to use [`rugby build pre`](commands-help/build/pre.md) to prebuild your project and finalize source code;
3. Be sure that all your pods (including development) are ready to build standalone.\
   Otherwise, you can get a state when one of them can't be reused correctly without the source of its dependencies.\
   As a temporary workaround, you can exclude some pods like `rugby -e BadPod`.\
   🔸 For example: if some of your pods use incorrect headers;
4. You need cloud object storage.\
   🔸 For example: I've tested only with AWS S3.

<br>

## 🐳 Upload Cache

After each [`rugby build`](commands-help/build.md) (or [`rugby cache`](commands-help/shortcuts/cache.md), which includes `build`) command, 🏈 Rugby creates a file with the changes.\
You can find it here: `~/.rugby/bin/+latest`.

This file contains the following:
```
/Users/swiftyfinch/.rugby/bin/Alamofire/Debug-iphonesimulator-x86_64/f38484e
/Users/swiftyfinch/.rugby/bin/AutoMate/Debug-iphonesimulator-x86_64/dfcf69f
/Users/swiftyfinch/.rugby/bin/KeyboardLayoutGuide/Debug-iphonesimulator-x86_64/f44e1b4
```

All you need to do is simply parse this file after each build and upload the binaries from these paths to your remote storage.

###### Example of parsing:
```ruby
#!/usr/bin/ruby

SHARED_PATH = File.expand_path('~/.rugby')
BIN_PATH = "#{SHARED_PATH}/bin"
LATEST_BINARIES_PATH = "#{BIN_PATH}/+latest"

# Getting last built binaries
return unless File.exist?(LATEST_BINARIES_PATH)
binaries = File.readlines(LATEST_BINARIES_PATH, chomp: true).each_with_object({}) do |path, hash|
  remote_path = path.delete_prefix("#{BIN_PATH}/")
  hash[remote_path] = path
end

# puts binaries
# {
#   "Alamofire/Debug-iphonesimulator-x86_64/f38484e"
#   =>
#   "/Users/swiftyfinch/.rugby/bin/Alamofire/Debug-iphonesimulator-x86_64/f38484e"
# }
```

###### Example of uploading to S3:
```ruby
require 'parallel'
require 'aws-sdk-s3'

# (!) Configure these S3 arguments:
S3_ENDPOINT = "https://s3-your-endpoint" #
S3_BUCKET = ""                           #
S3_ACCESS_KEY = ""                       #
S3_SECRET_KEY = ""                       #

Parallel.each(binaries, in_processes: 10) do |remote_path, path|
  # Zipping binaries
  binary_folder_path = File.dirname(path)
  binary_name = File.basename(path)
  `cd #{binary_folder_path} && zip -r #{binary_name}.zip #{binary_name}`
  # For example, it produces: ~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/2617d3e.zip

  # Uploading zip files to S3
  content = File.read("#{path}.zip")
  credentials = Aws::Credentials.new(S3_ACCESS_KEY, S3_SECRET_KEY)
  s3 = Aws::S3::Client.new({endpoint: S3_ENDPOINT, credentials: credentials})
  s3.put_object(bucket: S3_BUCKET, body: content, content_type: 'application/zip', key: remote_path)
  # For example, it uploads ~/.rugby/bin/Alamofire/Debug-iphonesimulator-arm64/2617d3e.zip
  # And then it will be available at S3_ENDPOINT/S3_BUCKET/Alamofire/Debug-iphonesimulator-arm64/2617d3e
end
```

<br>

## 🐳 Download Cache

If you can download binaries from your remote storage via HTTPS, you can use the [`rugby warmup`](commands-help/warmup.md) command.

```sh
> rugby warmup s3.eu-west-2.amazonaws.com
> rugby cache

# or in one line
> rugby cache --warmup s3.eu-west-2.amazonaws.com
```

If you need to provide a key to access your storage, please use the `headers` field:
```sh
> rugby cache --warmup s3.eu-west-2.amazonaws.com --headers "key: value"
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

You will receive the output in the following format:
```shell
- /Users/swiftyfinch/.rugby/bin/AutoMate/Debug-iphonesimulator-x86_64/dfcf69f
- /Users/swiftyfinch/.rugby/bin/Moya/Debug-iphonesimulator-x86_64/185feed
```

Then, you can download the binaries from your remote storage and place them in these paths before running any build commands.
