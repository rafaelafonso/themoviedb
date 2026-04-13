//
//  FavoriteMovie.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 7/10/24.
//

import Foundation
import SwiftData

@Model
class FavoriteMovie {
    var id: Int = 0
    var title: String = ""
    var posterPath: String? = nil
    var releaseDate: String = ""
    var overview: String = ""
    var genres: [Int] = []
    var director: String? = nil
    var cast: [Cast]? = nil
    var rating: Float? = nil
    var votes: Int? = nil

    init(id: Int, title: String, posterPath: String?, releaseDate: String, overview: String, genres: [Int], director: String?, cast: [Cast]?, rating: Float?, votes: Int?) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.overview = overview
        self.genres = genres
        self.director = director
        self.cast = cast
        self.rating = rating
        self.votes = votes
    }
}
