//
//  FilterView.swift
//  TheMovieDB
//
//  Created by Rafael Afonso on 4/10/24.
//

import SwiftUI

struct FilterState {
    var isMenuVisible = false
    var selectedGenre: Genre?
    var selectedYear: Int?
    var selectedRating: Int?

    var hasActiveFilters: Bool {
        selectedGenre != nil || selectedYear != nil || selectedRating != nil
    }

    mutating func clearAll() {
        selectedGenre = nil
        selectedYear = nil
        selectedRating = nil
    }
}

struct FilterView: View {

    @Binding var state: FilterState
    var genres: [Genre]?
    var onRequestGenres: () -> Void

    private let ratings = Array(1...10)

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 20) {
                toggleButton
                if state.isMenuVisible {
                    filterControls
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Toggle

    private var toggleButton: some View {
        HStack {
            Button {
                withAnimation {
                    state.isMenuVisible.toggle()
                    if genres == nil {
                        onRequestGenres()
                    }
                }
            } label: {
                Image(systemName: state.isMenuVisible
                      ? "line.3.horizontal.decrease.circle.fill"
                      : "line.3.horizontal.decrease.circle")
                    .resizable()
                    .frame(width: 26, height: 26)
                    .scaledToFit()
            }
            if !state.isMenuVisible {
                Spacer()
            }
        }
    }

    // MARK: - Filter Controls

    private var filterControls: some View {
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

    // MARK: - Genre

    private var genreFilter: some View {
        FilterRow(
            icon: state.selectedGenre != nil ? "movieclapper.fill" : "movieclapper",
            isActive: state.selectedGenre != nil,
            onClear: { state.selectedGenre = nil }
        ) {
            if let genres {
                Picker("Select a Genre", selection: $state.selectedGenre) {
                    Text("All").tag(Genre?.none)
                    ForEach(genres) { genre in
                        Text(genre.name).tag(Optional(genre))
                    }
                }
                .font(.footnote)
            }
        }
    }

    // MARK: - Year

    private var calendarFilter: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        return FilterRow(
            icon: state.selectedYear != nil ? "calendar.badge.clock" : "calendar",
            isActive: state.selectedYear != nil,
            onClear: { state.selectedYear = nil }
        ) {
            Picker("Select Year", selection: $state.selectedYear) {
                Text("All").tag(Int?.none)
                ForEach(Array(stride(from: currentYear, through: 1900, by: -1)), id: \.self) { year in
                    Text(year.description).tag(Optional(year))
                }
            }
        }
    }

    // MARK: - Rating

    private var ratingFilter: some View {
        FilterRow(
            icon: state.selectedRating != nil ? "star.fill" : "star",
            isActive: state.selectedRating != nil,
            onClear: { state.selectedRating = nil }
        ) {
            Picker("Select Rating", selection: $state.selectedRating) {
                Text("All").tag(Int?.none)
                ForEach(ratings, id: \.self) { rating in
                    Text("\(rating)").tag(Optional(rating))
                }
            }
        }
    }
}

// MARK: - FilterRow

private struct FilterRow<Content: View>: View {
    let icon: String
    let isActive: Bool
    let onClear: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 24, height: 24)
                .scaledToFit()

            content
                .transition(.slide)

            Spacer()

            if isActive {
                Button {
                    withAnimation { onClear() }
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .scaledToFit()
                }
            }
        }
    }
}
