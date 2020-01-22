//
//  RoomView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/22.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Foundation
import SwiftUI
import YoutubeKit

// room view
struct RoomView: View {
    @EnvironmentObject private var store: AppStore
    
    private var state: RoomState {
        get {
            return self.store.state.roomState
        }
    }
    
    var body: some View {
        VStack {
            Section {
                Text("roomID: \(state.room?.data.roomID ?? "---") ")
                Text("tracks: \((state.room?.data.tracks ?? []).debugDescription)")
                
                Button(action: {
                    self.store.dispatch(PlayerAction.toggle())
                }) {
                    Text("Stop Video")
                }
                
                Button(action: {
                    self.store.dispatch(PlayerAction.setVideoId(videoId: "ETtDJz9t09U"))
                }) {
                    Text("Set VideoId")
                }
            }
        }
        .onAppear {
            self.store.dispatch(RoomAction.subscribe(roomID: "12345"))
        }
    }
}
