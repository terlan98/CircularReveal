
# CircularReveal
![ios](https://img.shields.io/badge/Platforms-iOS_16+-lightgray?style=for-the-badge&logo=apple)
![swiftui](https://img.shields.io/badge/MADE_WITH-SWIFTUI-0097FE?style=for-the-badge)
![spm](https://img.shields.io/badge/SwiftPM-compatible-brightgreen?style=for-the-badge&logo=swift)
![license](https://img.shields.io/github/license/terlan98/CircularSlider?style=for-the-badge)

A SwiftUI package for presenting views with a circular animation.

<p align="center">
<img width=35% src="https://github.com/terlan98/CircularReveal/assets/22798314/90c26fe1-37b2-4555-b66c-8689112ddac1">
</p>

## 📦 Features
- Trigger with a boolean or an arbitrary item
- Set custom animation duration
- Execute a closure when the presented view is dismissed

## 🛠 Installation
You can install `CircularReveal` by going to your Project settings > Swift Packages and add the repository by providing the GitHub URL. Alternatively, you can go to File > Swift Packages > Add Package Dependencies...

## 🚀 Usage
### Example

```swift
struct FirstView: View {
    @State private var isRevealed = false

    var body: some View {
        VStack {
            Text("This is the first view")

            Button("Present Second View") {
                isRevealed = true
            }
        }
        .circularReveal(isRevealed: $isRevealed) {
            SecondView(isRevealed: $isRevealed)
        }
    }
}
```

```swift
struct SecondView: View {
    @Binding var isRevealed: Bool

    var body: some View {
        VStack {
            Text("This is the second view")
  
            Button("Dismiss Second View") {
                isRevealed = false
            }
        }
    }
}
```

For more examples, check out the [Examples](https://github.com/terlan98/CircularReveal/tree/main/Sources/Examples) folder

## 🤝 Contribution
I highly appreciate and welcome any issue reports, feature requests, pull requests, or GitHub stars you may provide.

# License
CircularReveal is released under the MIT license. 

<a href="https://www.buymeacoffee.com/terlan98" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 2.5em !important;width: 9em !important;" ></a>

