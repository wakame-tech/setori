//
//  RootView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/22.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import SwiftUI
import Foundation

// debug view

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
        VStack {
            Text("Hello Setori \(state.info?.version ?? "---")")
            Text("uid: \(user?.uid ?? "---")")
            Text("name: \(user?.name ?? "---")")
            
            Button(action: {
                self.store.dispatch(RoomAction.createRoom())
            }) {
                Text("Create Room")
            }
        }.onAppear {
            self.store.dispatch(RootAction.subscribe())
        }
        .onDisappear {
            self.store.dispatch(RootAction.unsubscribe())
        }
    }
}

// Handle dragging
struct DraggableView: ViewModifier {
  @State var offset = CGPoint(x: 0, y: 0)

  func body(content: Content) -> some View {
    content
      .gesture(DragGesture(minimumDistance: 0)
        .onChanged { value in
          self.offset.x += value.location.x - value.startLocation.x
          self.offset.y += value.location.y - value.startLocation.y
      })
      .offset(x: offset.x, y: offset.y)
  }
}

// Wrap `draggable()` in a View extension to have a clean call site
extension View {
  func draggable() -> some View {
    return modifier(DraggableView())
  }
}

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
                    .frame(width: 320, height: 160)
                    .draggable()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
