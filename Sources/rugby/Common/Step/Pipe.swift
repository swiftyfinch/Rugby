//
//  Pipe.swift
//  
//
//  Created by Vyacheslav Khorkov on 04.04.2021.
//

/// Shortcut for Void()
let none: Void = ()

/// Pipe one func to another without call
func |<Input, Output0, Output1>(
    _ lhs: @escaping (Input) throws -> Output0,
    _ rhs: @escaping (Output0) throws -> Output1
) -> (Input) throws -> Output1 {
    { try rhs(lhs($0)) }
}
