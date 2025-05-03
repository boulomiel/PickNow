//
//  CharactersSelectionView.swift
//  PickPick
//
//  Created by Ruben Mimoun on 02/05/2025.
//

import SwiftUI

struct CharactersSelectionView: View {

    @State var obs: Obs

    init(obs: Obs) {
        self.obs = obs
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let seconds = Calendar.current.dateComponents([.second], from: obs.startDate, to: timeline.date)
                if seconds.second! >= 2 {
                    if obs.freezeDate == nil {
                        obs.freezeDate = .now
                    }
                    drawSelectedName(timeline, graphicContext: context, in: size)
                } else {
                    drawFlyingLetters(timeline, graphicContext: context, in: size)
                }
            }
            .appFontStyle()
        }
    }
    
    func drawSelectedName(_ timeline: TimelineViewDefaultContext, graphicContext: GraphicsContext, in size: CGSize) {
        guard let freezeDate = obs.freezeDate else { return }
        let width = size.width
        let height = size.height
        var usedIndices = Set<Int>()
        let selectedLetters = Array(obs.selectedName).map { String($0) }
        let spacing: CGFloat = 30
        let startX = width / 2 - spacing * CGFloat(selectedLetters.count - 1) / 2
        let centerY = height / 2
        
        let animationProgress = min(1.0, timeline.date.timeIntervalSince(freezeDate)) // 0.0 to 1.0

        for (i, targetLetter) in selectedLetters.enumerated() {
            if let match = obs.flyingLetterPosition.first(where: { !usedIndices.contains($0.index) && $0.letter == targetLetter }) {
                usedIndices.insert(match.index)

                let finalX = startX + CGFloat(i) * spacing
                let finalPosition = CGPoint(x: finalX, y: centerY)

                let interpolatedX = match.x + (finalPosition.x - match.x) * CGFloat(animationProgress)
                let interpolatedY = match.y + (finalPosition.y - match.y) * CGFloat(animationProgress)
                

                let text = Text(match.letter)
                    .font(.system(size: 35, weight: .bold))
                                            
                graphicContext.draw(text, at: CGPoint(x: interpolatedX, y: interpolatedY))
            }
        }
    }
    
    func drawFlyingLetters(_ timeline: TimelineViewDefaultContext, graphicContext: GraphicsContext, in size: CGSize) {
        let time = timeline.date.timeIntervalSinceReferenceDate
        let width = size.width
        let height = size.height
        
        for (index, letter) in obs.letters.enumerated() {
            let speed = Double(index + 1) * 0.1
            let phaseX = Double(index) * 0.5
            let phaseY = Double(index) * 0.8

            // Smooth paths across screen using sin and cos
            let x = width * (0.5 + 0.4 * CGFloat(sin(time * speed + phaseX)))
            let y = height * (0.5 + 0.4 * CGFloat(cos(time * speed + phaseY)))

            let text = Text(String(letter))
                .font(.system(size: 24, weight: .bold))

            graphicContext.draw(text, at: CGPoint(x: x, y: y))
            obs.addLetter(letter: .init(index: index, letter: letter, x: x, y: y))
        }
    }
    
    @Observable
    class Obs {
        
        @ObservationIgnored
        let letters: [String]
        @ObservationIgnored
        let selectedNames: [String]
        @ObservationIgnored
        let selectedName: String
        
        var startDate: Date
        var freezeDate: Date?
        var flyingLetterPosition = [FlyingLetter]()
        
        init(selectedNames: [String]) {
            var letters = [String]()
            selectedNames.forEach { name in
                name.forEach { c in
                    letters.append("\(c)")
                }
            }
            self.startDate = .now
            self.letters = letters
            self.selectedNames = selectedNames
            selectedName = selectedNames.randomElement()!
            letters.enumerated().forEach { index, l in
                flyingLetterPosition.append(.init(index: index, letter: l, x: 0, y: 0))
            }
        }
        
        func addLetter(letter: FlyingLetter) {
            guard !flyingLetterPosition.isEmpty else { return }
            if flyingLetterPosition.indices.contains(letter.index) {
                flyingLetterPosition[letter.index] = letter
            }
        }
    }
}

struct FlyingLetter: Hashable {
    let index: Int
    let letter: String
    let x: CGFloat
    let y: CGFloat
    
    var point: CGPoint {
        .init(x: x, y: y)
    }
}


#Preview {
    CharactersSelectionView(obs: .init(selectedNames: ["Phil", "Mack", "Jenna", "Patrick"]))
        .preferredColorScheme(.dark)
}
