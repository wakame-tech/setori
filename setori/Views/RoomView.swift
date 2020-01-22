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

class YTPlayerController: ObservableObject, Identifiable, YTSwiftyPlayerDelegate {
    @Published var player: YTSwiftyPlayer!
    
    init() {
        player = YTSwiftyPlayer(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            playerVars: [
                .autoplay(true),
                .playsInline(true),
                .showControls(.hidden),
                .videoID("ETtDJz9t09U")
            ]
        )
        player.delegate = self
        player.loadPlayer()
    }
    
    func stop() {
        self.player?.stopVideo()
    }
    
    func playerReady(_ player: YTSwiftyPlayer) {
        print("player ready")
    }
    
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        print(state)
//        switch state {
//        case .unstarted:
//            break
//        case .playing:
//            break
//        case .paused:
//            break
//        case .ended:
//            break
//        default:
//            break
//        }
    }
}

struct YTPlayer: UIViewRepresentable {
    var player: YTSwiftyPlayer!
    
    func makeUIView(context: Context) -> UIView {
        player
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// player view
struct PlayerView: View {
    @ObservedObject private var ytPlayerController: YTPlayerController = YTPlayerController()
    
    var body: some View {
        YTPlayer(player: self.ytPlayerController.player!)
    }
}

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
                    // self.ytPlayerController.stop()
                }) {
                    Text("Stop Video")
                }
                
            }
        }
        .onAppear {
            self.store.dispatch(RoomAction.subscribe(roomID: "12345"))
        }
    }
}
