//
//  CircularReveal.swift
//
//  Created by Tarlan Ismayilsoy on 03.12.23.
//

import SwiftUI
import Combine

// TODO: 5. remove prints :)
struct CircularRevealBool<V>: ViewModifier where V: View {
    @Binding var isPresented: Bool
    var animationDuration: TimeInterval
    var onDismiss: (() -> Void)?
    var viewToReveal: () -> V
    
    @State private var tapLocation: CGPoint = .zero
    @State private var isPresentedCopy = false
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded({ dragValue in
                        tapLocation = dragValue.location.relativeToScreenCenter()
                    })
            )
            .onAppear { isPresentedCopy = isPresented }
            .onChange(of: isPresented) { revealing in
                // Prevent default fullScreenCover animation
                UIView.setAnimationsEnabled(false)
                
                if revealing {
                    isPresentedCopy = true
                } else {
                    Task {
                        // Wait for the dismiss animation
                        try? await Task.sleep(for: .seconds(animationDuration))
                        
                        // Perform dismiss
                        await MainActor.run {
                            isPresentedCopy = false
                            onDismiss?()
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresentedCopy, content: {
                if isPresented {
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
    func circularReveal<Content>(isPresented: Binding<Bool>,
                                 animationDuration: TimeInterval = 0.3,
                                 onDismiss: (() -> Void)? = nil,
                                 @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        modifier(CircularRevealBool(isPresented: isPresented,
                                    animationDuration: animationDuration,
                                    onDismiss: onDismiss,
                                    viewToReveal: content))
    }
    
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
    // TODO: Check if this function is being called too much and using substantial resources
    func relativeToScreenCenter() -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        return CGPoint(x: self.x - screenWidth / 2, y: self.y - screenHeight / 2)
    }
}
