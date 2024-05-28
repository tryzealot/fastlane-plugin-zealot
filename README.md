# fastlane-plugin-zealot

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-zealot)
[![English document](https://img.shields.io/badge/Document-English-blue.svg)](https://zealot.ews.im/docs/developer-guide/fastlane)


上传移动应用（iPhone、Android）到 [Zealot](https://github.com/tryzealot/zealot) 自建 App 分发系统。

fastlane-plugin-zealot provides upload app, debug_file and version check actions to [Zealot](https://github.com/tryzealot/zealot).

## 快速上手 Quick Start

这是一个 [_fastlane_](https://github.com/fastlane/fastlane) 插件。如果要使用 `fastlane-plugin-zealot` 可通过下面方法添加到 fastlane 体系中：

```bash
$ fastlane add_plugin zealot
```

## 功能列表

插件包含多个 actions 提供大家使用：

### zealot

上传 iOS (app/ipa)、Android (apk/abb) App 至 Zealot 系统，插件会通过参数和 CI 系统自动获取很多辅助信息。包括但不仅限于：

- 使用 gym 或 gradle 打包生成的 app 文件路径
- 解析应用获取的应用名称、打包类型
- Git 提交日志
- Git 分支名
- Git 最后一次提交的 Commit Hash
- CI 系统的名称
- CI 系统本次构建的 URL

#### 参数和返回值

```
+-----------------+-----------------------------------+------------------------+----------+
|                                     zealot Options                                      |
+-----------------+-----------------------------------+------------------------+----------+
| Key             | Description                       | Env Var                | Default  |
+-----------------+-----------------------------------+------------------------+----------+
| endpoint        | The endpoint of zealot            | ZEALOT_ENDPOINT        |          |
| token           | The token of user                 | ZEALOT_TOKEN           |          |
| channel_key     | The key of app's channel          | ZEALOT_CHANNEL_KEY     |          |
| file            | The path of app file. Optional    | ZEALOT_FILE            |          |
|                 | if you use the `gym`, `ipa`,      |                        |          |
|                 | `xcodebuild` or `gradle` action.  |                        |          |
| name            | The name of app to display on     | ZEALOT_NAME            |          |
|                 | zealot                            |                        |          |
| changelog       | The changelog of app              | ZEALOT_CHANGELOG       |          |
| slug            | The slug of app                   | ZEALOT_SLUG            |          |
| release_type    | The release type of app           | ZEALOT_RELEASE_TYPE    |          |
| branch          | The name of git branch            | ZEALOT_BRANCH          |          |
| git_commit      | The hash of git commit            | ZEALOT_GIT_COMMIT      |          |
| custom_fields   | The key-value hash of custom      | ZEALOT_CUSTOM_FIELDS   |          |
|                 | fields                            |                        |          |
| password        | The password of app to download   | ZEALOT_PASSWORD        |          |
| source          | The name of upload source         | ZEALOT_SOURCE          | fastlane |
| ci_url          | The name of upload source         | ZEALOT_CI_CURL         |          |
| timeout         | Request timeout in seconds        | ZEALOT_TIMEOUT         |          |
| hide_user_token | replase user token to *** to      | ZEALOT_HIDE_USER_TOKEN | true     |
|                 | keep secret                       |                        |          |
| verify_ssl      | Should verify SSL of zealot       | ZEALOT_VERIFY_SSL      | true     |
|                 | service                           |                        |          |
| fail_on_error   | Should an error uploading app     | ZEALOT_FAIL_ON_ERROR   | false    |
|                 | cause a failure                   |                        |          |
+-----------------+-----------------------------------+------------------------+----------+
* = default value is dependent on the user's system

+-----------------------+---------------------------------------------+
|                       zealot Output Variables                       |
+-----------------------+---------------------------------------------+
| Key                   | Description                                 |
+-----------------------+---------------------------------------------+
| ZEALOT_APP_ID         | The id of app                               |
| ZEALOT_RELEASE_ID     | The id of app's release                     |
| ZEALOT_RELEASE_URL    | The release URL of the newly uploaded build |
| ZEALOT_INSTALL_URL    | The install URL of the newly uploaded build |
| ZEALOT_QRCODE_URL     | The QRCode URL of the newly uploaded build  |
| ZEAALOT_ERROR_MESSAGE | The error message during upload process     |
+-----------------------+---------------------------------------------+
```

#### 样例

```ruby
# 自动根据上面结果来获取信息上传
lane :automatic_upload do
  # iOS
  gym

  # Android
  gradle

  # 根据 CI 系统自动获取提交日志
  ci_changelog

  zealot(
    endpoint: 'http://localhost:3000',
    token: '...',
    channel_key: '...'
  )

  # 或者通过环境变量配置参数
  ENV['ZEALOT_ENDPOINT'] = 'http://localhost:3000'
  ENV['ZEALOT_TOKEN'] = '...'
  ENV['ZEALOT_CHANNEL_KEY'] = '...'

  # 这里就无需再配置参数
  zealot
end

# 上传指定文件
lane :upload_file do
  zealot(
    endpoint: 'http://localhost:3000',
    token: '...',
    channel_key: '...',
    file: '.ipa_or_apk',
    custom_fields: {
      api_env: '测试环境'
    }
  )
end
```

### zealot_debug_file

上传 iOS 的 dSYM 或 Android 的 Proguard 调试文件到 Zealot

#### 参数和返回值

```
+--------------------+-----------------------------------+---------------------------+---------+
|                                  zealot_debug_file Options                                   |
+--------------------+-----------------------------------+---------------------------+---------+
| Key                | Description                       | Env Var                   | Default |
+--------------------+-----------------------------------+---------------------------+---------+
| endpoint           | The endpoint of zealot            | ZEALOT_ENDPOINT           |         |
| token              | The token of user                 | ZEALOT_TOKEN              |         |
| channel_key        | Any channel key of app            | ZEALOT_CHANNEL_KEY        |         |
| zip_file           | Using given the path of zip file  | DF_DSYM_ZIP_FILE          |         |
|                    | to direct upload                  |                           |         |
| platform           | The name of platfrom, avaiable    | ZEALOT_PLATFORM           |         |
|                    | value are                         |                           |         |
|                    | ios,mac,macos,osx,android         |                           |         |
| path               | The path of debug file            | ZEALOT_PATH               |         |
|                    | (iOS/macOS is archive path for    |                           |         |
|                    | Xcode, Android is path for app    |                           |         |
|                    | project)                          |                           |         |
| xcode_scheme       | The scheme name of app            | ZEALOT_XCODE_SCHEME       |         |
| android_build_type | The build type of app             | ZEALOT_ANDROID_BUILD_TYPE | release |
| android_flavor     | The product flavor of app         | ZEALOT_ANDROID_FLAVOR     |         |
| extra_files        | A set file names                  | ZEALOT_EXTRA_FILES        | []      |
| output_path        | The output path of compressed     | DF_DSYM_OUTPUT_PATH       | .       |
|                    | dSYM file                         |                           |         |
| release_version    | The release version of app        | ZEALOT_RELEASE_VERSION    |         |
|                    | (Android needs)                   |                           |         |
| build_version      | The build version of app          | ZEALOT_BUILD_VERSION      |         |
|                    | (Android needs)                   |                           |         |
| overwrite          | Overwrite output compressed file  | DF_DSYM_OVERWRITE         | false   |
|                    | if it existed                     |                           |         |
| timeout            | Request timeout in seconds        | ZEALOT_TIMEOUT            |         |
| verify_ssl         | Should verify SSL of zealot       | ZEALOT_VERIFY_SSL         | true    |
|                    | service                           |                           |         |
| fail_on_error      | Should an error uploading app     | ZEALOT_FAIL_ON_ERROR      | false   |
|                    | cause a failure? (true/false)     |                           |         |
+--------------------+-----------------------------------+---------------------------+---------+
* = default value is dependent on the user's system

+-----------------------+-----------------------------------------+
|               zealot_debug_file Output Variables                |
+-----------------------+-----------------------------------------+
| Key                   | Description                             |
+-----------------------+-----------------------------------------+
| ZEAALOT_ERROR_MESSAGE | The error message during upload process |
+-----------------------+-----------------------------------------+
```

#### 样例

```ruby
# 自动根据上面结果来获取信息上传
lane :automatic_upload do
  # iOS
  gym

  # Android
  gradle

  # 根据 CI 系统自动获取提交日志
  ci_changelog

  ENV['ZEALOT_ENDPOINT'] = 'http://localhost:3000'
  ENV['ZEALOT_TOKEN'] = '...'
  ENV['ZEALOT_CHANNEL_KEY'] = '...'

  # 自动上传 App 和调试文件
  zealot
  zealot_debug_file
end
```

### zealot_sync_device

同步指定 Apple 开发者账号的设备列表信息到 Zealot，主要是为了让使用者更清晰看到每个设备 udid 记录的名称，提供两种授权方式：

- [Apple API Key 授权](https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key-json-file) **强烈推荐**
- 密码授权

#### 参数和返回值

```
+---------------+-----------------------------------------------------------------------------+------------------------+---------+
|                                                  zealot_sync_devices Options                                                   |
+---------------+-----------------------------------------------------------------------------+------------------------+---------+
| Key           | Description                                                                 | Env Var(s)             | Default |
+---------------+-----------------------------------------------------------------------------+------------------------+---------+
| endpoint      | The endpoint of zealot                                                      | ZEALOT_ENDPOINT        |         |
| token         | The token of user                                                           | ZEALOT_TOKEN           |         |
| username      | The apple id (username) of Apple Developer Portal                           | ZEALOT_USERNAME        | *       |
| api_key_path  | Path to your App Store Connect API Key JSON file                            | ZEALOT_API_PATH        |         |
|               | (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key  |                        |         |
|               | -json-file)                                                                 |                        |         |
| api_key       | Your App Store Connect API Key information                                  | ZEALOT_API_KEY         | *       |
|               | (https://docs.fastlane.tools/app-store-connect-api/#using-fastlane-api-key  |                        |         |
|               | -hash-option)                                                               |                        |         |
| team_id       | The ID of your Developer Portal team if you're in multiple teams            | ZEALOT_APPLE_TEAM_ID   | *       |
| team_name     | The name of your Developer Portal team if you're in multiple teams          | ZEALOT_APPLE_TEAM_NAME | *       |
| platform      | The platform to use (optional)                                              | ZEALOT_APPLE_PLATFORM  | ios     |
| verify_ssl    | Should verify SSL of zealot service                                         | ZEALOT_VERIFY_SSL      | true    |
| timeout       | Request timeout in seconds                                                  | ZEALOT_TIMEOUT         |         |
| fail_on_error | Should an error http request cause a failure? (true/false)                  | ZEALOT_FAIL_ON_ERROR   | false   |
+---------------+-----------------------------------------------------------------------------+------------------------+---------+
```

#### 样例

```ruby
lane :sync do
  # 使用 Apple API Key 方式授权，无需密码和二次验证
  zealot_sync_devices(
    endpoint: "...",
    token: "...",
    api_key_path: "/path/to/your/api_key_json_file",
    team_id: "..."
  )

  # 使用传统的密码授权
  zealot_sync_devices(
    endpoint: "...",
    token: "...",
    username: "...",
    team_id: "..."
  )
end
```

### zealot_version_check

检查应用版本是否已经上传，避免重复打包、上传已经上传的应用，目前支持两种方式检查：

- bundle_id + git commit
- bundle_id+ release_version + build_version

参数和各平台实际值对应关系

参数 | iOS | Android
---|---|---
bundle_id | bundle_id | package_name
release_version | CFBundleShortVersionString | versionName
build_version | CFBundleVersion | versionCode

#### 参数和返回值

```
+-----------------+---------------------------------+------------------------+---------+
|                             zealot_version_check Options                             |
+-----------------+---------------------------------+------------------------+---------+
| Key             | Description                     | Env Var                | Default |
+-----------------+---------------------------------+------------------------+---------+
| endpoint        | The endpoint of zealot          | ZEALOT_ENDPOINT        |         |
| token           | The token of user               | ZEALOT_TOKEN           |         |
| channel_key     | The key of app's channel        | ZEALOT_CHANNEL_KEY     |         |
| bundle_id       | The bundle id(package name) of  | ZEALOT_BUNDLE_ID       |         |
|                 | app                             |                        |         |
| release_version | The release version of app      | ZEALOT_RELEASE_VERSION |         |
| build_version   | The build version of app        | ZEALOT_BUILD_VERSION   |         |
| git_commit      | The latest git commit of app    | ZEALOT_GIT_COMMIT      |         |
| verify_ssl      | Should verify SSL of zealot     | ZEALOT_VERIFY_SSL      | true    |
|                 | service                         |                        |         |
| hide_user_token | replase user token to *** to    | ZEALOT_HIDE_USER_TOKEN | true    |
|                 | keep secret                     |                        |         |
| fail_on_error   | Should an error http request    | ZEALOT_FAIL_ON_ERROR   | false   |
|                 | cause a failure? (true/false)   |                        |         |
+-----------------+---------------------------------+------------------------+---------+
* = default value is dependent on the user's system

+------------------------+---------------------------------------------+
|                zealot_version_check Output Variables                 |
+------------------------+---------------------------------------------+
| Key                    | Description                                 |
+------------------------+---------------------------------------------+
| ZEALOT_VERSION_EXISTED | The result of app verison existed (Boolean) |
| ZEAALOT_ERROR_MESSAGE  | The error message during upload process     |
+------------------------+---------------------------------------------+
Access the output values using `lane_context[SharedValues::VARIABLE_NAME]`

+-----------------------------------+
| zealot_version_check Return Value |
+-----------------------------------+
| Fastlane::Boolean                 |
```

## 更多例子

检查[范例 `Fastfile` 文件](fastlane/Fastfile) 来看看如何使用插件吧

## 问题和反馈

使用本插件过程中遇到的任何问题和反馈请提交问题。

## 疑惑解答

如果你对 fastlane 不了解建议现看看[本教程](https://icyleaf.com/tags/fastlane/)，再看看使用插件的[疑惑解答](https://docs.fastlane.tools/plugins/plugins-troubleshooting/)
