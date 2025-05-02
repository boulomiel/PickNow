//
//  TouchView.swift
//  PickPick
//
//  Created by Ruben Mimoun on 01/02/2024.
//

import SwiftUI


func triggerVibration(_ type: UINotificationFeedbackGenerator.FeedbackType = .warning) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}

struct TouchView: View {
    
    private let observer: TouchObserver
    @State var showRemoveMark: Bool
    
    var color: Color {
        observer.color
    }
    
    init(observer: TouchObserver, showRemoveMark: Bool = false) {
        self.observer = observer
        self._showRemoveMark = .init(initialValue: showRemoveMark)
    }
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 70, height: 70)
            .overlay {
                Circle()
                    .trim(from: 0, to: observer.trimValue)
                    .stroke(color, lineWidth: 2.0)
                    .frame(width: 80, height: 80)
            }
            .overlay { removeMark }
            .onAppear(perform: {
                observer.trimValue = 1.0
                observer.scale = 1
            })
            .scaleEffect(observer.scale)
            .animation(.easeInOut(duration: 1.0), value: observer.trimValue)
            .animation(.easeInOut(duration: 1.0), value: observer.scale)
            .animation(.easeInOut(duration: 1.0), value: observer.position)
            .animation(.snappy, value: showRemoveMark)
            .shadow(color: color, radius: 20)
            .coordinateSpace(name: "circle")
            .position(observer.position)
            .gesture(removalGestures)
    }
    
    var removalGestures: some Gesture {
        LongPressGesture()
            .onEnded({ state in
                showRemoveMark = state
                triggerVibration(.success)
            })
            .simultaneously(with: TapGesture(count: 2)
                .onEnded({ _ in
                    showRemoveMark = false
                    triggerVibration(.success)
                }))
    }
    
    @ViewBuilder
    var removeMark: some View {
        if showRemoveMark {
            GeometryReader { geo in
                let frame = geo.frame(in: .named("circle"))
                Button {
                    observer.remove()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
                .frame(width: 30, height: 30)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(observer.color.opacity(0.5))
                }
                .transition(.opacity)
                .position(x: frame.maxX, y: 5)
            }
        }
    }
    
    
    @Observable
    final class TouchObserver: Identifiable {
        
        var position: CGPoint
        
        var color: Color = .black
        
        private var lastColor: Color?
        var trimValue: Double
        var scale: Double = 0.0
        let id: UUID
        let onRemove: (CGPoint) -> Void
        
        init(position: CGPoint,
             onRemove: @escaping (CGPoint) -> Void,
             lastColor: Color?
        ) {
            self.id = UUID()
            self.trimValue =  0.0
            self.lastColor = lastColor
            self.position = position
            self.onRemove = onRemove
            self.color = generateColor()
        }
        
        func remove() {
            self.onRemove(position)
        }
        
        private func generateColor() -> Color {
            var newColor: Color
              repeat {
                  newColor = Color.randomColor
              } while !isColorDifferentEnough(from: lastColor, to: newColor)
              
              return newColor
        }
        
        private func isColorDifferentEnough(from oldColor: Color?, to newColor: Color) -> Bool {
            guard let oldColor = oldColor else { return true }
            
            // Convert the colors to RGB components
            let (oldRed, oldGreen, oldBlue, _) = oldColor.components()
            let (newRed, newGreen, newBlue, _) = newColor.components()
            
            // Calculate Euclidean distance in RGB space
            let colorDistance = sqrt(pow(oldRed - newRed, 2) +
                                     pow(oldGreen - newGreen, 2) +
                                     pow(oldBlue - newBlue, 2))
            
            // Set a threshold for color difference, e.g., 0.5
            return colorDistance > 0.5
        }
    }
}

private extension Color {
    // Helper function to get the RGBA components of a Color
    func components() -> (red: Double, green: Double, blue: Double, opacity: Double) {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        return (red: Double(components[0]), green: Double(components[1]), blue: Double(components[2]), opacity: Double(components[3]))
    }
}

private extension Color {
    
    static var randomColor: Color {
        return Color(red: generate(),
                     green: generate(),
                     blue: generate(), opacity: 1)
    }
    
    private static func generate() -> Double {
        let generator = Double.random(in: 0...255)
        return generator/255
    }
}


#Preview {
    GeometryReader(content: { geomtry in
        let frame = geomtry.frame(in: .global)
        TouchView(observer: .init(position:  .init(x: frame.width/2, y: frame.height/2), onRemove: {_ in print("Remove at point sent")}, lastColor: nil))
    })
    .background {
        Color.black
    }
}

#Preview {
    VStack {
        Button {

        } label: {
            GeometryReader { geo in
                let frame = geo.frame(in: .named("Hello"))
                Image(systemName: "xmark")
                    .foregroundStyle(.black)
            }
        }
        .transition(.scale)
    }
    .frame(width: 89, height: 89, alignment: .center)
    .position(x: 100)
    .coordinateSpace(name: "Hello")
}
