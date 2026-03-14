//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//
import Foundation

var args = ProcessInfo.processInfo.arguments
args.removeFirst()

let calculator = Calculator()

do {
    let result = try calculator.calculate(args)
    print(result)
} catch let error as CalculatorError {
    fputs(error.message + "\n", stderr)
    exit(EXIT_FAILURE)
} catch {
    fputs("Unknown error\n", stderr)
    exit(EXIT_FAILURE)
}
