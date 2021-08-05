智汀云家庭
============
![Language](https://img.shields.io/badge/language-Swift%204-orange.svg)

**智汀云家庭** 是一款在 Swift 5 中开发的 iOS 智能家具APP。该应用一直在积极升级以采用 iOS 和 Swift 语言的最新功能。此应用可以发现和连接家庭网络内符合相对应协议的终端产品，并基于这些产品打造接地气的生活场景，提供人性化的信息提示和交互，以及便捷的配套服务。

1.轻松控制设备

您可以方便地调节智能灯的亮度和色温、智能控制开关插座、智能窗帘、空调的温度等等，即使不在家也能远程控制家里的智能设备

2.查看设备运行状况

您可以在APP上查看每个设备的运行状态，是否开启或关闭。

3.设置相应的控制场景


## 开发环境
当前版本适用于 Xcode 版本 Xcode 12.5 。如果您使用不同的 Xcode 版本，请查看之前的版本。

## 版本
此版本为仅使用 Swift 5 支持 iOS 13+。

## 特征
* MVC— Model View controller 常规设计模式
* 基于值的编程 - 在任何地方使用不可变值。
* Animations动画
* [HandyJSON](https://github.com/alibaba/handyjson)
* 网络请求是使用[Moya](https://github.com/Moya/Moya)对[Alamofire](https://github.com/Alamofire/Alamofire)的再次封装
  

## 如何构建

1) 克隆存储库

```bash
$ git clone https://github.com/JakeLin/SwiftLanguageWeather.git
```

2) Install pods

```bash
$ cd sa-ios-sdk
$ pod install
```

3) 在 Xcode 中打开工作区

```bash
$ open "ZhiTing.xcworkspace"
```

4) 在模拟器中编译并运行应用程序

5) 如果您没有看到任何数据，请检查 "Simulator" -> "Debug" -> "Location" 以更改位置。

# 要求

* Xcode 12
* iOS 13+
* Swift 5

