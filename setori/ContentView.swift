//
//  ContentView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/15.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI
import Foundation

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
