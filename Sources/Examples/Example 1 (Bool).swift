//
//  Example 1 (Bool).swift
//  Contains two views as an example usage of CircularReveal toggled with a boolean.
//
//  Created by Tarlan Ismayilsoy on 03.01.24.
//

import SwiftUI
import CircularReveal

struct FirstView: View {
    @State private var isRevealed = false
    
    var body: some View {
        VStack {
            Text("This is the first view")
                .font(.title)
            
            Button("Reveal Second View") {
                isRevealed = true
            }
            .tint(.black)
            .buttonStyle(.bordered)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue)
        .circularReveal(isRevealed: $isRevealed, animationDuration: 0.6) {
            print("Second view dismissed")
        } content: {
            SecondView(isRevealed: $isRevealed)
        }
    }
}

struct SecondView: View {
    @Binding var isRevealed: Bool
    
    var body: some View {
        VStack {
            Text("This is the second view")
                .font(.title)
            
            Button("Dismiss") {
                isRevealed = false
            }
            .tint(.black)
            .buttonStyle(.bordered)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.green)
    }
}
