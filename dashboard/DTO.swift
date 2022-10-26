//
//  DTO.swift
//  dashboard
//
//  Created by Luca Georges Francois on 19/10/2022.
//

import Foundation

enum Action: String, Codable {
    case poweron = "poweron"
    case poweroff = "poweroff"
}

struct PerformInstanceActionData: Codable {
    let action: Action
}
