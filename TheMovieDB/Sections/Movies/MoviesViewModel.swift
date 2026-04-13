//
//  MoviesViewModel.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 4/10/24.
//

import SwiftUI
import os

@MainActor
class MoviesViewModel: ObservableObject {
    @Published var movies: Movies? = nil
    @Published var genres: [Genre]? = nil
    @Published var movieCredits: MovieCredits? = nil
    @Published var director: String? = nil
    @Published var page: Int = 1
    @Published var errorMessage: String? = nil

    private let movieService: MovieServiceProtocol
    private let logger = Logger(subsystem: "com.themoviedb", category: "ViewModel")

    init(movieService: MovieServiceProtocol = MovieService()) {
        self.movieService = movieService
        Task {
            await self.fetchMovies()
        }
    }

    func fetchMovies() async {
        logger.debug("Fetching movies page \(self.page)")
        do {
            let result = try await movieService.fetchMovies(page: page)
            if movies == nil {
                movies = result
            } else {
                movies?.results.append(contentsOf: result.results)
            }
            errorMessage = nil
        } catch {
            logger.error("Error fetching movies: \(error.localizedDescription)")
            errorMessage = "Could not load movies."
        }
    }

    func fetchMovieDetails(for movie: Movie) async {
        logger.debug("Fetching details for movie \(movie.id)")
        do {
            _ = try await movieService.fetchMovieDetails(id: movie.id)
        } catch {
            logger.error("Error fetching movie details: \(error.localizedDescription)")
        }
    }

    func fetchMovieCredits(for movie: Movie) async {
        logger.debug("Fetching credits for movie \(movie.id)")
        do {
            let credits = try await movieService.fetchMovieCredits(id: movie.id)
            movieCredits = credits
            director = credits.crew.first(where: { $0.job == "Director" })?.name
        } catch {
            logger.error("Error fetching credits: \(error.localizedDescription)")
        }
    }

    func fetchGenres() async {
        logger.debug("Fetching genres")
        do {
            genres = try await movieService.fetchGenres()
        } catch {
            logger.error("Error fetching genres: \(error.localizedDescription)")
        }
    }
}
