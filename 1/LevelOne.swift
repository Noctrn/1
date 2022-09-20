//
//  Level One.swift
//  SING
//
//  Created by Vladimir Em on 21.03.2022.
//

import Foundation
struct TestOne: Test {
    
    let soundName: String = "1"
    let name: String = "Test Sound 1"
    let levelName: String = "Easy"
    
    var notes: [Note] = [
        
            Note(
                 name: "-",
                 distance: 10,
                 frequency: Float(notesFreqs["-"]!)),
            Note(
                 name: "E3",
                 distance: 10,
                 frequency: Float(notesFreqs["E3"]!)),
                 
            Note(
                 name: "-",
                 distance: 10,
                 frequency: Float(notesFreqs["-"]!)),
        
            Note(
                 name: "G3",
                 distance: 10,
                 frequency: Float(notesFreqs["G3"]!)),
                      
            Note(
                 name: "-",
                 distance: 10,
                 frequency: Float(notesFreqs["-"]!)),
        
            Note(
                 name: "E3",
                 distance: 10,
                 frequency: Float(notesFreqs["E3"]!)),
            Note(
                 name: "-",
                 distance: 10,
                 frequency: Float(notesFreqs["-"]!)),
            
            Note(
                 name: "C3",
                 distance: 20,
                 frequency: Float(notesFreqs["E3"]!)),
]
}
