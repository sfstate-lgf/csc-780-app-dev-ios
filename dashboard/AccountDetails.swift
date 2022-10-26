//
//  AccountDetails.swift
//  dashboard
//
//  Created by Luca Georges Francois on 18/10/2022.
//

// TODO: Ask for biometrics before updating API-KEY: https://www.raywenderlich.com/11496196-how-to-secure-ios-user-data-keychain-services-and-biometrics-with-swiftui

import Foundation
import SwiftUI
import Security

struct AccountDetails: View {
    // Used to store the API Key.
    @State private var newAPIKey: String = ""
    
    // Used to select the zone.
    @State private var selectedZone: Zone = Zone.fr_par_1
    private let zones = [
        Zone.fr_par_1,
        Zone.fr_par_2,
        Zone.fr_par_3,
        Zone.nl_ams_1,
        Zone.po_waw_1,
    ]
    
    @State private var isShowingSavingError: Bool = false
    @State private var savingError: ErrorWithContext? = Optional.none
    
    init() {
        do {
            let kc_api_key_raw = try KeychainWrapper.readPassword(service: "service-d7f126a0-7a05-4725-a6dc-0f7522e15760", account: "account-488b2f7a-9de9-4124-b992-c7f31844fe49")
            let kc_api_key = String(decoding: kc_api_key_raw, as: UTF8.self)
            
            _newAPIKey = State(initialValue: kc_api_key)
        } catch {
            self.isShowingSavingError = true
            self.savingError = ErrorWithContext(context: "Failed to save preferences.", description: "Could not read API Key from Apple Keychain.")
        }
        
        let rawPreferredZone = UserDefaults.standard.string(forKey: "scw-preferred-zone") ?? Zone.fr_par_1.rawValue
        let preferredZone: Zone = Zone(rawValue: rawPreferredZone) ?? Zone.fr_par_1
        _selectedZone = State(initialValue: preferredZone)
    }
    
    // Used when showing the confirmation pop-up.
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @State private var isPresentingSavingConfirmation: Bool = false
    
    var body: some View {
        List {
            SecureField("Enter your Scaleway API Key", text: $newAPIKey)
            Picker("Select a preferred zone", selection: $selectedZone) {
                ForEach(zones, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.menu)
        }
        Button("Save", role: .none) {
            isPresentingSavingConfirmation = true
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .confirmationDialog("Are you sure?", isPresented: $isPresentingSavingConfirmation) {
            Button("Yes, save my new preferences", role: .none, action: {
                // Save API Key to KC.
                if let data = newAPIKey.data(using: .utf8) {
                    do {
                        try KeychainWrapper.save(password: data, service: "service-d7f126a0-7a05-4725-a6dc-0f7522e15760", account: "account-488b2f7a-9de9-4124-b992-c7f31844fe49")
                    } catch {
                        self.isShowingSavingError = true
                        self.savingError = ErrorWithContext(context: "Failed to save preferences.", description: "Could not save API Key in Apple Keychain.")
                        return
                    }
                } else {
                    self.isShowingSavingError = true
                    self.savingError = ErrorWithContext(context: "Failed to save preferences.", description: "The provided API Key is not encoded in UTF-8.")
                    return
                }
                
                UserDefaults.standard.set(self.selectedZone.rawValue, forKey: "scw-preferred-zone")

                self.isShowingSavingError = false
                self.savingError = Optional.none
                self.mode.wrappedValue.dismiss()
            })
        } message: {
            Text("Warning! Any change related to your preferences requires a re-submission of your API Key.")
        }
        .padding()
        .navigationTitle("Your account 🤖")
    }
}
