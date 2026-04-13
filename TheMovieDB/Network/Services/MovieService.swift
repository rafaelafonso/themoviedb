//
//  MovieService.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 4/10/24.
//

import Foundation

protocol MovieServiceProtocol: Sendable {
    func fetchGenres() async throws -> [Genre]
    func fetchMovies(page: Int) async throws -> Movies
    func fetchMovieDetails(id: Int) async throws -> Movie
    func fetchMovieCredits(id: Int) async throws -> MovieCredits
}

struct MovieService: MovieServiceProtocol {

    private let networkManager: NetworkManaging

    init(networkManager: NetworkManaging = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func fetchGenres() async throws -> [Genre] {
        let data = try await networkManager.getRequest(.fetchGenres)
        let genres = try JSONDecoder().decode(Genres.self, from: data)
        return genres.genres
    }

    func fetchMovies(page: Int) async throws -> Movies {
        let data = try await networkManager.getRequest(.fetchPopularMovies, params: ["page": page])
        return try JSONDecoder().decode(Movies.self, from: data)
    }

    func fetchMovieDetails(id: Int) async throws -> Movie {
        let data = try await networkManager.getRequest(.fetchMovie(id: id))
        return try JSONDecoder().decode(Movie.self, from: data)
    }

    func fetchMovieCredits(id: Int) async throws -> MovieCredits {
        let data = try await networkManager.getRequest(.fetchMovieCredits(id: id))
        return try JSONDecoder().decode(MovieCredits.self, from: data)
    }
}
