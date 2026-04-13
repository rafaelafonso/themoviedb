//
//  MockMovieService.swift
//  TheMovieDBTests
//

import Foundation
@testable import TheMovieDB

final class MockMovieService: MovieServiceProtocol, @unchecked Sendable {
    var moviesToReturn: Movies?
    var genresToReturn: [Genre]?
    var movieCreditsToReturn: MovieCredits?
    var errorToThrow: Error?

    func fetchMovies(page: Int) async throws -> Movies {
        if let error = errorToThrow { throw error }
        return moviesToReturn!
    }

    func fetchGenres() async throws -> [Genre] {
        if let error = errorToThrow { throw error }
        return genresToReturn!
    }

    func fetchMovieDetails(id: Int) async throws -> Movie {
        if let error = errorToThrow { throw error }
        return moviesToReturn!.results.first(where: { $0.id == id })!
    }

    func fetchMovieCredits(id: Int) async throws -> MovieCredits {
        if let error = errorToThrow { throw error }
        return movieCreditsToReturn!
    }
}
