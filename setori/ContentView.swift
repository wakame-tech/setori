//
//  ContentView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/15.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI

struct ChildView: View {
    @EnvironmentObject private var store: AppStore
    
    private var state: RootState {
        get {
            return self.store.state.rootState
        }
    }
    
    var body: some View {
        Text("Hello Setori \(state.info?.version ?? "---")")
    }
}

// root view
struct ContentView: View {
    // injected store
    @EnvironmentObject private var store: AppStore
    
    var body: some View {
        // wrap view
        AnyView({ () -> AnyView in
            return AnyView(ChildView())
        }())
        .onAppear {
            self.store.dispatch(RootAction.subscribe())
        }
        .onDisappear {
            self.store.dispatch(RootAction.unsubscribe())
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppMain().store)
    }
}
