//
//  MoviesViewModelTests.swift
//  TheMovieDBTests
//

import Testing
import Foundation
@testable import TheMovieDB

@MainActor
struct MoviesViewModelTests {

    private func makeMockService(
        movies: Movies? = nil,
        genres: [Genre]? = nil,
        credits: MovieCredits? = nil,
        error: Error? = nil
    ) -> MockMovieService {
        let mock = MockMovieService()
        mock.moviesToReturn = movies
        mock.genresToReturn = genres
        mock.movieCreditsToReturn = credits
        mock.errorToThrow = error
        return mock
    }

    private let sampleMovies = Movies(results: [
        Movie(id: 1, title: "Movie One", releaseDate: "2024-01-01", overview: "Overview one", genres: [28], rating: 7.5),
        Movie(id: 2, title: "Movie Two", releaseDate: "2023-06-15", overview: "Overview two", genres: [35], rating: 5.0),
    ])

    // MARK: - fetchMovies

    @Test func fetchMoviesSetsLoadedState() async {
        let service = makeMockService(movies: sampleMovies)
        let vm = MoviesViewModel(movieService: service)

        await vm.fetchMovies()

        #expect(vm.state == .loaded)
        #expect(vm.movies?.results.count == 2)
    }

    @Test func fetchMoviesSetsErrorStateOnFailure() async {
        let service = makeMockService(error: URLError(.notConnectedToInternet))
        let vm = MoviesViewModel(movieService: service)

        await vm.fetchMovies()

        if case .error = vm.state {
            // expected
        } else {
            Issue.record("Expected error state, got \(vm.state)")
        }
        #expect(vm.movies == nil)
    }

    @Test func fetchMoviesShowsLoadingOnFirstLoad() async {
        let service = makeMockService(movies: sampleMovies)
        let vm = MoviesViewModel(movieService: service)

        #expect(vm.state == .idle)
        #expect(vm.movies == nil)
    }

    // MARK: - Pagination

    @Test func loadNextPageAppendsResults() async {
        let page1 = Movies(results: [
            Movie(id: 1, title: "Movie One", releaseDate: "2024-01-01", overview: "Overview", genres: [28])
        ])
        let page2 = Movies(results: [
            Movie(id: 2, title: "Movie Two", releaseDate: "2024-01-01", overview: "Overview", genres: [35])
        ])

        let service = MockMovieService()
        service.moviesToReturn = page1
        let vm = MoviesViewModel(movieService: service)

        await vm.fetchMovies()
        #expect(vm.movies?.results.count == 1)

        service.moviesToReturn = page2
        await vm.loadNextPage()

        #expect(vm.page == 2)
        #expect(vm.movies?.results.count == 2)
        #expect(vm.movies?.results[1].title == "Movie Two")
    }

    // MARK: - fetchGenres

    @Test func fetchGenresSetsGenres() async {
        let genres = [Genre(id: 28, name: "Action"), Genre(id: 35, name: "Comedy")]
        let service = makeMockService(movies: sampleMovies, genres: genres)
        let vm = MoviesViewModel(movieService: service)

        await vm.fetchGenres()

        #expect(vm.genres?.count == 2)
        #expect(vm.genres?[0].name == "Action")
    }

    // MARK: - fetchMovieCredits

    @Test func fetchCreditsSetsDirectorAndCredits() async {
        let credits = MovieCredits(
            id: 1,
            cast: [Cast(name: "Actor One"), Cast(name: "Actor Two")],
            crew: [Crew(name: "Shawn Levy", job: "Director"), Crew(name: "Someone", job: "Producer")]
        )
        let service = makeMockService(movies: sampleMovies, credits: credits)
        let vm = MoviesViewModel(movieService: service)

        let movie = sampleMovies.results[0]
        await vm.fetchMovieCredits(for: movie)

        #expect(vm.director == "Shawn Levy")
        #expect(vm.movieCredits?.cast.count == 2)
    }

    @Test func fetchCreditsWithNoDirectorSetsNil() async {
        let credits = MovieCredits(
            id: 1,
            cast: [Cast(name: "Actor One")],
            crew: [Crew(name: "Someone", job: "Producer")]
        )
        let service = makeMockService(movies: sampleMovies, credits: credits)
        let vm = MoviesViewModel(movieService: service)

        let movie = sampleMovies.results[0]
        await vm.fetchMovieCredits(for: movie)

        #expect(vm.director == nil)
    }
}
