## FIB Payment SDK

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Alamofire.svg)

FIB Payment SDK is a payment library using First Iraqi Bank App written in Swift.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Features
- [x] Make payment transaction using FIB App.
- [x] Support 2 FIB apps (Personal & Business).

## Requirements

- iOS 12.0+ 
- Xcode 11+
- Swift 5.0+

## Installation

### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. 
- To integrate FIBPaymentSDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "https://github.com/MohamadMareri/FIB-Payment-SDK" ~> 1.0
```

- Close your Cartfile in Xcode and head back to Terminal. Run the following command:
```ogdl
carthage update --platform iOS
```
This instructs Carthage to clone the Git repositories that are specified in the Cartfile, and then build each dependency into a framework. 

The `--platform iOS` option ensures that frameworks are only built for iOS. If you don’t specify a platform, then by default Carthage will build frameworks for all platforms (often both Mac and iOS) supported by the library.

By default, Carthage will perform its checkouts and builds in a new directory named `Carthage` in the same location as your Cartfile. Open up this directory now by running `open Carthage`

You should see a Finder window pop up that contains two directories: Build and Checkouts.

Now you need to add Framework to Your Project, click on your project in the Project Navigator. Select the target, choose the General tab at the top, and scroll down to the Linked Frameworks and Libraries section at the bottom.

In the Carthage Finder window, navigate into Build\iOS. Drag both FIB-Payment-SDK.framework into the Linked Frameworks and Libraries section in Xcode.

Next, switch over to Build Phases and add a new Run Script build phase by clicking the + in the top left of the editor. Add the following command:
```ogdl
/usr/local/bin/carthage copy-frameworks
```

Click the + under Input Files and add an entry for the framework:
```ogdl
$(SRCROOT)/Carthage/Build/iOS/FIB-Payment-SDK.framework
```

## License

Alamofire is released under the MIT license. [See LICENSE](https://github.com/MohamadMareri/FIB-Payment-SDK/blob/master/LICENSE) for details.
