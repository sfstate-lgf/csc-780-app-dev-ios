//
//  InstanceDetails.swift
//  dashboard
//
//  Created by Luca Georges Francois on 18/10/2022.
//

import Foundation
import SwiftUI

struct ServerAttribute: Identifiable {
    let id = UUID()
    let icon: String?
    let key: String
    let value: String?
    
    var items: [ServerAttribute]?
}

struct InstanceDetails: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State private var isPresentingSuppressionConfirmation: Bool = false
    
    @State private var isShowingActionError: Bool = false
    @State private var actionError: ErrorWithContext? = Optional.none
    
    let service = ScalewayService()

    let id: String
    let name: String
    let type: String
    let state: ServerState
    let zone: Zone
    let publicIP: String
    let volumes: [String: Volume]
    let items: [ServerAttribute]
    
    init(id: String, name: String, type: String, state: ServerState, zone: Zone, publicIP: String, volumes: [String: Volume]) {
        self.id = id
        self.name = name
        self.type = type
        self.state = state
        self.zone = zone
        self.publicIP = publicIP
        self.volumes = volumes
        self.items = [
            ServerAttribute(icon: "filemenu.and.selection", key: "Name", value: name),
            ServerAttribute(icon: "circle.hexagongrid.circle", key: "Type", value: type),
            ServerAttribute(icon: "bolt.horizontal.circle", key: "State", value: state.rawValue),
            ServerAttribute(icon: "externaldrive", key: "Storage", value: Optional.none, items: volumes.map { (vKey: String, volume: Volume) in
                return ServerAttribute(icon: Optional.none, key: volume.name, value: "\(volume.size / 1_000_000_000) GB")
            }),
            ServerAttribute(icon: "network", key: "Public IP", value: publicIP),
            ServerAttribute(icon: "location.north.circle", key: "Zone", value: "fr-par-1")
        ]
    }

    var body: some View {
        VStack {
            List(items, children: \.items) { row in
                if let unwrappedIcon = row.icon {
                    Image(systemName: unwrappedIcon)
                }
                Text(row.key)
                    .bold()
                
                if let unwrappedValue = row.value {
                    Spacer()
                    Text(unwrappedValue)
                }
            }
            Button("Power \(state == ServerState.stopped ? "on" : "off") this instance", role: (state == ServerState.stopped ? .none : .destructive)) {
                isPresentingSuppressionConfirmation = true
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .confirmationDialog("Are you sure?", isPresented: $isPresentingSuppressionConfirmation) {
                Button("Yes, power \(state == ServerState.stopped ? "on" : "off") this instance", role: .destructive, action: {
                    service.performActionOnServer(zone: zone, serverID: id, action: (state == ServerState.stopped ? Action.poweron : Action.poweroff)) { error in
                        if let error = error {
                            self.isShowingActionError = true
                            self.actionError = error
                        } else {
                            self.isShowingActionError = false
                            self.actionError = Optional.none
                        }
                    }
                    self.mode.wrappedValue.dismiss()
                })
            } message: {
                Text("\(state == ServerState.stopped ? "Warning, this instance is about to be powered on. It will consume resources and therefore use your credit." : "Warning! Powering off or rebooting an Instance is similar to pulling the electrical plug on a running computer, which can cause data corruption. You need to shut down the OS first: login to your Instance as root and execute the halt command.")")
            }
            .padding(.top)
        }
    }
}
