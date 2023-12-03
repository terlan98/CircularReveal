//
//  CircularReveal.swift
//
//  Created by Tarlan Ismayilsoy on 03.12.23.
//

import SwiftUI

// TODO: make it work for a bool
// TODO: make it work for a binding item
// TODO: also animate dismiss action
struct CircularReveal<V>: ViewModifier where V: View {
    @Binding var isPresented: Bool
    var viewToReveal: () -> V
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _ in
                UIView.setAnimationsEnabled(!isPresented)
            }
            .fullScreenCover(isPresented: .constant(true), content: { // TODO: remove constant
                viewToReveal()
                    .onAppear {
                        UIView.setAnimationsEnabled(true)
                    }
                    .mask (
                        Circle()
                            .frame(width: 100)
                    )
            })
    }
}

public extension View {
    func circularReveal<Content>(isPresented: Binding<Bool>,
                        @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(CircularReveal(isPresented: isPresented, viewToReveal: content))
    }
}

//extension View {
//    /// Works like mask, but in reverse
//    @inlinable func reverseMask<Mask: View>(
//        alignment: Alignment = .center,
//        @ViewBuilder _ mask: () -> Mask
//    ) -> some View {
//        self.mask(
//            ZStack {
//                Rectangle()
//                    .ignoresSafeArea()
//                
//                mask()
//                    .blendMode(.destinationOut)
//            }
//        )
//    }
//}

