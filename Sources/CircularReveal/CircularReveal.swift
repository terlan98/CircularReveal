//
//  CircularReveal.swift
//
//  Created by Tarlan Ismayilsoy on 03.12.23.
//

import SwiftUI
import Combine

fileprivate let minCircleSideLength = 50.0
fileprivate let initialViewToRevealOpacity = 0.2

// TODO: 3. also animate dismiss action
// TODO: 4. Add onDismiss parameter (because it exists in .fullScreenCover)
// TODO: 5. remove prints :)
struct CircularRevealBool<V>: ViewModifier where V: View {
    @Binding var isPresented: Bool
    var animationDuration: TimeInterval
    var viewToReveal: () -> V
    
    @State private var tapLocation: CGPoint = .zero
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded({ dragValue in
                        tapLocation = dragValue.location.relativeToScreenCenter()
                    })
            )
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Prevent default fullScreenCover animation
                    UIView.setAnimationsEnabled(false)
                }
            }
            .fullScreenCover(isPresented: $isPresented, content: {
                viewToReveal()
                    .maskWithCircleAndAnimate(tapLocation: tapLocation,
                                              animationDuration: animationDuration)
            })
    }
}

struct CircularRevealItem<V, ItemType>: ViewModifier where V: View, ItemType: Identifiable & Equatable {
    @Binding var item: ItemType?
    var animationDuration: TimeInterval
    var viewToReveal: (ItemType) -> V
    
    @State private var tapLocation: CGPoint = .zero
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded({ dragValue in
                        tapLocation = dragValue.location.relativeToScreenCenter()
                    })
            )
            .onChange(of: item) { newItem in
                if newItem != nil {
                    // Prevent default fullScreenCover animation
                    UIView.setAnimationsEnabled(false)
                }
            }
            .fullScreenCover(item: $item, content: { it in
                viewToReveal(it)
                    .maskWithCircleAndAnimate(tapLocation: tapLocation,
                                              animationDuration: animationDuration)
            })
    }
}

public extension View {
    func circularReveal<Content>(isPresented: Binding<Bool>,
                                 animationDuration: TimeInterval = 0.3,
                                 @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(CircularRevealBool(isPresented: isPresented,
                                    animationDuration: animationDuration,
                                    viewToReveal: content))
    }
    
    func circularReveal<Item, Content>(item: Binding<Item?>,
                                       animationDuration: TimeInterval = 0.3,
                                       @ViewBuilder content: @escaping (Item) -> Content) -> some View where Content : View, Item: Identifiable & Equatable {
        modifier(CircularRevealItem(item: item,
                                    animationDuration: animationDuration,
                                    viewToReveal: content))
    }
}

extension CGPoint {
    // TODO: Check if this function is being called too much and using substantial resources
    func relativeToScreenCenter() -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return CGPoint(x: self.x - screenWidth / 2, y: self.y - screenHeight / 2)
    }
}

struct AnimateCircleMask: ViewModifier {
    var tapLocation: CGPoint
    var animationDuration: TimeInterval
    
    @State private var viewToRevealOpacity: Double = initialViewToRevealOpacity
    @State private var circleSize: CGFloat = minCircleSideLength
    
    private let maxCircleSideLength = UIScreen.main.bounds.height * 2
    
    func body(content: Content) -> some View {
        content
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
    }
}

extension View {
    func maskWithCircleAndAnimate(tapLocation: CGPoint, animationDuration: TimeInterval) -> some View {
        modifier(AnimateCircleMask(tapLocation: tapLocation, animationDuration: animationDuration))
    }
}
