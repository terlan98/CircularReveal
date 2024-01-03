//
//  Example 2 (Item).swift
//  Contains two views as an example usage of CircularReveal toggled with an item (Equatable & Identifiable).
//
//  Created by Tarlan Ismayilsoy on 03.01.24.
//

import Foundation

struct FirstView: View {
    @State private var city: City? = nil
    
    var body: some View {
        VStack {
            Text("This is the first view")
                .font(.title)
            
            Button("Reveal Second View") {
                city = City(name: "Munich")
            }
            .tint(.black)
            .buttonStyle(.bordered)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue)
        .circularReveal(item: $city, animationDuration: 0.6) {
            print("Second view dismissed")
        } content: { _ in
            SecondView(city: $city)
        }
    }
}

struct SecondView: View {
    @Binding var city: City?
    
    var body: some View {
        VStack {
            Text("This is the second view")
                .font(.title)
            
            Button("Dismiss") {
                city = nil
            }
            .tint(.black)
            .buttonStyle(.bordered)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.green)
    }
}

struct City: Identifiable, Equatable {
    var id = UUID()
    var name: String
}
