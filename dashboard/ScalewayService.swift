//
//  ScalewayService.swift
//  dashboard
//
//  Created by Luca Georges Francois on 18/10/2022.
//

import Foundation

struct ScalewayService {
    private let baseURL = "https://api.scaleway.com"
    
    func getServers(onCompletion: @escaping ([Server], ErrorWithContext?) -> Void) {
        let errorContext: String = "Failed to get servers."
        
        let rawPreferredZone = UserDefaults.standard.string(forKey: "scw-preferred-zone") ?? Zone.fr_par_1.rawValue
        let preferredZone: Zone = Zone(rawValue: rawPreferredZone) ?? Zone.fr_par_1

        let url = URL(string: baseURL + "/instance/v1/zones/\(preferredZone.rawValue)/servers")
        guard let requestUrl = url else { fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        do {
            let kc_api_key_raw = try KeychainWrapper.readPassword(service: "service-d7f126a0-7a05-4725-a6dc-0f7522e15760", account: "account-488b2f7a-9de9-4124-b992-c7f31844fe49")
            let kc_api_key = String(decoding: kc_api_key_raw, as: UTF8.self)
            
            request.setValue(kc_api_key, forHTTPHeaderField: "X-Auth-Token")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    onCompletion([], ErrorWithContext(context: errorContext, description: error.localizedDescription))
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(response.statusCode)")
                }
                
                guard let data = data else {
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let routesResponse = try decoder.decode(GetServersResponse.self, from: data)
                    
                    onCompletion(routesResponse.servers, Optional.none)
                } catch {
                    onCompletion([], ErrorWithContext(context: errorContext, description: "Could not decode data."))
                }
            }
            task.resume()
        } catch {
            onCompletion([], ErrorWithContext(context: errorContext, description: "Could not read API Key from Apple Keychain."))
        }
    }
    
    func performActionOnServer(zone: Zone, serverID: String, action: Action, onCompletion: @escaping (ErrorWithContext?) -> Void) {
        let errorContext: String = "Failed to perform action on server."

        let url = URL(string: baseURL + "/instance/v1/zones/\(zone.rawValue)/servers/\(serverID)/action")
        guard let requestUrl = url else { fatalError() }
        
        print(requestUrl)
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let performInstanceActionDataModel = PerformInstanceActionData(action: action)
        
        guard let jsonData = try? JSONEncoder().encode(performInstanceActionDataModel) else {
            onCompletion(ErrorWithContext(context: errorContext, description: "Failed to encode data to perform action."))
            return
        }
        request.httpBody = jsonData
        
        do {
            let kc_api_key_raw = try KeychainWrapper.readPassword(service: "service-d7f126a0-7a05-4725-a6dc-0f7522e15760", account: "account-488b2f7a-9de9-4124-b992-c7f31844fe49")
            let kc_api_key = String(decoding: kc_api_key_raw, as: UTF8.self)
            
            request.setValue(kc_api_key, forHTTPHeaderField: "X-Auth-Token")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    onCompletion(ErrorWithContext(context: errorContext, description: error.localizedDescription))
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(response.statusCode)")
                }
                
                guard let _ = data else {
                    onCompletion(ErrorWithContext(context: errorContext, description: "Performing the action returned nothing, which is weird."))
                    return
               }
            }
            task.resume()
        } catch {
            onCompletion(ErrorWithContext(context: errorContext, description: "Could not read API Key from Apple Keychain."))
        }
    }
}
