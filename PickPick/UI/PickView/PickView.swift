//
//  PickView.swift
//  PickPick
//
//  Created by Ruben Mimoun on 01/02/2024.
//

import SwiftUI
import TipKit
import Combine

struct PickView: View {
    
    let observer: PickObserver
    @State private var isSelected: Bool = false
    @State private var showSheet: Bool = false
    @Namespace var resultView
    
    private var tip =  SelectionCountTip()
    private var removeTip = RemoveTip()
    
    init(observer: PickObserver = .init()) {
        self.observer = observer
    }
    
    var body: some View {
        content
        .animation(.smooth, value: observer.touchCount)
        .animation(.smooth, value: observer.hasTouched)
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
        navigationContent {
            if isSelected {
                resultSelectedView
                .ignoresSafeArea()
                .overlay(alignment: .bottom) { restartButton }
            } else {
                ZStack {
                    touchBackgroundDetector
                    idleView
                    touchesView
                   
                }
                .ignoresSafeArea()
                .matchedGeometryEffect(id: "MAIN", in: resultView)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolBarContent
                }
                .sheet(isPresented: $showSheet) {
                    SelectionCountSheet(count: observer.selectionRequired, show: $showSheet)
                        .background(Color.black)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolBarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                Task {
                    tip.invalidate(reason: .actionPerformed)
                    try? await  Task.sleep(for: .milliseconds(300))
                    await MainActor.run {
                        showSheet = true
                    }
                }
                
            }, label: {
                if observer.selectionRequired.wrappedValue > 1 {
                    Text("\(observer.selectionRequired.wrappedValue)")
                        .appFontStyle()
                        .padding(4)
                        .background {
                          Circle()
                                .fill(Color.blue)
                        }
                        .scaleEffect(2.0)
                        .padding(.trailing)

                    
                } else {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .padding(4)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                        }
                }
            })
            .popoverTip(tip)
            .opacity(observer.hasTouched ? 1 : 0)
        }
        
        ToolbarItem(placement: .principal) {
            if observer.hasTouched {
                TimerView(observer: .init(timerState: observer.timerState), isButtonEnabled: Binding(
                    get: { !observer.touchObservers.isEmpty },
                    set: { _ in }))
                .transition(.move(edge: .top))
                .onAppear {
                    SelectionCountTip.canShow = true
                }
            }
        }
    }
    
    func navigationContent<Content: View>(@ViewBuilder content: () -> Content) -> some View  {
        NavigationStack {
            content()
        }
    }
    
    @ViewBuilder
    var resultSelectedView: some View  {
        ZStack {
            Color.black
            if observer.selectionRequired.wrappedValue > 1 {
                ForEach(observer.getMultiplePicked()) {
                    TouchView(observer: $0)
                        .matchedGeometryEffect(id: $0.id, in: resultView)
                }
                .scaleEffect(0.7)
            } else {
                TouchView(observer: observer.getPicked())
                    .matchedGeometryEffect(id: "RESULT", in: resultView)
            }
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
    var idleView: some View  {
        if !observer.hasTouched {
            VStack {
                Text("Whoever is participating,")
                Text("tap the screen")
            }
            .onTapGesture {
                observer.hasTouched = true
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
        .overlay(alignment: .bottom) {
            if observer.hasTouched && observer.touchCount > 0 {
                TipView(removeTip)
                    .padding()
            }
        }
    }
    
    var restartButton: some View {
        Button {
            observer.restart()
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

