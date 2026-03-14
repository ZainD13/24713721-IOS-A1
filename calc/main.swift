//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import Foundation

var args = ProcessInfo.processInfo.arguments
args.removeFirst() // remove the name of the program

var numbers: [Int] = []
var operators: [String] = []

for (index, value) in args.enumerated() {
    if index.isMultiple(of: 2) {
        // even index = number
        if let number = Int(value) {
            numbers.append(number)
        } else {
            // number must be valid
            fputs("Invalid number at position \(index): '\(value)'\n", stderr)
            exit(EXIT_FAILURE)
        }
    } else {
        // odd index = operator
        switch value {
        case "+", "-", "*", "x", "X", "/", "%":
            operators.append(value)
        default:
            // operator must be recognized
            fputs("Unknown operator at position \(index): '\(value)'\n", stderr)
            exit(EXIT_FAILURE)
        }
    }
}

if numbers.isEmpty {
    // list cannot be empty
    fputs("No input provided.\n", stderr)
    exit(EXIT_FAILURE)
} else if operators.count != numbers.count - 1 {
    // ensure operators and numbers align
    fputs("Mismatched input: expected \(numbers.count - 1) operators, got \(operators.count).\n", stderr)
    exit(EXIT_FAILURE)
} else {
    // handle multiplication, division, and modulo first
    var collapsedNumbers: [Int] = [numbers[0]]
    var collapsedOperators: [String] = []

    for (i, op) in operators.enumerated() {
        let rhs = numbers[i + 1]
        switch op {
        case "*", "x", "X":
            let lhs = collapsedNumbers.removeLast()
            collapsedNumbers.append(lhs * rhs)
        case "/":
            if rhs == 0 {
                print("Error: division by zero.")
                exit(EXIT_FAILURE)
            }
            let lhs = collapsedNumbers.removeLast()
            collapsedNumbers.append(lhs / rhs)
        case "%":
            if rhs == 0 {
                print("Error: modulo by zero.")
                exit(EXIT_FAILURE)
            }
            let lhs = collapsedNumbers.removeLast()
            collapsedNumbers.append(lhs % rhs)
        case "+", "-":
            // carry over low-precedence operators and next number
            collapsedOperators.append(op)
            collapsedNumbers.append(rhs)
        default:
            print("Unknown operator: \(op)")
            exit(EXIT_FAILURE)
        }
    }

    // handle subtraction adn addition
    var result = collapsedNumbers[0]
    for (i, op) in collapsedOperators.enumerated() {
        let rhs = collapsedNumbers[i + 1]
        switch op {
        case "+":
            result += rhs
        case "-":
            result -= rhs
        default:
            print("Unknown operator in second pass: \(op)")
            exit(EXIT_FAILURE)
        }
    }

    print(result)
}
