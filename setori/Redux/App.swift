//
//  App.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/16.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Foundation
import Firebase
import ReSwift
import ReSwiftThunk
import FireSnapshot

// Info is on FireStore
struct Info: SnapshotData {
    var version: String
}

struct UserAuth: SnapshotData, HasTimestamps {
    let uid: String
    let name: String
}

struct RootState: StateType {
    // data snapshot
    var info: Snapshot<Info>?
    // data listener
    var infoListener: ListenerRegistration?
}

enum RootAction: Action {
    case updateInfo(info: Snapshot<Info>)
    case updateListener(listener: ListenerRegistration?)
    
    static func subscribe() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            // initial fetch
            Snapshot<Info>.get(.info) { result in
                switch result {
                case let .success(info):
                    dispatch(RootAction.updateInfo(info: info))
                case let .failure(error):
                    print(error)
                }
            }
            
            // state change listener
            let listener = Snapshot<Info>.listen(.info) { result in
                switch result {
                case let .success(info):
                    dispatch(RootAction.updateInfo(info: info))
                case let .failure(error):
                    print(error)
                }
            }
            
            // set listener
            dispatch(RootAction.updateListener(listener: listener))
        }
    }
    
    static func unsubscribe() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            getState()?.rootState.infoListener?.remove()
            // unset listener
            dispatch(RootAction.updateListener(listener: nil))
        }
    }
}

enum RootReducer {
    static var reduce: Reducer<RootState> {
        return { action, state in
            var state = state ?? RootState()
            guard let action = action as? RootAction else {
                return state
            }
            
            // reducer
            switch action {
            case let .updateInfo(info):
                state.info = info
                return state
            case let .updateListener(listener):
                state.infoListener = listener
                return state
            }
        }
    }
}

// app all states
struct AppState: StateType {
    var authState: AuthState = .init()
    var rootState: RootState = .init()
    var roomState: RoomState = .init()
    var playerState: PlayerState = .init()
}

enum AppReducer {
    static var reduce: Reducer<AppState> {
        return { action, state in
            var state = state ?? AppState()
            
            // enumerate app all reducers
            state.rootState = RootReducer.reduce(action, state.rootState)
            state.authState = AuthReducer.reduce(action, state.authState)
            state.roomState = RoomReducer.reduce(action, state.roomState)
            state.playerState = PlayerReducer.reduce(action, state.playerState)
            
            return state
        }
    }
}
