//
//  Library.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/22.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI
import Foundation
import PartialSheet

struct TrackView: View {
    var track: Track
    var body: some View {
        VStack {
            HStack {
                Text("\(track.title)")
                     .font(.headline)
                     .foregroundColor(.white)
                     .bold()
                Spacer()
            }

            HStack {
                Text("ユーザー1 / \("フル")")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Spacer()
            }
        }
        .padding(10)
        .background(trackColor())
        .cornerRadius(10)
        // border less
        .onAppear { UITableView.appearance().separatorStyle = .none }
    }
    
    private func trackColor() -> Color {
        return Color.orange
    }
}

// root view
struct LibraryView: View {
    @EnvironmentObject private var store: AppStore
    @State private var target: Track?
    @State private var actionShowing: Bool = false
    
    @State var favorites: [Track] = [
        Track(title: "AAA"),
        Track(title: "BBB"),
        Track(title: "CCC"),
        Track(title: "DDD"),
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Favorites")) {
                    ForEach(favorites) { favorite in
                        TrackView(track: favorite)
                        .onTapGesture {
                             self.target = favorite
                             self.actionShowing = true
                        }
                    }.onDelete(perform: deleteRow)
                }
            }
        }
        .actionSheet(isPresented: $actionShowing) {
            ActionSheet(title: Text("\(self.target?.title ?? "")"), buttons: [
                .default(Text("予約する")) {
                    guard let track = self.target else {
                        return
                    }
                    
                    self.store.dispatch(RoomAction.reserveTrack(track: track))
                }
            ])
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.favorites.remove(atOffsets: indexSet)
    }
}
