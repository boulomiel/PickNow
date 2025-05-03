//
//  TransitionView.swift
//  PickPick
//
//  Created by Ruben Mimoun on 02/05/2025.
//

import SwiftUI

public struct TransitionView<Content: View, T: Transition>: View {
    
    let transition: T
    let when: Bool
    let content: () -> Content
    
    public init(transition: T,
                when: Bool,
                @ViewBuilder content: @escaping () -> Content) {
        self.transition = transition
        self.when = when
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            if when {
                content()
                    .transition(transition)
            }
        }
    }
}
