//
//  Instance.swift
//  dashboard
//
//  Created by Luca Georges Francois on 18/10/2022.
//

import Foundation
import SwiftUI

struct InstanceViewModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(colorScheme == .dark ? Color(red: 27/255, green: 36/255, blue: 48/255) : .white)
            .cornerRadius(15)
    }
}

struct Instance: View, Identifiable, Hashable {
    let id: String
    let loading: Bool
    let name: String
    let type: String
    let state: ServerState
    let zone: Zone
    let publicIP: String
    let volumes: [String: Volume]
    
    private let statusColor: Color
    
    init(id: String, loading: Bool, name: String, type: String, state: ServerState, zone: Zone, publicIP: String, volumes: [String : Volume]) {
        self.id = id
        self.loading = loading
        self.name = name
        self.type = type
        self.state = state
        self.zone = zone
        self.publicIP = publicIP
        self.volumes = volumes
        
        if loading {
            self.statusColor = .gray
        } else {
            self.statusColor = state == ServerState.running ? .green : (state == ServerState.starting ? .orange : .red)
        }
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Group {
                    Image(systemName: "shippingbox")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .padding(.leading, 20)
                    Circle()
                        .fill(self.statusColor)
                        .frame(width: 10)
                        .padding(.leading, 10)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(name)
                            .bold()
                            .lineLimit(1)
                        Text(type)
                            .lineLimit(1)
                    }
                    .skeleton(with: loading)
                    .multiline(lines: 3, scales: [
                        0: Double.random(in: 0.7...1),
                        1: Double.random(in: 0.7...1),
                    ])
                    .animation(type: .pulse())
                    .padding(.leading, 10)
                    Spacer()
                    Image(systemName: "ellipsis")
                        .padding(.trailing, 20)
                }
                .padding([.top, .bottom], 30)
            }
            .modifier(InstanceViewModifier())
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
            .shadow(radius: 3, x: 0, y: 1)
            if !loading {
                NavigationLink(destination: InstanceDetails(id: self.id, name: name, type: type, state: state, zone: zone, publicIP: publicIP, volumes: volumes)) {
                    EmptyView()
                }
                .opacity(0)
            }
        }
        .listRowBackground(Color.clear)
    }
}
