//
//  Calculator.swift
//  calc
//
//  Created by Damaq Mohd Zain on 14/3/2026.
//  Copyright © 2026 UTS. All rights reserved.
//

import Foundation

// custom errors used by the calculator to report invalid input or runtime calculation problems.
enum CalculatorError: Error {
    case invalidNumber(position: Int, value: String)      // input is not a valid number
    case unknownOperator(position: Int, value: String)    // operator is unknown and not supported
    case noInput                                          // no arguments are provided
    case mismatchedInput(expected: Int, got: Int)         // numbers do not align with operators
    case divisionByZero                                   // division by 0 is not allowed
    case moduloByZero                                     // modulo by 0 is not allowed

    // converts erros into messages
    var message: String {
        switch self {
        case .invalidNumber(let pos, let val):
            return "Invalid number at position \(pos): '\(val)'"
        case .unknownOperator(let pos, let val):
            return "Unknown operator at position \(pos): '\(val)'"
        case .noInput:
            return "No input provided."
        case .mismatchedInput(let expected, let got):
            return "Mismatched input: expected \(expected) operators, got \(got)."
        case .divisionByZero:
            return "Error: division by zero."
        case .moduloByZero:
            return "Error: modulo by zero."
        }
    }
}

// main calculator class
class Calculator {

    // parses arguments and evaluates expression
    func calculate(_ args: [String]) throws -> Int {
        let (numbers, operators) = try parseInput(args)
        return try evaluate(numbers: numbers, operators: operators)
    }
    
    // seperates arguments into numbers and operators
    private func parseInput(_ args: [String]) throws -> ([Int], [String]) {
        var numbers: [Int] = []
        var operators: [String] = []

        for (index, value) in args.enumerated() {
            // even index = number
            if index.isMultiple(of: 2) {
                guard let number = Int(value) else {
                    throw CalculatorError.invalidNumber(position: index, value: value)
                }

                numbers.append(number)
            } else {

                // odd index = operator
                switch value {
                case "+", "-", "x", "/", "%":
                    operators.append(value)
                default:
                    throw CalculatorError.unknownOperator(position: index, value: value)
                }
            }
        }
        
        // minimum of one number is to be provided
        if numbers.isEmpty {
            throw CalculatorError.noInput
        }

        // make sure numbers and operators align
        if operators.count != numbers.count - 1 {
            throw CalculatorError.mismatchedInput(
                expected: numbers.count - 1,
                got: operators.count
            )
        }

        return (numbers, operators)
    }

    // evaluates expressions by doing 2 passes
    private func evaluate(numbers: [Int], operators: [String]) throws -> Int {
        // first pass deals with high precedence operators
        // collapsed numbers and operators store intermediate expression
        var collapsedNumbers: [Int] = [numbers[0]]
        var collapsedOperators: [String] = []

        for (i, op) in operators.enumerated() {

            let rhs = numbers[i + 1]

            switch op {

            case "x":
                let lhs = collapsedNumbers.removeLast()
                collapsedNumbers.append(lhs * rhs)
            case "/":
                if rhs == 0 { throw CalculatorError.divisionByZero }
                let lhs = collapsedNumbers.removeLast()
                collapsedNumbers.append(lhs / rhs)
            case "%":
                if rhs == 0 { throw CalculatorError.moduloByZero }
                let lhs = collapsedNumbers.removeLast()
                collapsedNumbers.append(lhs % rhs)
            // low precedence operators carry over to the second pass
            case "+", "-":
                collapsedOperators.append(op)
                collapsedNumbers.append(rhs)
            default:
                throw CalculatorError.unknownOperator(position: -1, value: op)
            }
        }

        // second pass takes care of low precedence operators
        var result = collapsedNumbers[0]

        for (i, op) in collapsedOperators.enumerated() {
            let rhs = collapsedNumbers[i + 1]

            switch op {
            case "+":
                result += rhs
            case "-":
                result -= rhs
            default:
                throw CalculatorError.unknownOperator(position: -1, value: op)
            }
        }

        return result
    }
}
