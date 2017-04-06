//
//  CodeGenerator.swift
//  Jocelyn Decipher Code
//
//  Created by 钟立 on 16/7/20.
//  Copyright © 2016年 钟立. All rights reserved.
//

import Foundation

class CodeGenerator {
    fileprivate var code: Int;
    fileprivate var win: Bool;
    var count: Int;
    
    init() {
        win = false
        count = 10
        code = Int(arc4random()%10000)
    }
    
    func generate() {
        win = false
        count = 10
        code = Int(arc4random()%10000)
    }
    
    func returnCode() -> String {
        if code < 1000 {
            return "0" + String(code)
        } else {
            return String(code)
        }
    }
    
    func checkWin() -> Bool {
        return win
    }
    
    func checkGuess(_ guess: String) -> String {
        count -= 1
        
        guard guess.characters.count == 4 else {
            return "Please enter 4-digit number from 0000 to 9999\n"
        }
        guard let guessNumber: Int = Int(guess) else {
            return "Please enter 4-digit number from 0000 to 9999\n"
        }
        
        var correctNumberAndPosition = 0
        var correctNumberOnly = 0
        
        var tempDigits = numberToDigits(code)
        var guessDigits = numberToDigits(guessNumber)
        
        for index in 0..<4 {
            if guessDigits[index] == tempDigits[index] {
                correctNumberAndPosition += 1
                tempDigits[index] = 10
                guessDigits[index] = 11
            }
        }
        
        for i in 0..<4 {
            for j in 0..<4 {
                if guessDigits[j] == tempDigits[i] {
                    correctNumberOnly += 1
                    tempDigits[i] = 10
                    guessDigits[j] = 11
                }
            }
        }
        
        if correctNumberAndPosition == 4 {
            win = true
            return "\nAbsolutely right!! The code is \(returnCode()). You've successfully broken the code and now you can take out the food for Tommy from the fridge :)\n"
        } else if count > 0{
            return "[\(guess)]  \(correctNumberAndPosition) number with correct value and position\n     \(correctNumberOnly) number with correct value but wrong position\n"
        } else {
            return "\nSorry, you ran out of your chances before deciphering the code(\(returnCode())). It seems the fridge door can't be opened now and maybe you could buy some food for Tommy instead.\n"
        }
        
    }
    
    fileprivate func numberToDigits(_ number: Int) -> Array<Int> {
        let digits:Array<Int> = [number/1000, (number%1000)/100, (number%100)/10, number%10]
        return digits
    }

    
}
