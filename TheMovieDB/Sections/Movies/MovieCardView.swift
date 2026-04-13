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
                AsyncImage(url: movie.posterURL, transaction: Transaction(animation: nil)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 120)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        Image(systemName: "photo")
                            .frame(width: 90, height: 120)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    default:
                        Color.gray.opacity(0.15)
                            .frame(width: 90, height: 120)
                            .cornerRadius(8)
                    }
                }
                Text("Released on: \n\(movie.releaseDate)")
                    .font(.caption)
            }
            .frame(width: 90)

            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(movie.overview)
                    .font(.footnote)
                    .lineLimit(4)
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
