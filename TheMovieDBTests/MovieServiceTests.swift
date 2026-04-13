//
//  MovieServiceTests.swift
//  TheMovieDBTests
//

import Testing
import Foundation
@testable import TheMovieDB

struct MovieServiceTests {

    private func makeService(json: String) -> MovieService {
        let mock = MockNetworkManager()
        mock.mockData = json.data(using: .utf8)!
        return MovieService(networkManager: mock)
    }

    private func makeFailingService() -> MovieService {
        let mock = MockNetworkManager()
        mock.mockError = URLError(.notConnectedToInternet)
        return MovieService(networkManager: mock)
    }

    // MARK: - fetchMovies

    @Test func fetchMoviesReturnsDecodedMovies() async throws {
        let service = makeService(json: """
        {
            "results": [
                {"id": 1, "title": "Movie One", "release_date": "2024-01-01", "overview": "Overview", "genre_ids": [28]}
            ]
        }
        """)

        let movies = try await service.fetchMovies(page: 1)

        #expect(movies.results.count == 1)
        #expect(movies.results[0].title == "Movie One")
    }

    @Test func fetchMoviesThrowsOnNetworkError() async {
        let service = makeFailingService()

        await #expect(throws: URLError.self) {
            _ = try await service.fetchMovies(page: 1)
        }
    }

    @Test func fetchMoviesThrowsOnInvalidJSON() async {
        let service = makeService(json: "{ invalid }")

        await #expect(throws: DecodingError.self) {
            _ = try await service.fetchMovies(page: 1)
        }
    }

    // MARK: - fetchGenres

    @Test func fetchGenresReturnsDecodedGenres() async throws {
        let service = makeService(json: """
        {
            "genres": [
                {"id": 28, "name": "Action"},
                {"id": 35, "name": "Comedy"}
            ]
        }
        """)

        let genres = try await service.fetchGenres()

        #expect(genres.count == 2)
        #expect(genres[0].name == "Action")
    }

    // MARK: - fetchMovieCredits

    @Test func fetchMovieCreditsReturnsDecodedCredits() async throws {
        let service = makeService(json: """
        {
            "id": 1,
            "cast": [{"name": "Actor One"}],
            "crew": [{"name": "Director One", "job": "Director"}]
        }
        """)

        let credits = try await service.fetchMovieCredits(id: 1)

        #expect(credits.cast.count == 1)
        #expect(credits.crew.first?.job == "Director")
    }

    // MARK: - fetchMovieDetails

    @Test func fetchMovieDetailsReturnsDecodedMovie() async throws {
        let service = makeService(json: """
        {
            "id": 42,
            "title": "Detail Movie",
            "release_date": "2024-06-01",
            "overview": "Detailed overview.",
            "genre_ids": [18],
            "vote_average": 8.5,
            "vote_count": 1000
        }
        """)

        let movie = try await service.fetchMovieDetails(id: 42)

        #expect(movie.id == 42)
        #expect(movie.title == "Detail Movie")
        #expect(movie.rating == 8.5)
    }
}
