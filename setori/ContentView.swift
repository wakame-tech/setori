//
//  ContentView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/15.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI
import Foundation
import YoutubeKit

class YTPlayerController: ObservableObject, Identifiable, YTSwiftyPlayerDelegate {
    @Published var player: YTSwiftyPlayer!
    
    init() {
        player = YTSwiftyPlayer(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            playerVars: [
                .autoplay(true),
                .playsInline(true),
                // .showControls(.hidden)
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

// room view
struct RoomView: View {
    @EnvironmentObject private var store: AppStore
    @ObservedObject private var ytPlayerController: YTPlayerController = YTPlayerController()
    
    private var state: RoomState {
        get {
            return self.store.state.roomState
        }
    }
    
    var body: some View {
        Section {
            Text("roomID: \(state.room?.data.roomID ?? "---") ")
            Text("tracks: \((state.room?.data.tracks ?? []).debugDescription)")
            
            Button(action: {
                self.ytPlayerController.stop()
            }) {
                Text("Stop Video")
            }
            
            Text("player: \(self.ytPlayerController.player?.description ?? "---")")
            YTPlayer(player: self.ytPlayerController.player!)
        }
        .onAppear {
            self.store.dispatch(RoomAction.subscribe(roomID: "12345"))
        }
    }
}

// root view
struct RootView: View {
    @EnvironmentObject private var store: AppStore
    
    private var state: RootState {
        get {
            return self.store.state.rootState
        }
    }
    
    private var user: UserAuth? {
        get {
            return self.store.state.authState.user?.data
        }
    }
    
    var body: some View {
        VStack {
            Text("Hello Setori \(state.info?.version ?? "---")")
            Text("uid: \(user?.uid ?? "---")")
            Text("name: \(user?.name ?? "---")")
            
            Button(action: {
                self.store.dispatch(RoomAction.createRoom())
            }) {
                Text("Create Room")
            }
            
            RoomView()
        }.onAppear {
            self.store.dispatch(RootAction.subscribe())
        }
        .onDisappear {
            self.store.dispatch(RootAction.unsubscribe())
        }
    }
}

// wrapped view
struct ContentView: View {
    // injected store
    @EnvironmentObject private var store: AppStore
    
    var body: some View {
        // wrap view
        AnyView({ () -> AnyView in
            if let _ = self.store.state.authState.user {
                return AnyView(RootView())
            } else {
                return AnyView(EmptyView())
            }
        }())
        .onAppear {
            self.store.dispatch(AuthAction.subscribe())
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppMain().store)
    }
}
