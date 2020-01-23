//
//  Player.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/22.
//  Copyright © 2020 wakame-tech. All rights reserved.
//
import Combine
import Firebase
import FireSnapshot
import Foundation
import ReSwift
import ReSwiftThunk

struct PlayerState: StateType {
    var controller: YTPlayerController?
}

enum PlayerAction: Action {
    case updatePlayerController(playerController: YTPlayerController)
    case togglePlayAndStop
    case stop
    case updateVideoId(videoId: String)
    
    static func updateController(playerController: YTPlayerController) {
        Thunk<AppState> { dispatch, getState in
            print("updateController")
            dispatch(PlayerAction.updatePlayerController(playerController: playerController))
        }
    }
    
    static func toggle() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("PlayerAction.toggle()")
            dispatch(PlayerAction.togglePlayAndStop)
        }
    }
    
    static func stop() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("PlayerAction.stop()")
            dispatch(PlayerAction.stop)
        }
    }
    
    @available(*, unavailable, deprecated: 1.0)
    static func setVideoId(videoId: String) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("PlayerAction.setVideoId()")
            dispatch(PlayerAction.updateVideoId(videoId: videoId))
        }
    }
    
    static func setCurrentVideoId() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("PlayerAction.setCurrentVideoId()")
            guard let tracks = getState()?.roomState.room?.tracks else {
                return
            }
            
            // last track
            if tracks.isEmpty {
                print("empty")
                return
            }
            // set track
            dispatch(PlayerAction.updateVideoId(videoId: tracks[0].videoId))
        }
    }
    
    static func setNextVideoId() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("PlayerAction.setNextVideoId()")
            
            guard let tracks = getState()?.roomState.room?.tracks else {
                return
            }
            
            // last track
            if tracks.isEmpty {
                print("empty")
                return
            }
            // last track
            else if tracks.count == 1 {
                print("last video")
                dispatch(RoomAction.popTrack())
                dispatch(PlayerAction.stop())
                return
            }
            // next track
            else {
                let nextVideoId = tracks[0].videoId
                print("next videoId: \(nextVideoId)")
                dispatch(RoomAction.popTrack())
                dispatch(PlayerAction.updateVideoId(videoId: nextVideoId))
            }
        }
    }
}

enum PlayerReducer {
    static var reduce: Reducer<PlayerState> {
        return { action, state in
            var state = state ?? PlayerState()
            guard let action = action as? PlayerAction else {
                return state
            }
            
            switch action {
            case .togglePlayAndStop:
                print("reducer togglePlayAndStop")
                state.controller?.toggle()
            case .stop:
                print("reducer stop")
                state.controller?.stop()
            case let .updateVideoId(videoId):
                state.controller?.setVideoId(videoId)
            case let .updatePlayerController(playerController):
                state.controller = playerController
            }
            return state
        }
    }
}
