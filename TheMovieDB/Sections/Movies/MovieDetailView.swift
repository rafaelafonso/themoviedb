//
//  MovieDetailView.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 7/10/24.
//

import SwiftData
import SwiftUI

struct MovieDetailView: View {

    @Environment(\.modelContext) private var modelContext
    var viewModel: MoviesViewModel
    @Query var favorites: [FavoriteMovie]
    var movie: Movie
    @State private var isFavorite: Bool = false
    @State private var isLoadingCredits: Bool = true

    var body: some View {

        ScrollView {
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 20) {
                    AsyncImage(url: movie.poster) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 180, height: 240)
                                .scaledToFit()
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .frame(width: 180, height: 240)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        default:
                            ProgressView()
                                .frame(width: 180, height: 240)
                        }
                    }
                    VStack(alignment: .leading) {
                        infoSection(title: "Director", content: viewModel.director ?? "")
                        infoSection(title: "Released on", content: movie.releaseDate)
                        infoSection(title: "Rating", content: "\(movie.rating ?? 0.0)")
                        infoSection(title: "Votes", content: "\(movie.votes ?? 0)")
                    }

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    infoSection(title: "Synopsis", content: movie.overview)

                    if isLoadingCredits {
                        ProgressView()
                            .padding(.vertical, 8)
                    } else if let cast = viewModel.movieCredits?.cast, !cast.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Cast")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            ForEach(cast, id: \.self) { member in
                                Text(member.name)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle(movie.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.handleFavorite()
                } label: {
                    Image(systemName: self.isFavorite ? "heart.fill" : "heart")
                        .font(.body)
                }
            }
        }
        .task {
            await viewModel.fetchMovieCredits(for: movie)
            isLoadingCredits = false
        }
        .onAppear {
            self.isFavorite = favorites.contains(where: { $0.id == movie.id })
        }
        .onDisappear {
            Task {
                do {
                    try modelContext.save()
                } catch {
                    print(">error saving modelContext: \(error.localizedDescription)")
                }
            }
        }
    }
}

private extension MovieDetailView {

    func handleFavorite() {

        self.isFavorite.toggle()

        if isFavorite {
            let favoriteMovie = FavoriteMovie(id: movie.id, title: movie.title, poster: movie.poster, releaseDate: movie.releaseDate, overview: movie.overview, genres: movie.genres, director: movie.director, cast: movie.cast, rating: movie.rating, votes: movie.votes)
            modelContext.insert(favoriteMovie)
        } else {
            if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
                modelContext.delete(favorites[index])
            }
        }
    }

    func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
            Text(content)
                .font(.subheadline)
        }
        .padding(.bottom, 8)
    }
}
