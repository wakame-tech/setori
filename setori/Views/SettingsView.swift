//
//  SettingsView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/31.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI
import Foundation

struct SettingsView: View {
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
        NavigationView {
            VStack {
                Text("uid: \(user?.uid ?? "---")")
                    .padding()
                
                Divider()
                
                Text("name: \(user?.name ?? "---")")
                    .padding()
                
                Divider()
                
                Text("バージョン \(state.info?.version ?? "---")")
                    .padding()
                
                Divider()
                
                Button(action: {
                    self.store.dispatch(AuthAction.signOut())
                }) {
                    Text("ログアウト")
                        .foregroundColor(.red)
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            self.store.dispatch(RootAction.subscribe())
        }
        .onDisappear {
            self.store.dispatch(RootAction.unsubscribe())
        }
    }
}
