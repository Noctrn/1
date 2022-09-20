//
//  ExecriseConverion.swift
//  SING
//
//  Created by Vladimir Em on 02.07.2022.
//

import Foundation
func convertWithHalfSteps(inputFile: Test) -> [Double] {
    var outputFile = [Double]()
    for i in 0...12{
        for note in inputFile.notes{
            
            for _ in 1...Int(note.distance/0.2){
                if note.name != "_"{
                    outputFile.append(notesScale[note.name]! + Double(i))
                }
                else{
                    outputFile.append(0)
                }
            }
            
        }
    }
    return outputFile
}
