//
//  Store.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/16.
//
// Copyright © Suguru Kishimoto. All rights reserved.
//
// <https://github.com/sgr-ksmt/FireTodo/blob/9d904093c0/FireTodo/Redux/Main/AppStore.swift>

import Foundation
import Combine
import ReSwift
import ReSwiftThunk

final class AppStore: StoreSubscriber, DispatchingStoreType, ObservableObject {
    private let store: Store<AppState>
    var state: AppState { store.state }
    private(set) var objectWillChange: ObservableObjectPublisher = .init()
    
    init(_ store: Store<AppState>) {
        self.store = store
        print("store subscribe")
        store.subscribe(self)
    }
    
    func newState(state: AppState) {
        objectWillChange.send()
    }
    
    func dispatch(_ action: Action) {
        if Thread.isMainThread {
            store.dispatch(action)
        } else {
            DispatchQueue.main.async { [store] in
                store.dispatch(action)
            }
        }
    }
    
    deinit {
        store.unsubscribe(self)
    }
}

final class AppMain {
    let store: AppStore
    
    init(store: Store<AppState> = makeStore()) {
        print("store init")
        self.store = AppStore(store)
    }
}

private func makeStore() -> Store<AppState> {
    .init(
        reducer: AppReducer.reduce,
        state: AppState(),
        // https://github.com/ReSwift/ReSwift-Thunk/blob/master/README.md
        middleware: [
            createThunkMiddleware()
        ]
    )
}
