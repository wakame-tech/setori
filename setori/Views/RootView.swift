//
//  RootView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/22.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI
import Foundation


// root view
struct RootView: View {
    @EnvironmentObject private var store: AppStore
    
    var body: some View {
        ZStack {
            TabView {
                RoomView()
                    .tabItem {
                        VStack {
                            Image(systemName: "play.rectangle")
                            Text("部屋")
                        }
                }.tag(1)
                
                LibraryView()
                    .tabItem {
                        VStack {
                            Image(systemName: "music.note.list")
                            Text("セトリ")
                        }
                }.tag(2)
                
                 SettingsView()
                    .tabItem {
                        VStack {
                            Image(systemName: "gear")
                            Text("設定")
                        }
                }.tag(3)
            }
            
            VStack {
                Spacer()
                PlayerView()
                    .frame(width: 260, height: 160)
                    .draggable(initialPos: CGPoint(x: 200, y: 400))
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
