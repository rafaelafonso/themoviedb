//
//  MockNetworkManager.swift
//  TheMovieDBTests
//

import Foundation
@testable import TheMovieDB

final class MockNetworkManager: NetworkManaging, @unchecked Sendable {
    var mockData: Data = Data()
    var mockError: Error?

    func getRequest(_ endpoint: MovieEndpoint, params: [String: CustomStringConvertible]) async throws -> Data {
        if let error = mockError {
            throw error
        }
        return mockData
    }
}
