//
//  MoviesViewModel.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 4/10/24.
//

import SwiftUI
import os

@Observable
@MainActor
final class MoviesViewModel {

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    var movies: Movies? = nil
    var genres: [Genre]? = nil
    var page: Int = 1
    var state: State = .idle

    private(set) var creditsCache: [Int: MovieCredits] = [:]
    private let movieService: MovieServiceProtocol
    private let logger = Logger(subsystem: "com.themoviedb", category: "ViewModel")

    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
    }

    func fetchMovies() async {
        if movies == nil { state = .loading }
        logger.debug("Fetching movies page \(self.page)")
        do {
            let result = try await movieService.fetchMovies(page: page)
            if movies == nil {
                movies = result
            } else {
                movies?.results.append(contentsOf: result.results)
            }
            state = movies?.results.isEmpty == true ? .loaded : .loaded
        } catch {
            logger.error("Error fetching movies: \(error.localizedDescription)")
            if movies == nil {
                state = .error("Could not load movies. Check your connection and try again.")
            }
        }
    }

    func fetchMovieCredits(for movie: Movie) async {
        if creditsCache[movie.id] != nil {
            logger.debug("Credits cache hit for movie \(movie.id)")
            return
        }
        logger.debug("Fetching credits for movie \(movie.id)")
        do {
            let credits = try await movieService.fetchMovieCredits(id: movie.id)
            creditsCache[movie.id] = credits
        } catch {
            logger.error("Error fetching credits: \(error.localizedDescription)")
        }
    }

    func credits(for movieId: Int) -> MovieCredits? {
        creditsCache[movieId]
    }

    func director(for movieId: Int) -> String? {
        creditsCache[movieId]?.crew.first(where: { $0.job == "Director" })?.name
    }

    func fetchGenres() async {
        logger.debug("Fetching genres")
        do {
            genres = try await movieService.fetchGenres()
        } catch {
            logger.error("Error fetching genres: \(error.localizedDescription)")
        }
    }

    func loadNextPage() async {
        page += 1
        await fetchMovies()
    }
}
