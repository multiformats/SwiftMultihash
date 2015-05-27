# Swift Multihash
[multihash](//github.com/jbenet/multihash) implementation in Swift.

## Installation
### Using Carthage
Add the following to your Cartfile 
```
github "NeoTeo/SwiftMultihash"
```
Then, in the root of your project, type:
`carthage update`

##### You will then need to add SwiftMultihash.framework to your Xcode project:

- Select your target's General tab.

- Add the framework from the Carthage/Build/Mac directory in your project root,
 either by dropping the SwiftMultihash.framework file directly onto the "Embedded Binaries" or by clicking the + and navigating to it.  
 - In case of a code signing error, select the target's Build Settings tab make sure the "Code Signing Identity" is either a valid identity or "Don't Code Sign".

 For more information on how to install via Carthage see the [README][carthage-installation]

 [carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

```Swift
import SwiftMultihash 

func test() {
    let buffer = SwiftHex.decodeString("0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33")
    let (multihashBuffer,_) = SwiftMultihash.encodeName(buffer, "sha1")
    var multihashHex = SwiftHex.encodeToString(multihashBuffer)
    println("Hex: \(multihashHex)")

    let (obj, _) = SwiftMultihash.decode(multihashBuffer)
    multihashHex = SwiftHex.encodeToString(decoded.digest)
    println("name: \(obj.name) code: \(obj.code) \(obj.length) \(multihashHex)") 
}
```

## License

MIT
