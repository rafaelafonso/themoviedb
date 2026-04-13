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

    @State private var showDetailsView: Bool = false
    @State private var selectedMovie: Movie?

    @State private var showFilterMenu: Bool = false
    @State private var showFilterByGenre: Bool = false
    @State private var showFilterByYear: Bool = false
    @State private var showFilterByRating: Bool = false

    @State private var selectedGenre: Genre?
    @State private var selectedYear: Int?
    @State private var selectedRating: Int?
    let ratings: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    let columns = [GridItem()]

    @State private var searchText: String = ""

    @Query var favoriteMovies: [FavoriteMovie]
    @State private var showReconnectionCounter: Int = 0
    @State private var showReconnectionAlert: Bool = false

    private var filteredMovies: [Movie] {

        // offline
        if !networkStatus.isConnected {
            var tempMovies: [Movie] = []
            for favoriteMovie in favoriteMovies {
                tempMovies.append(Movie(id: favoriteMovie.id, title: favoriteMovie.title, releaseDate: favoriteMovie.releaseDate, overview: favoriteMovie.overview, genres: favoriteMovie.genres, director: favoriteMovie.director, cast: favoriteMovie.cast, rating: favoriteMovie.rating, votes: favoriteMovie.votes))
            }
            return tempMovies
        }
        // online
        else {
            if let movies = viewModel.movies {
                var tempMovies = movies
                if let selectedRating = selectedRating {
                    tempMovies.results = tempMovies.results.filter { $0.rating ?? 0.0 >= Float(selectedRating) }
                }

                if let selectedGenre = selectedGenre {
                    tempMovies.results = tempMovies.results.filter { $0.genres.contains(selectedGenre.id) }
                }

                if let selectedYear = selectedYear {
                    tempMovies.results = tempMovies.results.filter { $0.releaseDate.contains("\(selectedYear)") }
                }

                if !searchText.isEmpty {
                    tempMovies.results = tempMovies.results.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                }
                return tempMovies.results
            } else {
                return []
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                filterView
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
                    self.showReconnectionCounter += 1
                    if showReconnectionCounter > 1 {
                        self.showReconnectionAlert.toggle()
                    }
                }
            }
            .alert("Internet is back!", isPresented: $showReconnectionAlert) {}
        }
    }

    private var moviesList: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(filteredMovies.enumerated()), id: \.offset) { index, movie in
                    MovieCardView(movie: movie)
                        .onTapGesture {
                            self.selectedMovie = movie
                            self.showDetailsView = true
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

// MARK: - Filters

private extension MoviesListView {

    var filterView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 20) {
                HStack {
                    // show/hide filters
                    Button {
                        withAnimation {
                            self.showFilterMenu.toggle()
                            if viewModel.genres == nil {
                                Task {
                                    await viewModel.fetchGenres()
                                }
                            }
                        }
                    } label: {
                        Image(systemName: self.showFilterMenu ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .resizable()
                            .frame(width: 26, height: 26)
                            .scaledToFit()
                    }
                    if !showFilterMenu {
                        Spacer()
                    }
                }

                if showFilterMenu {
                    VStack(spacing: 20) {
                        genreFilter
                        calendarFilter
                        ratingFilter
                    }
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .transition(.scale)
                    .foregroundStyle(Color.accentColor)
                }
            }
        }
        .padding(.horizontal)
    }


    var genreFilter: some View {

        HStack {
            Image(systemName: self.selectedGenre != nil ? "movieclapper.fill" : "movieclapper")
                .resizable()
                .frame(width: 24, height: 24)
                .scaledToFit()

            Button {
                withAnimation {
                    self.showFilterByGenre.toggle()
                }
            } label: {
                if let genres = viewModel.genres {
                    Picker("Select a Genre", systemImage: self.showFilterByGenre ? "movieclapper.fill" : "movieclapper", selection: $selectedGenre) {
                        ForEach(genres) { genre in
                            Text(genre.name)
                                .tag(genre)
                        }
                    }
                    .font(.footnote)
                }
            }
            .transition(.slide)

            Spacer()

            if selectedGenre != nil {
                Button {
                    withAnimation {
                        self.selectedGenre = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .scaledToFit()
                }
            }
        }
    }

    var calendarFilter: some View {

        HStack {
            Image(systemName: selectedYear != nil ? "calendar.badge.clock" : "calendar")
                .resizable()
                .frame(width: 24, height: 24)
                .scaledToFit()

            Button {
                withAnimation {
                    self.showFilterByYear.toggle()
                }
            } label: {
                Picker("Select Year", selection: $selectedYear) {
                    ForEach(Array(stride(from: Calendar.current.component(.year, from: Date()), through: 1900, by: -1)), id: \.self) { year in
                        Text("\(year.description)")
                            .tag(year)
                    }
                }
            }
            .transition(.slide)

            Spacer()

            if selectedYear != nil {
                Button {
                    self.selectedYear = nil
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }

    var ratingFilter: some View {

        HStack {
            Image(systemName: selectedRating != nil ? "star.fill" : "star")
                .resizable()
                .frame(width: 24, height: 24)
                .scaledToFit()

            Button {
                withAnimation {
                    self.showFilterByRating.toggle()
                }
            } label: {
                Picker("Select Rating", selection: $selectedRating) {
                    ForEach(ratings, id: \.self) { rating in
                        Text("\(rating)")
                            .tag(rating)
                    }
                }
            }
            .transition(.slide)

            Spacer()

            if selectedRating != nil {
                Button {
                    self.selectedRating = nil
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
