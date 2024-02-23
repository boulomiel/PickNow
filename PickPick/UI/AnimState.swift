//
//  AnimState.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation

enum AnimState {
    case idle, expanded, rotating, center
    
    var isCircled: Bool {
        return self == .expanded
    }
    
    var next: Self {
        switch self {
        case .idle:
            return .expanded
        case .expanded:
            return .rotating
        case .rotating:
            return .center
        case .center:
            return .idle
        }
    }
}
