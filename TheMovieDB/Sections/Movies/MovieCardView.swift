//
//  MovieCardView.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 7/10/24.
//

import SwiftUI

struct MovieCardView: View {
    var movie: Movie

    var body: some View {

        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: movie.poster) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 90, height: 120)
                            .scaledToFit()
                            .cornerRadius(8)
                    case .failure:
                        Image(systemName: "photo")
                            .frame(width: 90, height: 120)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    default:
                        ProgressView()
                            .frame(width: 90, height: 120)
                    }
                }
                Text("Released on: \n\(movie.releaseDate)")
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(movie.overview)
                    .font(.footnote)
            }

            Spacer()
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.background)
                .stroke(Color.primary, lineWidth: 1.0)
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    MovieCardView(movie: Movie(id: 533535, title: "Deadpool & Wolverine", poster: "/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg", releaseDate: "2024-07-24", overview: "A listless Wade Wilson toils away in civilian life with his days as the morally flexible mercenary, Deadpool, behind him. But when his homeworld faces an existential threat, Wade must reluctantly suit-up again with an even more reluctant Wolverine."))
//}
