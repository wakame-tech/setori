//
//  Auth.swift
//  setori-ios
//
//  Created by 鎌田大己 on 2020/01/13.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Combine
import Firebase
import FireSnapshot
import Foundation
import ReSwift
import ReSwiftThunk

struct AuthState: StateType {
    enum LoadingState {
        case initial
        case loaded
    }
    
    var requesting: Bool = false
    var error: Error?

    var loadingState: LoadingState = .initial
    var user: Snapshot<UserAuth>?
    var listenerCancellable: AnyCancellable?
}

enum AuthAction: Action {
    case finishInitialLoad
    case updateAuthChangeListener(listener: AnyCancellable?)
    case updateUser(user: Snapshot<UserAuth>?)
    case signInStarted
    case signInFinished
    case signInFailed(error: Error)
    
    // subscribe auth listener
    static func subscribe() -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("auth subscribe")
            
            let finishInitialLoad = {
                if getState()?.authState.loadingState == .some(.initial) {
                    dispatch(AuthAction.finishInitialLoad)
                    
                    // auto login
                    #if DEBUG
                    dispatch(AuthAction.signIn(email: "a@b.com", password: "123456"))
                    #endif
                }
            }
            
            let cancellable = Auth.auth().combine.stateDidChange()
                .map { $1 }
                .map { user -> Action in
                    if let user = user {
                        return AuthAction.fetchUser(uid: user.uid) {
                            finishInitialLoad()
                        }
                    } else {
                        finishInitialLoad()
                        return AuthAction.updateUser(user: nil)
                    }
                }
                .sink(receiveValue: dispatch)
            
            dispatch(AuthAction.updateAuthChangeListener(listener: cancellable))
        }
    }

    // fetch user auth
    static func fetchUser(uid: String, completion: @escaping () -> Void = {}) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            Snapshot.get(.user(userID: uid)) { result in
                switch result {
                case let .success(user):
                    dispatch(AuthAction.updateUser(user: user))
                case let .failure(error):
                    print(error)
                    if getState()?.authState.requesting == false {
                        dispatch(AuthAction.signOut())
                    }
                }
                completion()
            }
        }
    }
    
    // signin and get user data
    static func signIn(email: String, password: String, auth: Auth = .auth()) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("try to signup")
            
            if getState()?.authState.requesting == true {
                return
            }
            
            dispatch(AuthAction.signInStarted)
            
            auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    dispatch(AuthAction.signInFailed(error: error))
                }
                else if let result = result {
                    dispatch(AuthAction.getUser(with: result.user.uid))
                    // TODO signup
                    // dispatch(AuthAction.createUser(with: result.user.uid, name: "ほげ"))
                }
            }
        }
    }
    
    // get user data
    private static func getUser(with uid: String, db: Firestore = .firestore()) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            Snapshot<UserAuth>.get(.user(userID: uid)) { result in
                print("user fetched")
                switch result {
                case .success:
                    dispatch(AuthAction.fetchUser(uid: uid) {
                        dispatch(AuthAction.signInFinished)
                    })
                case let .failure(error):
                    dispatch(AuthAction.signInFailed(error: error))
                }
            }
        }
    }
    
    // signup and create user data
    static func signUp(email: String, password: String, name: String, auth: Auth = .auth()) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("try to signup")
            
            if getState()?.authState.requesting == true {
                return
            }
            
            dispatch(AuthAction.signInStarted)
            
            auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    dispatch(AuthAction.signInFailed(error: error))
                }
                else if let result = result {
                    dispatch(AuthAction.createUser(with: result.user.uid, name: name))
                }
            }
        }
    }
    
    // signin and create user data
    private static func createUser(with uid: String, name: String, db: Firestore = .firestore()) -> Thunk<AppState> {
        Thunk<AppState> { dispatch, getState in
            print("creating user")
            let user = UserAuth(uid: uid, name: name)
            Snapshot<UserAuth>.init(data: user, path: DocumentPaths.user(userID: uid))
                .create { result in
                    switch result {
                    case .success:
                        print("user created")
                        dispatch(AuthAction.fetchUser(uid: uid) {
                            dispatch(AuthAction.signInFinished)
                        })
                    case let .failure(error):
                        dispatch(AuthAction.signInFailed(error: error))
                    }
                }
            }
    }

    static func signOut() -> Thunk<AppState> {
        Thunk<AppState> { _, _ in
            _ = try? Auth.auth().signOut()
        }
    }
}

enum AuthReducer {
    static var reduce: Reducer<AuthState> {
        return { action, state in
            var state = state ?? AuthState()
            guard let action = action as? AuthAction else {
                return state
            }
            
            switch action {
            case .finishInitialLoad:
                print("auth loaded")
                state.loadingState = .loaded
            case let .updateAuthChangeListener(cancellable):
                state.listenerCancellable = cancellable
            case let .updateUser(user):
                print("update user")
                state.user = user
            case .signInStarted:
                state.requesting = true
                state.error = nil
            case .signInFinished:
                print("signed in")
                state.requesting = false
                state.error = nil
            case let .signInFailed(error):
                state.requesting = false
                state.error = error
            }
            
            return state
        }
    }
}
