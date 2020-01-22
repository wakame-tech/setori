//
//  Library.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/22.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI
import Foundation


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
        .onDisappear { UITableView.appearance().separatorStyle = .singleLine }
    }
    
    private func trackColor() -> Color {
        return Color.orange
    }
}

// root view
struct LibraryView: View {
    @EnvironmentObject private var store: AppStore
    
    @State var favorites: [Track] = [
        Track(title: "AAA"),
        Track(title: "BBB"),
        Track(title: "CCC"),
        Track(title: "DDD"),
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favorites) { favorite in
                    TrackView(track: favorite)
                    .onTapGesture {
                        print(favorite)
                        // self.target = bookmark
                        // self.modalPresented = true
                    }
                }.onDelete(perform: deleteRow)
            }
        }
    }
    
    private func deleteRow(at indexSet: IndexSet) {
        self.favorites.remove(atOffsets: indexSet)
    }
}
