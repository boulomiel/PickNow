//
//  PickObserver.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation
import SwiftUI
import Combine

@Observable
class PickObserver {
    
    var touchObservers: [TouchView.TouchObserver]
    var timerState: PassthroughSubject<TimerState, Never>
    var animState: AnimState
    var center: CGPoint
    var hasTouched: Bool
    
    var touchCount: Int {
        touchObservers.count
    }
    
    private var _selectionRequired: Int
    
    var selectionRequired: Binding<Int> {
        Binding(get: { self._selectionRequired },
                set: { self._selectionRequired = $0 })

    }
    
    init(touchObservers: [TouchView.TouchObserver] = [],
         timerState: PassthroughSubject<TimerState, Never> = .init(),
         animState: AnimState = .idle) {
        self.touchObservers = touchObservers
        self.timerState = timerState
        self.center = .zero
        self.animState = animState
        self.hasTouched = false
        self._selectionRequired = 1
    }
    
    func add(_ point: CGPoint) {
        if hasTouched {
            touchObservers.append(.init(position: point, onRemove: remove))
        } else {
            hasTouched = true
        }
    }
    
    func updateLast(_ point: CGPoint) {
        touchObservers.last?.position = point
    }
    
    func circlePositionsForCenter() {
        circlePositions(elements: touchObservers, radius: center.x)
    }
    
    func remove(_ point: CGPoint) {
        let point = CGPoint(x: Int(point.x), y: Int(point.y))
        touchObservers.removeAll(where: { p in
            let positionPoint = CGPoint(x: Int(p.position.x), y: Int(p.position.y))
            return abs(point.x - positionPoint.x) <= 10 && abs(point.y - p.position.y) <= 10
        })
    }
    
    func getPicked() -> TouchView.TouchObserver {
        let element = touchObservers.randomElement()!
        element.position = center
        return element
    }
    
    func getMultiplePicked() -> [TouchView.TouchObserver] {
        var observers = touchObservers
        var results: [TouchView.TouchObserver] = []
        for i in 0..<_selectionRequired {
            if !observers.isEmpty {
                let element = observers.randomElement()!
                observers.removeAll(where: { $0.id == element.id })
                results.append(element)
            }
            
        }
        circlePositions(elements: results, radius: center.x)
        return results
    }
    
    func restart() {
        selectionRequired.wrappedValue = 1
        hasTouched = false
        timerState.send(.idle)
    }
    
    func reset() {
        center = .zero
        animState = .idle
        touchObservers = []
    }
    
    func updateAnimState() {
        animState = animState.next
    }
    
    private func circlePositions(elements: [TouchView.TouchObserver], radius: CGFloat) {
         for (i, observer) in elements.enumerated() {
             let angle = 2 * .pi / CGFloat(elements.count) * CGFloat(i)
             let x = radius * cos(angle) + radius
             let y = radius * sin(angle) + radius * 2
             observer.position = .init(x: x, y: y)
         }
     }
}
