//
//  Preferences.swift
//  dashboard
//
//  Created by Luca Georges Francois on 18/10/2022.
//

import Foundation

struct Preferences {
    var preferredZone = Zone.fr_par_1
}

extension Preferences : Equatable {
    static func == (lhs: Preferences, rhs: Preferences) -> Bool {
        return lhs.preferredZone == rhs.preferredZone
    }
}
