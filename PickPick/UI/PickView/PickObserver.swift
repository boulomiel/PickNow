//
//  PickObserver.swift
//  PickNow
//
//  Created by Ruben Mimoun on 23/02/2024.
//

import Foundation
import SwiftUI
import Combine

enum SelectionType {
    case idle
    case taps
    case names
}

@Observable
class PickObserver {
    
    var touchObservers: [TouchView.TouchObserver]
    var timerState: PassthroughSubject<TimerView.TimerState, Never>
    var animState: AnimState
    var center: CGPoint
    var pickedState: PickState
    var selectionType: SelectionType
    
    var closeCountTip = 0
    
    var canShowNameTooltipe: Bool {
        pickedState == .touchedOne && closeCountTip > 0
    }
    
    var canShowRemoveTooltip: Bool {
        pickedState == .touchedOne && touchCount > 0
    }
    
    var touchCount: Int {
        touchObservers.count
    }
    
    var selectionRequired: Int
    var selectedNames: [String]
    
    init(touchObservers: [TouchView.TouchObserver] = [],
         timerState: PassthroughSubject<TimerView.TimerState, Never> = .init(),
         animState: AnimState = .idle) {
        self.touchObservers = touchObservers
        self.timerState = timerState
        self.center = .zero
        self.animState = animState
        self.pickedState = .idle
        self.selectionRequired = 1
        self.selectedNames = []
        self.selectionType = .idle
    }
    
    func setSelectedNames(_ names: [String]) {
        self.selectedNames = names
        self.selectionType = .names
    }
    
    func add(_ point: CGPoint) {
        if pickedState == .touchedOne {
            let lastColor = touchObservers.last?.color
            touchObservers.append(.init(position: point, onRemove: remove, lastColor: lastColor))
        } else {
            pickedState = .touchedOne
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
        guard !touchObservers.isEmpty else { return .init(position: .zero, onRemove: {_ in}, lastColor: nil ) }
        let element = touchObservers.randomElement()!
        element.position = center
        return element
    }
    
    func getMultiplePicked() -> [TouchView.TouchObserver] {
        var observers = touchObservers
        var results: [TouchView.TouchObserver] = []
        for _ in 0..<_selectionRequired {
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
      //  reset()
        timerState.send(.idle)
        pickedState = .idle
        selectionType = .idle
        selectedNames = []
        selectionRequired = 1
    }
    
    func reset() {
        center = .zero
        animState = .idle
        touchObservers = []
    }
    
    func updateAnimState() {
        animState = animState.next
        print(animState)
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
