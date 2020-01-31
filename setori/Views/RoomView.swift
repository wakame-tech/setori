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
                
                ForEach(state.room?.tracks ?? []) { track in
                    Text("\(track.title)")
                }

                Button(action: {
                    self.store.dispatch(PlayerAction.toggle())
                }) {
                    Text("Stop Video")
                }
                
                Button(action: {
                    self.store.dispatch(PlayerAction.setNextVideoId())
                }) {
                    Text("Next")
                }
            }
        }
        .onAppear {
            self.store.dispatch(RoomAction.subscribe(roomID: "12345"))
        }
    }
}
