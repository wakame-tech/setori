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

// Library item
struct Item: Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var videoId: String
    
    func toTrack(userName: String, playMode: String) -> Track {
        return Track(title: title, videoId: videoId, userName: userName, playMode: playMode)
    }
}

func == (l: Item, r: Item) -> Bool {
    return l.title == r.title
}

// Component for Library Item
struct ItemView: View {
    var item: Item
    
    var body: some View {
        VStack {
            HStack {
                Text("\(item.title)")
                     .font(.headline)
                     .foregroundColor(.white)
                     .bold()
                Spacer()
            }
            
            HStack {
                Text(item.videoId)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(Color.gray)
        .cornerRadius(10)
        // border less
        .onAppear { UITableView.appearance().separatorStyle = .none }
    }
}

// Component for Track
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
                Text("\(track.userName) / \(track.playMode)")
                    .font(.subheadline)
                    .foregroundColor(.white)

                Spacer()
            }
        }
        .padding(10)
        .background(trackColor(track))
        .cornerRadius(10)
        // border less
        .onAppear { UITableView.appearance().separatorStyle = .none }
    }
    
    private func trackColor(_ track: Track) -> Color {
        switch track.playMode {
        case "フル":
            return Color.orange
        case "ショート":
            return Color.blue
        case "メドレー":
            return Color.green
        default:
            return Color.orange
        }
    }
}

// root view
struct LibraryView: View {
    @EnvironmentObject private var store: AppStore
    @State private var target: Item?
    @State private var actionShowing: Bool = false
    
    @State var favorites: [Item] = [
        Item(title: "椎名林檎 - 公然の秘密", videoId: "ETtDJz9t09U"),
        Item(title: "椎名林檎と宇多田ヒカル - 浪漫と算盤 / Sheena Ringo & Hikaru Utada- The Sun&moon", videoId: "VXJdG0elwSY"),
        Item(title: "King Gnu - 白日", videoId: "ony539T074w"),
        Item(title: "Official髭男dism - Pretender［Official Video］", videoId: "TQ8WlA2GXbk"),
    ]
    
    @State var history: [Item] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Favorites")) {
                    ForEach(favorites) { favorite in
                        ItemView(item: favorite)
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
                    ForEach(history) { item in
                        ItemView(item: item)
                            .onTapGesture {
                                self.target = item
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
                .default(Text("フルで予約する")) {
                    if let item = self.target {
                        self.reserveTrack(item: item, playMode: "フル")
                    }
                },
                .default(Text("ショートで予約する")) {
                    if let item = self.target {
                        self.reserveTrack(item: item, playMode: "ショート")
                    }
                },
                .default(Text("メドレーで予約する")) {
                    if let item = self.target {
                        self.reserveTrack(item: item, playMode: "メドレー")
                    }
                },
                .cancel(Text("キャンセル"))
            ])
        }
    }
    
    func reserveTrack(item: Item, playMode: String) {
        let track = item.toTrack(userName: "ユーザー1", playMode: playMode)
        // send to palylist
        self.store.dispatch(RoomAction.reserveTrack(track: track))
        
        // play if empty
        if self.store.state.roomState.room?.tracks.isEmpty ?? false {
            self.store.dispatch(PlayerAction.setCurrentVideoId())
        }
        
        // add to history
        if self.history.contains(item) {
            self.history.removeAll { $0.title == item.title }
            self.history.append(item)
        } else {
            self.history.append(item)
        }
    }
}
