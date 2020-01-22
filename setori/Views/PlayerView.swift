//
//  PlayerView.swift
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
    private var isPlaying: Bool = false
    private var videoId: String?
    
    init() {
        player = YTSwiftyPlayer(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            playerVars: [
                .autoplay(true),
                .playsInline(true),
                .showControls(.hidden),
                // .videoID("ETtDJz9t09U")
            ]
        )
        player.delegate = self
    }
    
    func setVideoId(_ videoId: String) {
        print("YTPlayerController.setVideoId() videoId: \(videoId)")
        
        if self.videoId == nil {
            self.player.loadPlayer()
        } else {
            self.player.cueVideo(videoID: videoId)
        }
        
        self.videoId = videoId
    }
    
    func toggle() {
        print("YTPlayerController.toggle() isPlaying: \(self.isPlaying)")
        self.isPlaying ? self.player?.pauseVideo() : self.player?.playVideo()
    }
    
    func playerReady(_ player: YTSwiftyPlayer) {
        print("player ready")
        
        if self.videoId != nil {
            self.player?.loadVideo(videoID: self.videoId!)
        }
    }
    
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        print(state)
        
        switch state {
        case .unstarted:
            break
        case .playing:
            self.isPlaying = true
            break
        case .paused:
            self.isPlaying = false
            break
        case .ended:
            break
        default:
            break
        }
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
    @EnvironmentObject private var store: AppStore
    @ObservedObject private var ytPlayerController: YTPlayerController = YTPlayerController()
    
    var body: some View {
        VStack {
            YTPlayer(player: self.ytPlayerController.player!)
        }
        .onAppear {
            self.store.dispatch(PlayerAction.updatePlayerController(playerController: self.ytPlayerController))
        }
    }
}
