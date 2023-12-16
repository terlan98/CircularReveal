//
//  ClearBackgroundView.swift
//
//
//  Created by Tarlan Ismayilsoy on 13.12.23.
//

import SwiftUI

/// Intended for clearing the background of a fullScreenCover
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
