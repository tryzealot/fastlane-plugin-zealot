# Zealot plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-zealot)

上传移动应用（iPhone、Android）到 [Zealot](https://github.com/getzealot/zealot) 自建 App 分发系统。

> Zealot 是一个开源、可自建服务的移动应用上传没有如此简单、解放开发打包的烦恼，轻松放权给测试、产品、运营等使用 App 的人员，深度与 Jenkins 和 Gitlab 集成。

## 快速上手

这是一个 [_fastlane_](https://github.com/fastlane/fastlane) 插件。如果要使用 `fastlane-plugin-zealot` 可通过下面方法添加到 fastlane 体系中：

```bash
$ fastlane add_plugin zealot
```

## 参数说明

```
+-----------------+-------------------------------------------------+------------------------+----------+
|                                            zealot Options                                             |
+-----------------+-------------------------------------------------+------------------------+----------+
| Key             | Description                                     | Env Var                | Default  |
+-----------------+-------------------------------------------------+------------------------+----------+
| endpoint        | The endpoint of zealot                          | ZEALOT_ENDPOINT        |          |
| token           | The token of user                               | ZEALOT_TOKEN           |          |
| channel_key     | The key of app's channel                        | ZEALOT_CHANNEL_KEY     |          |
| file            | The path of app file. Optional if you use the   | ZEALOT_FILE            |          |
|                 | `gym`, `ipa`, `xcodebuild` or `gradle` action.  |                        |          |
| name            | The name of app to display on zealot            | ZEALOT_NAME            |          |
| changelog       | The changelog of app                            | ZEALOT_CHANGELOG       |          |
| slug            | The slug of app                                 | ZEALOT_SLUG            |          |
| release_type    | The release type of app                         | ZEALOT_RELEASE_TYPE    |          |
| branch          | The name of git branch                          | ZEALOT_BRANCH          |          |
| git_commit      | The hash of git commit                          | ZEALOT_GIT_COMMIT      |          |
| password        | The password of app to download                 | ZEALOT_PASSWORD        |          |
| source          | The name of upload source                       | ZEALOT_SOURCE          | fastlane |
| timeout         | Request timeout in seconds                      | ZEALOT_TIMEOUT         |          |
| hide_user_token | replase user token to *** to keep secret        | ZEALOT_HIDE_USER_TOKEN | true     |
| fail_on_error   | Should an error uploading app cause a failure?  | ZEALOT_FAIL_ON_ERROR   | false    |
|                 | (true/false)                                    |                        |          |
+-----------------+-------------------------------------------------+------------------------+----------+
```

## 举个例子

检查[范例 `Fastfile` 文件](fastlane/Fastfile) 来看看如何使用插件吧（其实啥都没有写）

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
