//
//  NetworkManager.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 4/10/24.
//

import Foundation
import os

protocol NetworkManaging: Sendable {
    func getRequest(_ endpoint: MovieEndpoint, params: [String: CustomStringConvertible]) async throws -> Data
}

extension NetworkManaging {
    func getRequest(_ endpoint: MovieEndpoint) async throws -> Data {
        try await getRequest(endpoint, params: [:])
    }
}

final class NetworkManager: NetworkManaging {
    static let shared = NetworkManager()

    private let baseURLString = "https://api.themoviedb.org/3"
    private let session: URLSession
    private let logger = Logger(subsystem: "com.themoviedb", category: "Network")

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getRequest(_ endpoint: MovieEndpoint, params: [String: CustomStringConvertible] = [:]) async throws -> Data {
        let urlString = baseURLString + endpoint.apiEndpoint()

        guard let baseURL = URL(string: urlString),
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw URLError(.badURL)
        }

        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value.description) }
        if let apiKey = ApiEnvironment.apiKey {
            components.queryItems?.append(URLQueryItem(name: "api_key", value: apiKey))
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        logger.debug("Request: \(url.absoluteString, privacy: .private)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            logger.error("HTTP \(httpResponse.statusCode) for \(endpoint.apiEndpoint())")
            throw URLError(.badServerResponse)
        }

        logger.debug("Success: \(endpoint.apiEndpoint())")
        return data
    }
}
