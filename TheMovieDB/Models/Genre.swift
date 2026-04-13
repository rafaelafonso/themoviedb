//
//  Genre.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 8/10/24.
//

import Foundation

struct Genres: Codable, Equatable {
    var genres: [Genre]
}

struct Genre: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
}
