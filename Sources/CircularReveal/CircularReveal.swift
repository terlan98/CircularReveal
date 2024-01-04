//
//  CircularReveal.swift
//
//  Created by Tarlan Ismayilsoy on 03.12.23.
//

import SwiftUI
import Combine

struct CircularRevealBool<V>: ViewModifier where V: View {
    @Binding var isRevealed: Bool
    var animationDuration: TimeInterval
    var onDismiss: (() -> Void)?
    var viewToReveal: () -> V
    
    @State private var tapLocation: CGPoint = .zero
    @State private var isRevealedCopy = false
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded({ dragValue in
                        tapLocation = dragValue.location.relativeToScreenCenter()
                    })
            )
            .onAppear { isRevealedCopy = isRevealed }
            .onChange(of: isRevealed) { revealing in
                // Prevent default fullScreenCover animation
                UIView.setAnimationsEnabled(false)
                
                if revealing {
                    isRevealedCopy = true
                } else {
                    Task {
                        // Wait for the dismiss animation
                        try? await Task.sleep(for: .seconds(animationDuration))
                        
                        // Perform dismiss
                        await MainActor.run {
                            isRevealedCopy = false
                            onDismiss?()
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isRevealedCopy, content: {
                if isRevealed {
                    viewToReveal()
                        .maskWithCircleAndAnimate(type: .expand,
                                                  tapLocation: tapLocation,
                                                  animationDuration: animationDuration)
                } else {
                    viewToReveal()
                        .maskWithCircleAndAnimate(type: .shrink,
                                                  tapLocation: tapLocation,
                                                  animationDuration: animationDuration)
                }
            })
    }
}

struct CircularRevealItem<V, ItemType>: ViewModifier where V: View, ItemType: Identifiable & Equatable {
    @Binding var item: ItemType?
    var animationDuration: TimeInterval
    var onDismiss: (() -> Void)?
    var viewToReveal: (ItemType) -> V
    
    @State private var tapLocation: CGPoint = .zero
    @State private var itemCopy: ItemType? = nil
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded({ dragValue in
                        tapLocation = dragValue.location.relativeToScreenCenter()
                    })
            )
            .onAppear { itemCopy = item }
            .onChange(of: item) { newItem in
                // Prevent default fullScreenCover animation
                UIView.setAnimationsEnabled(false)
                
                if newItem != nil {
                    itemCopy = newItem
                } else {
                    Task {
                        // Wait for the dismiss animation
                        try? await Task.sleep(for: .seconds(animationDuration))
                        
                        // Perform dismiss
                        await MainActor.run {
                            itemCopy = nil
                            onDismiss?()
                        }
                    }
                }
            }
            .fullScreenCover(item: $itemCopy, content: { itemCopy in
                if item != nil {
                    viewToReveal(itemCopy)
                        .maskWithCircleAndAnimate(type: .expand,
                                                  tapLocation: tapLocation,
                                                  animationDuration: animationDuration)
                } else {
                    viewToReveal(itemCopy)
                        .maskWithCircleAndAnimate(type: .shrink,
                                                  tapLocation: tapLocation,
                                                  animationDuration: animationDuration)
                }
            })
    }
}

public extension View {
    /// Presents a modal view that covers the whole screen gradually
    /// with a circular animation when binding to a Boolean value you 
    /// provide is true.
    ///
    /// - Note: If you'd like the presented view to also be
    /// dismissed with animation, make sure to pass the binding to it.
    /// The view should set it to `false` in order to dismiss itself.
    ///
    /// - Parameters:
    ///   - isRevealed: A binding to a Boolean value that determines whether
    ///     to present the view.
    ///   - animationDuration: The duration of the circular animation.
    ///   - onDismiss: The closure to execute when dismissing the presented view.
    ///   - content: A closure that returns the content that should be presented.
    func circularReveal<Content>(isRevealed: Binding<Bool>,
                                 animationDuration: TimeInterval = 0.3,
                                 onDismiss: (() -> Void)? = nil,
                                 @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(CircularRevealBool(isRevealed: isRevealed,
                                    animationDuration: animationDuration,
                                    onDismiss: onDismiss,
                                    viewToReveal: content))
    }
    
    /// Presents a modal view that covers the whole screen gradually
    /// with a circular animation using the binding you provide as a
    /// data source for the view's content.
    ///
    /// - Note: If you'd like the presented view to also be
    /// dismissed with animation, make sure to pass the binding to it.
    /// The view should set it to `nil` in order to dismiss itself.
    ///
    /// - Parameters:
    ///   - item: A binding to an optional source of truth that determines whether
    ///     to present the view.
    ///   - animationDuration: The duration of the circular animation.
    ///   - onDismiss: The closure to execute when dismissing the presented view.
    ///   - content: A closure that returns the content that should be presented.
    func circularReveal<Item, Content>(item: Binding<Item?>,
                                       animationDuration: TimeInterval = 0.3,
                                       onDismiss: (() -> Void)? = nil,
                                       @ViewBuilder content: @escaping (Item) -> Content) -> some View where Content : View, Item: Identifiable & Equatable {
        modifier(CircularRevealItem(item: item,
                                    animationDuration: animationDuration,
                                    onDismiss: onDismiss,
                                    viewToReveal: content))
    }
}

extension CGPoint {
    func relativeToScreenCenter() -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return CGPoint(x: self.x - screenWidth / 2, y: self.y - screenHeight / 2)
    }
}
