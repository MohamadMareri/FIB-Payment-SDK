[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

FIB Payment SDk is a payment library using First Iraqi Bank App written in Swift.

- [Features](#features)
- [Installation](#installation)

## Features
- [x] Make payment transaction using FIB App.
- [x] Support 2 FIB apps (Personal & Business).

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
