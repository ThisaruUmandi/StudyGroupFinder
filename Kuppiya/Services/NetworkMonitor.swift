//
//  NetworkMonitor.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                print("Network: \(path.status == .satisfied ? "Online" : "Offline")")
            }
        }
        monitor.start(queue: queue)
    }
}
