//
//  NetworkStatus.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 9/10/24.
//

import SwiftUI
import Network

@Observable
@MainActor
final class NetworkStatus {
    var isConnected = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkStatus")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
