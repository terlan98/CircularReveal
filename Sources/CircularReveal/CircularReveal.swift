//
//  CircularReveal.swift
//
//  Created by Tarlan Ismayilsoy on 03.12.23.
//

import SwiftUI

fileprivate let minCircleSideLength = 50.0
fileprivate let initialViewToRevealOpacity = 0.2

// TODO: 2. make it work for a binding item
// TODO: 3. also animate dismiss action
// TODO: 4. remove prints :)
struct CircularReveal<V>: ViewModifier where V: View {
    @Binding var isPresented: Bool
    var animationDuration: TimeInterval
    var viewToReveal: () -> V
    
    @State private var viewToRevealOpacity: Double = initialViewToRevealOpacity
    @State private var circleSize: CGFloat = minCircleSideLength
    @State private var tapLocation: CGPoint = .zero
    
    private let maxCircleSideLength = UIScreen.main.bounds.height * 2
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ dragValue in
                        tapLocation = centerRelativeLocation(for: dragValue.location)
                    })
            )
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Prevent default fullScreenCover animation
                    UIView.setAnimationsEnabled(false)
                } else {
                    reset()
                }
            }
            .fullScreenCover(isPresented: $isPresented, content: {
                viewToReveal()
                    .onAppear {
                        // Re-enable animations
                        UIView.setAnimationsEnabled(true)
                    }
                    .opacity(viewToRevealOpacity)
                    .animation(.easeOut(duration: animationDuration / 2), value: viewToRevealOpacity)
                    .mask (
                        Circle()
                            .offset(tapLocation)
                            .frame(width: circleSize, height: circleSize)
                            .ignoresSafeArea()
                            .animation(.easeIn(duration: animationDuration), value: circleSize)
                            .onAppear() {
                                self.circleSize = maxCircleSideLength
                                self.viewToRevealOpacity = 1.0
                            }
                    )
                    .background(ClearBackgroundView())
            })
    }
    
    // TODO: Check if this function is being called too much and using susbtantial resources
    private func centerRelativeLocation(for location: CGPoint) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return CGPoint(x: location.x - screenWidth / 2, y: location.y - screenHeight / 2)
    }
    
    /// Resets this view modifier to prepare for reuse
    private func reset() {
        self.circleSize = minCircleSideLength
        self.viewToRevealOpacity = initialViewToRevealOpacity
    }
}

public extension View {
    func circularReveal<Content>(isPresented: Binding<Bool>,
                                 animationDuration: TimeInterval = 0.3,
                                 @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(CircularReveal(isPresented: isPresented,
                                animationDuration: animationDuration,
                                viewToReveal: content))
    }
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return InnerView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            superview?.superview?.backgroundColor = .clear
        }
    }
}
