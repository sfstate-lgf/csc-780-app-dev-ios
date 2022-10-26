//
//  ContentView.swift
//  dashboard
//
//  Created by Luca Georges Francois on 18/10/2022.
//

import SwiftUI
import SkeletonUI
import AlertToast

struct ContentView: View {
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    // Color theme management.
    @State private var isDarkMode: Bool = false
    
    // Data related to Scaleway.
    @State private var servers: [Server] = []
    
    @State private var isLoading: Bool = false
    
    @State private var isShowingRefreshingError: Bool = false
    @State private var refreshingError: ErrorWithContext? = Optional.none
        
    let service = ScalewayService()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            NavigationView {
                SkeletonList(with: servers, quantity: (self.isLoading ? Int.random(in: 1...10) : 0)) { loading, server in
                    Instance(id: server?.id ?? "", loading: loading, name: server?.name ?? "", type: server?.commercial_type ?? "", state: server?.state ?? ServerState.stopping, zone: server?.zone ?? Zone.fr_par_1, publicIP: server?.public_ip.address ?? "", volumes: server?.volumes ?? [String: Volume]())
                        .listRowSeparator(.hidden)
                }
                .refreshable {
                    refreshServers()
                }
                .animation(.spring(), value: servers)
                .navigationTitle("Your servers 🚀")
                .toolbar {
                    ToolbarItem(placement:.navigationBarLeading) {
                        Button(action: {
                            self.isDarkMode = !self.isDarkMode
                        }) {
                            Label("DarkMode", systemImage: (self.isDarkMode ? "sun.and.horizon.circle" : "moon.haze"))
                        }
                    }
                    ToolbarItem(placement:.navigationBarTrailing) {
                        NavigationLink(destination: AccountDetails()) {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                }
                .onAppear {
                    self.servers = []
                    refreshServers()
                }
            }
        }
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            Color.white
                .frame(height: 0)
                .background(Material.ultraThin)
        }
        .preferredColorScheme(self.isDarkMode ? .dark : .light)
        .onReceive(timer) { _ in
            refreshServers()
        }
        .toast(isPresenting: $isShowingRefreshingError) {
            AlertToast(displayMode: .banner(.pop), type: .error(.black), title: refreshingError?.context, subTitle: refreshingError?.description, style: AlertToast.AlertStyle.style(backgroundColor: .red))
        }
    }
    
    func refreshServers() {
        self.isLoading = true
        service.getServers { servers, error in
            if let error = error {
                self.refreshingError = error
                self.isShowingRefreshingError = true
            } else {
                self.servers = servers
                self.isShowingRefreshingError = false
                self.refreshingError = Optional.none
            }
            self.isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
