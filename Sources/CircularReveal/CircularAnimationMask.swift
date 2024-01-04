//
//  CircularAnimationMask.swift
//
//
//  Created by Tarlan Ismayilsoy on 16.12.23.
//

import SwiftUI

fileprivate let minCircleSideLength = 50.0
fileprivate let maxCircleSideLength = UIScreen.main.bounds.height * 2.25
fileprivate let initialViewToRevealOpacity = 0.2

struct CircularAnimationMask: ViewModifier {
    var type: CircularAnimationType
    var tapLocation: CGPoint
    var animationDuration: TimeInterval
    
    @State private var currentOpacity: Double
    @State private var circleSize: CGFloat
    
    private let targetCircleSideLength: CGFloat
    private let targetOpacity: Double
    private let opacityAnimation: Animation
    private let circleSizeAnimation: Animation
    
    init(type: CircularAnimationType,
         tapLocation: CGPoint,
         animationDuration: TimeInterval) {
        self.type = type
        self.tapLocation = tapLocation
        self.animationDuration = animationDuration
        
        if type == .expand {
            self.opacityAnimation = .easeOut(duration: animationDuration * 0.5)
            self.circleSizeAnimation = .easeIn(duration: animationDuration)
        } else {
            self.opacityAnimation = .easeIn(duration: animationDuration * 4)
            self.circleSizeAnimation = .easeOut(duration: animationDuration)
        }
        
        self.currentOpacity = (type == .expand) ? initialViewToRevealOpacity : 1.0
        self.targetOpacity = (type == .expand) ? 1.0 : initialViewToRevealOpacity
        self.circleSize = (type == .expand) ? minCircleSideLength : maxCircleSideLength
        self.targetCircleSideLength = (type == .expand) ? maxCircleSideLength : minCircleSideLength
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Re-enable animations
                UIView.setAnimationsEnabled(type == .expand)
            }
            .onDisappear {
                // Re-enable animations
                UIView.setAnimationsEnabled(type == .shrink)
            }
            .opacity(currentOpacity)
            .animation(opacityAnimation, value: currentOpacity)
            .mask (
                Circle()
                    .offset(tapLocation)
                    .frame(width: circleSize, height: circleSize)
                    .ignoresSafeArea()
                    .animation(.easeIn(duration: animationDuration), value: circleSize)
                    .onAppear() {
                        self.circleSize = targetCircleSideLength
                        self.currentOpacity = targetOpacity
                    }
            )
            .background(ClearBackgroundView())
    }
}

enum CircularAnimationType {
    case expand, shrink
}

extension View {
    func maskWithCircleAndAnimate(type: CircularAnimationType,
                                  tapLocation: CGPoint,
                                  animationDuration: TimeInterval) -> some View {
        modifier(CircularAnimationMask(type: type,
                                   tapLocation: tapLocation,
                                   animationDuration: animationDuration))
    }
}
