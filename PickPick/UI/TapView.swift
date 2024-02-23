//
//  TapView.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation
import SwiftUI

struct TapView: UIViewRepresentable {
    
    var onLongPress: (CGPoint) -> Void
    var onRemovePress: (CGPoint) -> Void
    var onUpdate: (CGPoint) -> Void
    
    func makeUIView(context: Context) -> UIView {
        let v =  UIView()
        v.backgroundColor = .black
        return v
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.view = uiView
        context.coordinator.addGesture()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    typealias UIViewType = UIView
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        
        let parent: TapView
        var view: UIView?
        
        init(parent: TapView) {
            self.parent = parent
        }
        
        func addGesture() {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addLongPress))
            gesture.delegate = self
            self.view?.addGestureRecognizer(gesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addTapGesture))
            self.view?.addGestureRecognizer(tapGesture)
        }
        
        @objc func addLongPress(_ sender: UILongPressGestureRecognizer) {
            guard let view = view else { return }
            let location = sender.location(in: view)
            switch sender.state {
            case .possible:
                break
            case .began:
                self.parent.onLongPress(location)
            case .changed:
                self.parent.onUpdate(location)
            default:
                break
            }
        }
        
        @objc func addTapGesture(_ sender: UITapGestureRecognizer) {
            guard let view = view else { return }
            let location = sender.location(in: view)
            switch sender.state {
            case .ended:
                self.parent.onLongPress(location)
            default:
                break
            }
        }
    }
    
    
}
