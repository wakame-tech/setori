//
//  Room.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/16.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Combine
import Firebase
import FireSnapshot
import Foundation
import ReSwift
import ReSwiftThunk

struct Track: SnapshotData, HasTimestamps, Equatable {
    var title: String
    
    static var fieldNames: [PartialKeyPath<Track> : String] {
        [
            \Self.self.title: "title",
        ]
    }
}

struct Room: SnapshotData {
    let roomID: String
    let tracks: [Track]
}

struct RoomState: StateType {
    var room: Snapshot<Room>?
    var roomListener: ListenerRegistration?
}

enum RoomAction: Action {
    case updateListener(listener: ListenerRegistration?)
    case updateRoom(room: Snapshot<Room>)
    // case updateTracks(tracks: [Snapshot<Track>])
    
    static func subscribe(roomID: String) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("room \(roomID) subscribe")
            let listener = Snapshot<Room>
                .listen(.room(roomID: roomID)) { result in
                    switch result {
                    case let .success(room):
                        dispatch(RoomAction.updateRoom(room: room))
                    case let .failure(error):
                        print(error)
                    }
                }
            
            dispatch(RoomAction.updateListener(listener: listener))
        }
    }
    
    static func createRoom() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            let roomID = "12345"
            print("create room \(roomID)")
            let newRoom = Room(roomID: roomID, tracks: [])
            Snapshot<Room>.init(data: newRoom, path: .room(roomID: roomID)).create { result in
                switch result {
                case .success:
                    print("room \(roomID) created")
                    Snapshot<Room>.get(DocumentPaths.room(roomID: roomID)) { result in
                        switch result {
                        case let .success(room):
                            dispatch(RoomAction.updateRoom(room: room))
                        case let .failure(error):
                            print(error)
                        }
                    }
                case let .failure(error):
                    print(error)
                }
            }
        }
    }
    
    static func updateRoom(room: Room) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            dispatch(RoomAction.updateRoom(room: room))
        }
    }
}

enum RoomReducer {
    static var reduce: Reducer<RoomState> {
        return { action, state in
            var state = state ?? RoomState()
            guard let action = action as? RoomAction else {
                return state
            }
            
            switch action {
            case let .updateListener(listener):
                state.roomListener = listener
            case let .updateRoom(room):
                dump(room.data)
                state.room = room
            }
            
            return state
        }
    }
}
