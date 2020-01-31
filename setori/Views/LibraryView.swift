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
        Track(title: "椎名林檎 - 公然の秘密", videoId: "ETtDJz9t09U"),
        Track(title: "椎名林檎と宇多田ヒカル - 浪漫と算盤 / Sheena Ringo & Hikaru Utada- The Sun&moon", videoId: "VXJdG0elwSY"),
        Track(title: "King Gnu - 白日", videoId: "ony539T074w"),
        Track(title: "Official髭男dism - Pretender［Official Video］", videoId: "TQ8WlA2GXbk"),
    ]
    
    @State var history: [Track] = []
    
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
                    }
                    .onDelete { at in
                        self.favorites.remove(atOffsets: at)
                    }
                }
                
                Section(header: Text("History")) {
                    ForEach(history) { hist in
                        TrackView(track: hist)
                            .onTapGesture {
                                self.target = hist
                                self.actionShowing = true
                        }
                    }
                    .onDelete { at in
                        self.history.remove(atOffsets: at)
                    }
                }
            }
        }
        .actionSheet(isPresented: $actionShowing) {
            ActionSheet(title: Text("\(self.target?.title ?? "")"), buttons: [
                .default(Text("予約する")) {
                    guard let track = self.target else {
                        return
                    }
                    
                    // send to palylist
                    self.store.dispatch(RoomAction.reserveTrack(track: track))
                    
                    // play if empty
                    if self.store.state.roomState.room?.tracks.isEmpty ?? false {
                        self.store.dispatch(PlayerAction.setCurrentVideoId())
                    }
                    
                    // add to history
                    self.history.append(track)
                },
                .cancel(Text("キャンセル"))
            ])
        }
    }
}
