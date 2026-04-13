//
//  ModelDecodingTests.swift
//  TheMovieDBTests
//

import Testing
import Foundation
@testable import TheMovieDB

struct ModelDecodingTests {

    // MARK: - Movie

    @Test func decodesMovieFromJSON() throws {
        let json = """
        {
            "id": 533535,
            "title": "Deadpool & Wolverine",
            "release_date": "2024-07-24",
            "overview": "A listless Wade Wilson toils away.",
            "genre_ids": [28, 35],
            "poster_path": "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg",
            "vote_average": 7.8,
            "vote_count": 5200
        }
        """.data(using: .utf8)!

        let movie = try JSONDecoder().decode(Movie.self, from: json)

        #expect(movie.id == 533535)
        #expect(movie.title == "Deadpool & Wolverine")
        #expect(movie.releaseDate == "2024-07-24")
        #expect(movie.overview == "A listless Wade Wilson toils away.")
        #expect(movie.genres == [28, 35])
        #expect(movie.posterPath == "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg")
        #expect(movie.rating == 7.8)
        #expect(movie.votes == 5200)
    }

    @Test func moviePosterURLBuildsCorrectly() {
        let movie = Movie(id: 1, title: "Test", releaseDate: "2024-01-01", overview: "Overview", genres: [], posterPath: "/abc.jpg")

        #expect(movie.posterURL?.absoluteString == "https://image.tmdb.org/t/p/w500/abc.jpg")
    }

    @Test func moviePosterURLIsNilWhenNoPosterPath() {
        let movie = Movie(id: 1, title: "Test", releaseDate: "2024-01-01", overview: "Overview", genres: [])

        #expect(movie.posterURL == nil)
    }

    @Test func decodesMovieWithOptionalFieldsMissing() throws {
        let json = """
        {
            "id": 1,
            "title": "Minimal Movie",
            "release_date": "2024-01-01",
            "overview": "A movie.",
            "genre_ids": []
        }
        """.data(using: .utf8)!

        let movie = try JSONDecoder().decode(Movie.self, from: json)

        #expect(movie.id == 1)
        #expect(movie.posterPath == nil)
        #expect(movie.rating == nil)
        #expect(movie.votes == nil)
        #expect(movie.director == nil)
        #expect(movie.cast == nil)
    }

    @Test func decodesMoviesResponse() throws {
        let json = """
        {
            "results": [
                {
                    "id": 1,
                    "title": "Movie One",
                    "release_date": "2024-01-01",
                    "overview": "First movie.",
                    "genre_ids": [28]
                },
                {
                    "id": 2,
                    "title": "Movie Two",
                    "release_date": "2024-06-15",
                    "overview": "Second movie.",
                    "genre_ids": [35, 18]
                }
            ]
        }
        """.data(using: .utf8)!

        let movies = try JSONDecoder().decode(Movies.self, from: json)

        #expect(movies.results.count == 2)
        #expect(movies.results[0].title == "Movie One")
        #expect(movies.results[1].genres == [35, 18])
    }

    // MARK: - Genre

    @Test func decodesGenresResponse() throws {
        let json = """
        {
            "genres": [
                {"id": 28, "name": "Action"},
                {"id": 35, "name": "Comedy"}
            ]
        }
        """.data(using: .utf8)!

        let genres = try JSONDecoder().decode(Genres.self, from: json)

        #expect(genres.genres.count == 2)
        #expect(genres.genres[0].id == 28)
        #expect(genres.genres[0].name == "Action")
        #expect(genres.genres[1].name == "Comedy")
    }

    // MARK: - MovieCredits

    @Test func decodesMovieCredits() throws {
        let json = """
        {
            "id": 533535,
            "cast": [
                {"name": "Ryan Reynolds"},
                {"name": "Hugh Jackman"}
            ],
            "crew": [
                {"name": "Shawn Levy", "job": "Director"},
                {"name": "Kevin Feige", "job": "Producer"}
            ]
        }
        """.data(using: .utf8)!

        let credits = try JSONDecoder().decode(MovieCredits.self, from: json)

        #expect(credits.id == 533535)
        #expect(credits.cast.count == 2)
        #expect(credits.cast[0].name == "Ryan Reynolds")
        #expect(credits.crew.count == 2)
        #expect(credits.crew.first(where: { $0.job == "Director" })?.name == "Shawn Levy")
    }
}
