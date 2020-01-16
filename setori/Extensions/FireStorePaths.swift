//
//  FireStorePaths.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/16.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Foundation
import FireSnapshot

extension  CollectionPaths {
    // "/users/"
    static let users = CollectionPath<UserAuth>("users")
}

extension DocumentPaths {
    // "/master/info/"
    static let info = CollectionPath<Info>("master").document("info")
    
    static func user(userID: String) -> DocumentPath<UserAuth> {
        CollectionPaths.users.document(userID)
    }
}
