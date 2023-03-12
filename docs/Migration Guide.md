[< README](../README.md)

# 🚏 Migration Guide

#### 🚩 First steps

If you use the previous Rugby version I recommend you to follow this steps:

1. Remove `.rugby/backup` folder from each project. The structure in this folder has been\
   changed and can lead to some issues while calling `rugby rollback` command;
3. Optionally, you can remove all content from `.rugby` folder except for `.rugby/build`\
   and `.rugby/plans.yml`;
5. Rewrite content of your `plans.yml` files according the new documentation.

<br>

#### 🚚 Plans → Shortcuts

The default command `plans` was replaced by a new default command `shortcuts`. This command\
contains combinations of different commands. Now there are two subcommands: `umbrella` and `cache`.

The first one is similar to the `plans` command from Rugby `1.x`. It runs a new command `plan`\
if there is a `plans.yml` file or runs cache command if there isn’t such file. Every time when you\
call Rugby without any arguments, options or flags, this command will be called as a default one:

```sh
rugby

# It's the same as:
rugby shortcuts umbrella
```

The second command is `cache` and you can read more about it here 🧩 [Cache = build + use](#cache--build--use).\
You can call it like so:

```sh
rugby cache

# Or
rugby shortcuts cache
```

Documentation: 📍 [Shortcuts](Documentation/Shortcuts.md)

<br>

#### ♻️ Plans → Plan

The `plans` command was renamed to the `plan` command. Also, now you can call a plan with\
a name as an argument (not an option):

```sh
# Calls plan with name "pods"
rugby plan pods
```

The subcommands `example` and `list` haven’t been remade yet.

Documentation: ✈️ [Plan](Documentation/Plan.md) 

<br>

#### ♻️ File `plans.yml`

First of all, use an array as root structure instead of a dictionary.

```yaml
# Rugby 1.x
- usual:
  - command: cache

# Rugby 2.x
usual:
- command: cache
```

Use the `argument` key if a command has an argument. For example, the new `plan` command has\
the `name` argument.

```yaml
# Rugby 1.x
- tests:
  - command: plans
    name: base

# Rugby 2.x
tests:
- command: plan
  argument: base
```

That is because now this command will be called as a usual terminal command `plan base`\
without additional conversion.

Use all options and flags as they are, but without `-` and `--` prefixes.

```yaml
# Rugby 1.x
- usual:
  - command: cache
    sdk: [sim]
    ignoreChecksums: false
    exclude: PodName

# Rugby 2.x
usual:
- command: cache
  sdk: sim
  ignore-cache: false
  except: PodName
```

This command will be converted to `rugby cache --sdk sim --except PodName`.

Documentation: ✈️ [Plan](Documentation/Plan.md) 

<br>

#### 🧩 Cache = build + use

In the new Rugby you can build your Pods project without the step of integrating binaries\
into the project. It allows to build many times with different configurations and in the end\
use them all at once. For example:

```sh
rugby build --arch arm64 --sdk sim
rugby build --arch arm64 --sdk ios
rugby use
```

If it’s not necessary for you, use the `cache` command which is combination of `build` and `use`.\
For example:

```sh
rugby build && rugby use

# Or just
rugby cache
```

Some options and flags haven’t been remade yet.

Documentation:\
🏈 [Cache](Documentation/Shortcuts/Cache.md)\
🏗️ [Build](Documentation/Build.md)\
🎯 [Use](Documentation/Use.md)

<br>

#### ♻️ Drop → Delete

You can’t find the `drop` command in the new Rugby version. Use the `delete` command instead.\
This name is more clear and it does the same work.

Documentation: 🗑️ [Delete](Documentation/Delete.md) 

<br>

#### ♻️ Focus → `delete --safe`

The `focus` command was also removed.\
Now you can use `delete --safe --except PodA` in the similar manner.

Documentation: 🗑️ [Delete](Documentation/Delete.md) 

<br>

#### ♻️ Clean → Clear

The `clean` command was renamed and now you can decide which part of cache folders you want to delete.

Documentation: 🧼 [Clear](Documentation/Clear.md) 

<br>

#### ⛔️ ~~Log~~ & ~~Doctor~~

I haven’t remade these commands yet. I’m going to think about them during the public beta period.
