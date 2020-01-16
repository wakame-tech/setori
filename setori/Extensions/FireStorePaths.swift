//
//  FireStorePaths.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/16.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Foundation
import FireSnapshot

extension CollectionPaths {
    // "/users/"
    static let users = CollectionPath<UserAuth>("users")
    
    // "/rooms/"
    static let rooms = CollectionPath<Room>("rooms")
    
    // "/rooms/:id/tracks"
    static func tracks(roomID: String) -> CollectionPath<Track> {
        DocumentPaths.room(roomID: roomID).collection("tracks")
    }
}

extension DocumentPaths {
    // "/master/info/"
    static let info = CollectionPath<Info>("master").document("info")
    
    // "/users/:id/"
    static func user(userID: String) -> DocumentPath<UserAuth> {
        CollectionPaths.users.document(userID)
    }
    
    // "/rooms/:id"
    static func room(roomID: String) -> DocumentPath<Room> {
        CollectionPaths.rooms.document(roomID)
    }
}
