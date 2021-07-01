//
//  PrintFunctions.swift
//  Nomad-App
//
//  Created by Yu Ishii on 2020/08/05.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//

import Foundation

public func print(_ items: Any..., separator: String = "", terminator: String = "\n") {
    #if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(output, terminator: terminator)
    #endif
}

public func debugPrint(_ items: Any..., separator: String = "", terminator: String = "\n") {
    #if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.debugPrint(output, terminator: terminator)
    #endif
}
