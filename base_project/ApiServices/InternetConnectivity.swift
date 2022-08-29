//
//  InternetConnectivity.swift
//  base_project
//
//  Created by Pranav Singh on 29/08/22.
//

import Foundation
import Network

class InternetConnectivityViewModel {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "InternetConnectivityMonitor")
    
    var isConnectedToInternet: Bool = false
    
    init() {
        checkConnection()
    }
    
    func checkConnection() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.isConnectedToInternet = true
                } else {
                    self.isConnectedToInternet = false
                }
            }
        }
        monitor.start(queue: queue)
    }
}
