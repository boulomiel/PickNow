//
//  PickView.swift
//  PickPick
//
//  Created by Ruben Mimoun on 01/02/2024.
//

import SwiftUI
import Combine

struct PickView: View {
    
    let observer: PickObserver
    @State var isSelected: Bool = false
    @Namespace var resultView
    
    init(observer: PickObserver = .init()) {
        self.observer = observer
    }
    
    var body: some View {
        content
        .animation(.smooth, value: observer.touchCount)
        .animation(.snappy, value: observer.animState)
        .ignoresSafeArea()
        .onReceive(observer.timerState, perform: { state in
            switch state {
            case .idle:
                observer.reset()
            case .started:
                observer.updateAnimState()
            case .update(let time):
                if time > 0 {
                    observer.updateAnimState()
                }
            case .finished:
                withAnimation {
                    isSelected = true
                }
            }
        })
        .onChange(of: observer.animState) { state, initial in
            switch state {
            case .idle:
                break
            case .expanded:
                observer.circlePositionsForCenter()
            case .rotating:
                break
            case .center:
                break
            }
        }
    }
    
    @ViewBuilder
    var content: some View {
        if isSelected {
            ZStack {
                Color.black
                TouchView(observer: observer.getPicked())
                    .matchedGeometryEffect(id: "RESULT", in: resultView)
            }
            .overlay(alignment: .bottom) { restartButton }
        } else {
            ZStack {
                touchBackgroundDetector
                timerView
                touchesView
            }
            .matchedGeometryEffect(id: "MAIN", in: resultView)
        }
    }

    var touchBackgroundDetector: some View {
        TapView { point in
            triggerVibration()
            observer.add(point)
        } onRemovePress: { point in
            observer.remove(point)
        } onUpdate: { point in
            observer.updateLast(point)
        }
        .background {
            Color.clear.padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var timerView: some View {
        if observer.hasTouchedSaved {
            GeometryReader(content: { proxy in
                let position = proxy.frame(in: .global)
                TimerView(observer: .init(timerState: observer.timerState))
                    .position(.init(x: position.width / 2, y: 100))
            })
            .transition(.move(edge: .top))
        } else {
            VStack {
                Text("Whoever is participating,")
                Text("tap the screen")
            }
            .appFontStyle()
        }
    }
    
    var touchesView: some View {
        GeometryReader { proxy in
            ForEach(observer.touchObservers) { touchObserver in
                TouchView(observer: touchObserver)
            }
            .onAppear(perform: {
                let frame = proxy.frame(in: .local)
                observer.center = .init(x: frame.width / 2, y: frame.height / 2)
            })
            .scaleEffect(observer.animState == .expanded ? 0.6 : 1)
            .rotationEffect(observer.animState == .rotating ? Angle(radians: .pi) : .zero)
            .scaleEffect(observer.animState == .center ? 0.0 : 1)
        }
    }
    
    var restartButton: some View {
        Button {
            observer.timerState.send(.idle)
            withAnimation {
                isSelected = false
            }
        } label: {
            Text("RESTART")
                .bold()
                .appFontStyle()
        }
        .padding(.vertical)
    }
    
    @Observable
    class PickObserver {
        
        var touchObservers: [TouchView.TouchObserver]
        var timerState: PassthroughSubject<TimerState, Never>
        var animState: AnimState
        var center: CGPoint
        
        var hasTouchedSaved: Bool {
            return !touchObservers.isEmpty
        }
        
        var touchCount: Int {
            touchObservers.count
        }
        
        init(touchObservers: [TouchView.TouchObserver] = [],
             timerState: PassthroughSubject<TimerState, Never> = .init(),
             animState: AnimState = .idle) {
            self.touchObservers = touchObservers
            self.timerState = timerState
            self.center = .zero
            self.animState = animState
        }
        
        func add(_ point: CGPoint) {
            touchObservers.append(.init(position: point, onRemove: remove))
        }
        
        func updateLast(_ point: CGPoint) {
            touchObservers.last?.position = point
        }
        
        func circlePositionsForCenter() {
            circlePositions(radius: center.x)
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
        
        func reset() {
            center = .zero
            animState = .idle
            touchObservers = []
        }
        
        func updateAnimState() {
            animState = animState.next
        }
        
        private func circlePositions(radius: CGFloat) {
             for (i, observer) in touchObservers.enumerated() {
                 let angle = 2 * .pi / CGFloat(touchCount) * CGFloat(i)
                 let x = radius * cos(angle) + radius
                 let y = radius * sin(angle) + radius * 2
                 observer.position = .init(x: x, y: y)
             }
         }
    }
    
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
}

extension View  {
    func appFontStyle() -> some View  {
        self
            .fontWidth(.expanded)
            .fontDesign(.monospaced)
            .fontWeight(.bold)
            .foregroundStyle(.white)
    }
}

#Preview {
    PickView(observer: .init())
}
