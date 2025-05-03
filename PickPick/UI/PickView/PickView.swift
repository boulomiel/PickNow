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
    
    @State var observer: PickObserver
    @State private var pickSheet: PickSheet?
    @Namespace var resultView
    
    private var countTip = SelectionCountTip()
    private var nameTip = SelectionNameTip()
    
    private var removeTip = RemoveTip()
    
    init(observer: PickObserver = .init()) {
        self.observer = observer
    }
    
    var body: some View {
        content
            .animation(.smooth, value: observer.touchCount)
            .animation(.smooth, value: observer.pickedState)
            .animation(.smooth, value: observer.selectionType)
            .ignoresSafeArea()
            .onReceive(observer.timerState, perform: { state in

                switch state {
                case .idle:
                    observer.reset()
                case .started, .update:
                    observer.updateAnimState()
                case .finished:
                    observer.selectionType = .taps
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
            .onChange(of: observer.pickedState) { oldValue, newValue in
                if case .touchedOne = newValue {
                    SelectionCountTip.canShow = true
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        navigationContent {
            switch observer.selectionType {
            case .idle:
                ZStack {
                    touchBackgroundDetector
                    idleView
                    touchesView
                }
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolBarContent
                }
                .sheet(item: $pickSheet, content: { sheet in
                    switch sheet {
                    case .selectionCount:
                        SelectionCountSheet(count: $observer.selectionRequired)
                            .background(Color.black)
                    case .selectionName:
                        SelectionNameSheet {
                            observer.setSelectedNames($0)
                        }
                        .background(Color.blue)
                    }
                })
            case .taps:
                resultSelectedView
                    .ignoresSafeArea()
                    .overlay(alignment: .bottom) { restartButton }
            case .names:
                CharactersSelectionView(obs: .init(selectedNames: observer.selectedNames))
                    .preferredColorScheme(.dark)
                    .overlay(alignment: .bottom) { restartButton }

            }

        }
    }
    
    @ToolbarContentBuilder
    var toolBarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            TransitionView(transition: .move(edge: .leading), when: observer.pickedState == .touchedOne) {
                Button {
                    observer.selectionRequired = 1
                    nameTip.invalidate(reason: .actionPerformed)
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        pickSheet = .selectionName
                    }
                } label: {
                    VStack {
                        SystemImage(systemName: "person")
                        Text("Names")
                            .appFontStyle(fontwidth: .condensed)
                    }
                }
            }
        }
        
        ToolbarItem(placement: .principal) {
            TransitionView(transition: .move(edge: .top), when: observer.pickedState == .touchedOne) {
                TimerView(observer: .init(timerState: observer.timerState), isButtonEnabled: !observer.touchObservers.isEmpty)
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            TransitionView(transition: .move(edge: .trailing), when: observer.pickedState == .touchedOne, content: {
                Button(action: {
                    countTip.invalidate(reason: .actionPerformed)
                    observer.closeCountTip = 1
                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        pickSheet = .selectionCount
                    }
                    
                }, label: {
                    if observer.selectionRequired > 1 {
                        Text("\(observer.selectionRequired)")
                            .appFontStyle(fontwidth: .compressed)
                            .scaleEffect(0.8)
                            .background {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 20, height: 20)
                            }
                            .scaleEffect(2.0)
                            .padding(.trailing)
                        
                    } else {
                        VStack {
                            SystemImage(systemName: "plus")
                            Text("Taps")
                                .appFontStyle(fontwidth: .condensed)
                        }
                    }
                })
            })
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
           Rectangle()
                .fill(Color.black)
            TransitionView(transition: .scale, when: observer.selectionType == .taps) {
                Group {
                    if observer.selectionRequired > 1 {
                        ForEach(observer.getMultiplePicked()) {
                            TouchView(observer: $0)
                        }
                        .scaleEffect(0.7)
                    } else {
                        TouchView(observer: observer.getPicked())
                    }
                }
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
        if observer.pickedState == .idle {
            VStack {
                Text("Whoever is participating,")
                Text("tap the screen")
            }
            .onTapGesture {
                observer.pickedState = .touchedOne
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
            .keyframeAnimator(initialValue: TouchViewAnim(scale: 1, rotation: .zero),
                              trigger: observer.animState) { view, value in
                view
                    .scaleEffect(value.scale)
                    .rotationEffect(value.rotation)
            } keyframes: { value in
                KeyframeTrack(\.scale) {
                    CubicKeyframe(observer.animState == .expanded ? 0.6 :
                                    observer.animState == .center ? 0.0 :
                                    1, duration: 0.4)
                }
                KeyframeTrack(\.rotation) {
                    CubicKeyframe(observer.animState == .rotating ? Angle(radians: .pi) : .zero, duration: 1.0)
                }
            }
            
        }
        .overlay(alignment: .bottom) {
            if observer.canShowRemoveTooltip {
                TipView(removeTip)
                    .padding()
            }
        }
    }
    
    var restartButton: some View {
        Button {
            observer.restart()
        } label: {
            Text("RESTART")
                .bold()
                .appFontStyle()
        }
        .padding(.vertical)
    }
    
    
}

extension View  {
    func appFontStyle(fontwidth: Font.Width = .expanded, fontWeight: Font.Weight = .bold) -> some View  {
        self
            .fontWidth(fontwidth)
            .fontDesign(.monospaced)
            .fontWeight(fontWeight)
            .foregroundStyle(.white)
    }
}

#Preview {
    PickView(observer: .init())
}

