//
//  LevelProtocol.swift
//  SING
//
//  Created by Vladimir Em on 21.03.2022.
//

import Foundation
import UIKit
protocol Test {
    var notes: [Note] { get set }
    var soundName: String { get }
    var levelName: String { get }
    var name: String { get }
}
struct Dimensions {
    static let maxFrequency: Float = 1000.0
    static let resolution: Float = 0.02
    static let minAmplitude: Double = 0.01
    static let noteBarHeight: Float = 10
    static let width = Float(UIScreen.main.bounds.width)
    static let height = Float(UIScreen.main.bounds.height)
    static let scale = height / maxFrequency
    static let timeAccuracy: Float = 50
}

struct MusicConst {
    static let noteFrequencies = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    static let noteNamesWithSharps = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    static let noteNamesWithFlats = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
}

enum Score: Int {
    case bad
    case good
    case excellent
    
    var score: Int {
        switch self.score {
        case 0..<20:
            return 0
        case 5..<100:
            return 1
        case _ where self.score > 100:
            return 2
        default:
            return 3
        }
    }
}


struct Note {
    var name: String = ""
    var distance: Float = 0.0
    var frequency: Float = 0.0
}
