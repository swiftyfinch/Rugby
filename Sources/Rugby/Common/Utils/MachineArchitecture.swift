//
//  MachineArchitecture.swift
//  
//
//  Created by mlch911 on 2023/1/23.
//

import Foundation

func machineArchitecture() -> String? {
    var systemInfo = utsname()
    uname(&systemInfo)
    let architecture = withUnsafeBytes(of: &systemInfo.machine) { bufferPointer -> String? in
        let data = Data(bufferPointer)
        if let lastIndex = data.lastIndex(where: { $0 != 0 }) {
            return String(data: data[0...lastIndex], encoding: .utf8)
        } else {
            return String(data: data, encoding: .utf8)
        }
    }
    return architecture
}
