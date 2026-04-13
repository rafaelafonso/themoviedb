//
//  MoviesListView.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 4/10/24.
//

import SwiftUI
import SwiftData

struct MoviesListView: View {

    @Environment(\.modelContext) private var modelContext
    @State var networkStatus = NetworkStatus()
    @State var viewModel = MoviesViewModel()

    @State private var selectedMovie: Movie?
    @State private var showDetailsView = false
    @State private var filterState = FilterState()
    @State private var searchText = ""

    @Query var favoriteMovies: [FavoriteMovie]
    @State private var showReconnectionCounter = 0
    @State private var showReconnectionAlert = false

    private var filteredMovies: [Movie] {
        if !networkStatus.isConnected {
            return favoriteMovies.map {
                Movie(id: $0.id, title: $0.title, releaseDate: $0.releaseDate,
                      overview: $0.overview, genres: $0.genres, posterPath: $0.posterPath,
                      director: $0.director, cast: $0.cast, rating: $0.rating, votes: $0.votes)
            }
        }

        guard var movies = viewModel.movies else { return [] }

        if let rating = filterState.selectedRating {
            movies.results = movies.results.filter { $0.rating ?? 0.0 >= Float(rating) }
        }
        if let genre = filterState.selectedGenre {
            movies.results = movies.results.filter { $0.genres.contains(genre.id) }
        }
        if let year = filterState.selectedYear {
            movies.results = movies.results.filter { $0.releaseDate.contains("\(year)") }
        }
        if !searchText.isEmpty {
            movies.results = movies.results.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return movies.results
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                FilterView(
                    state: $filterState,
                    genres: viewModel.genres,
                    onRequestGenres: { Task { await viewModel.fetchGenres() } }
                )

                Group {
                    switch viewModel.state {
                    case .idle, .loading:
                        ProgressView("Loading movies...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    case .error(let message):
                        ContentUnavailableView {
                            Label("Something went wrong", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(message)
                        } actions: {
                            Button("Try Again") {
                                Task { await viewModel.fetchMovies() }
                            }
                        }

                    case .loaded:
                        if filteredMovies.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        } else {
                            moviesList
                        }
                    }
                }
            }
            .navigationTitle(Text("Popular Movies"))
            .navigationDestination(isPresented: $showDetailsView) {
                if let movie = selectedMovie {
                    MovieDetailView(viewModel: viewModel, movie: movie)
                }
            }
            .task {
                await viewModel.fetchMovies()
            }
            .onChange(of: networkStatus.isConnected) { oldValue, newValue in
                if !oldValue && newValue {
                    showReconnectionCounter += 1
                    if showReconnectionCounter > 1 {
                        showReconnectionAlert.toggle()
                    }
                }
            }
            .alert("Internet is back!", isPresented: $showReconnectionAlert) {}
        }
    }

    private var moviesList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem()], spacing: 12) {
                ForEach(Array(filteredMovies.enumerated()), id: \.offset) { index, movie in
                    MovieCardView(movie: movie)
                        .onTapGesture {
                            selectedMovie = movie
                            showDetailsView = true
                        }
                        .onAppear {
                            if index == filteredMovies.count - 3 {
                                Task { await viewModel.loadNextPage() }
                            }
                        }
                }
                .searchable(text: $searchText, prompt: "Search movie")
            }
        }
        .padding(.top)
    }
}
