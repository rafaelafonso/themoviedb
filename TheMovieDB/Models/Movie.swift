//
//  Movie.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 4/10/24.
//

import Foundation

struct Movies: Codable, Equatable {
    var results: [Movie]
}

struct Cast: Codable, Hashable {
    let name: String
}

struct Crew: Codable, Hashable {
    let name: String
    let job: String
}

struct MovieCredits: Codable, Hashable {
    var id: Int
    var cast: [Cast]
    var crew: [Crew]
}

struct Movie: Codable, Identifiable, Equatable {

    var id: Int
    var title: String
    var releaseDate: String
    var overview: String
    var genres: [Int]
    var posterPath: String?
    var director: String?
    var cast: [Cast]?
    var rating: Float?
    var votes: Int?

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview, director, cast
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case genres = "genre_ids"
        case rating = "vote_average"
        case votes = "vote_count"
    }

    init(id: Int, title: String, releaseDate: String, overview: String, genres: [Int], posterPath: String? = nil, director: String? = nil, cast: [Cast]? = nil, rating: Float? = nil, votes: Int? = nil) {
        self.id = id
        self.title = title
        self.releaseDate = releaseDate
        self.overview = overview
        self.genres = genres
        self.posterPath = posterPath
        self.director = director
        self.cast = cast
        self.rating = rating
        self.votes = votes
    }

    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
}
