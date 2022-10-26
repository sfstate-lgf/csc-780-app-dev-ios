//
//  ro.swift
//  dashboard
//
//  Created by Luca Georges Francois on 18/10/2022.
//

import Foundation

enum ServerState: String, Codable {
    case running = "running"
    case stopped = "stopped"
    case stopped_in_place = "stopped in place"
    case starting = "starting"
    case stopping = "stopping"
    case locked = "locked"
}

enum Zone: String, Codable {
    case fr_par_1 = "fr-par-1"
    case fr_par_2 = "fr-par-2"
    case fr_par_3 = "fr-par-3"
    case nl_ams_1 = "nl-ams-1"
    case po_waw_1 = "po-waw-1"
}

struct PublicIP: Decodable, Hashable {
    let id: String
    let address: String
}

struct Volume: Decodable, Hashable {
    let id: String
    let name: String
    let size: UInt64
}

struct Server: Decodable, Hashable, Identifiable {
    let id: String
    let name: String
    let organization: String
    let commercial_type: String
    let state: ServerState
    let zone: Zone
    let public_ip: PublicIP
    let volumes: [String: Volume]
}

struct GetServersResponse: Decodable {
    let servers: [Server]
}
