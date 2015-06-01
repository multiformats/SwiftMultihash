# Swift Multihash
[multihash](//github.com/jbenet/multihash) implementation in Swift.

## Installation
#### Carthage
Add the following to your Cartfile 
```
github "NeoTeo/SwiftMultihash"
```
Then, in the root of your project, type:
`carthage update`

If you need the Multihash Sum functions:
Because the CryptoSwift project defaults to building for iOS and I haven't figured out how to tell Carthage to tell Xcode 
which build to do you will have to do the following:

- In Xcode open the CryptoSwift project in `Carthage/Checkouts/CryptoSwift/CryptoSwift.xcodeproject`
- Select the project and in the Build Settings change the "Base SDK" to "Latest OS X". Close the project.
- from the Multihash root type `carthage build`

##### You will then need to add SwiftMultihash.framework to your Xcode project:

- Select your target's General tab.

- Add SwiftMultihash.framework, SwiftBase58.framework and SwiftHex.framework from the Carthage/Build/Mac directory in your project root, either by dropping them directly onto the "Embedded Binaries" or by clicking the + and navigating to them.  
 - In case of a code signing error, select the target's Build Settings tab make sure the "Code Signing Identity" is either a valid identity or "Don't Code Sign".

 For more information on how to install via Carthage see the [README][carthage-installation]

 [carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

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

## License

MIT
