# SwiftMultihash

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![](https://img.shields.io/badge/project-multiformats-blue.svg?style=flat-square)](https://github.com/multiformats/multiformats)
[![](https://img.shields.io/badge/freenode-%23ipfs-blue.svg?style=flat-square)](https://webchat.freenode.net/?channels=%23ipfs)
[![](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> Swift implementation of [multihash](//github.com/multiformats/multihash)

## Table of Contents

- [Install](#install)
    - [Carthage](#carthage)
      - [If you get the error 'Project "VarInt.xcodeproj" has no shared schemes'](#if-you-get-the-error-project-varintxcodeproj-has-no-shared-schemes)
      - [You will then need to add frameworks to your own Xcode project:](#you-will-then-need-to-add-frameworks-to-your-own-xcode-project)
  - [Requirements](#requirements)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
- [License](#license)

## Install

#### Carthage
Add the following to your Cartfile:
```
github "multihash/SwiftMultihash"
```
Then, in the root of your project, type:
`carthage update --platform Mac`

##### If you get the error 'Project "VarInt.xcodeproj" has no shared schemes'
Make sure your scheme is marked shared. For more details see [here](https://github.com/Carthage/Carthage)

- from the Multihash root type `carthage build`

##### You will then need to add frameworks to your own Xcode project:

- Select your target's `Build Phases` tab.

- Select the `Link Binary With Libraries`, click the `+` and then `Add Other...` buttons.

- Navigate to the Carthage/Build/Mac directory in your project root and select the SwiftMultihash.framework, SwiftBase58.framework and SwiftHex.framework.  

 - In case of a code signing error, select the target's Build Settings tab make sure the "Code Signing Identity" is either a valid identity or "Don't Code Sign".

 For more information on how to install via Carthage see the [README][carthage-installation]

 [carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### Requirements

- Swift 3

## Usage

```Swift
import SwiftMultihash 
import SwiftHex

func test() {
    
    if let buffer = SwiftHex.decodeString("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33") {
        let (multihashBuffer,_) = SwiftMultihash.encodeName(buffer, "sha1")
        if let mhb = multihashBuffer {
            
            var multihashHex = SwiftHex.encodeToString(mhb)
            println("Hex: \(multihashHex)")
    
            let (object, _) = SwiftMultihash.decode(mhb)
            if let obj = object {
                
                multihashHex = SwiftHex.encodeToString(obj.digest)
                println(String(format: "obj: %@ 0x%X %d %@\n", obj.name!, obj.code, obj.length, multihashHex))
            }
        }
    }
}
```

## Maintainers

Captain: [@NeoTeo](https://github.com/NeoTeo).

## Contribute

Contributions are welcome! Check out [the issues](https://github.com/multiformats/SwiftMultihash/issues).

Check out our [contributing document](https://github.com/multiformats/multiformats/blob/master/contributing.md) for more information on how we work, and about contributing in general. Please be aware that all interactions related to Multiformats are subject to the IPFS [Code of Conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md).

Small note: If editing the README, note that this README should be [standard-readme](https://github.com/RichardLitt/standard-readme) compatible.

## License

[MIT](LICENSE) © 2015 [Matteo Sartori](https://github.com/NeoTeo)
