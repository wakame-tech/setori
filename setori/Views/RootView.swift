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
// TODO: calclate offset
// TODO: region restrict
struct DraggableView: ViewModifier {
    @State private var validPos: CGPoint = .zero
    @State private var pos: CGPoint = .zero
    @State private var offset: CGPoint = .zero
    @State private var overLimit: Bool = false

    func isSafe(region: CGRect, location: CGPoint) -> Bool {
        return region.contains(location)
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            let rect = geometry.frame(in: .global)
                            self.offset = CGPoint(
                                x: value.location.x - rect.origin.x,
                                y: value.location.y - rect.origin.y
                            )
                            self.pos = CGPoint(
                                x: value.location.x + self.offset.x,
                                y: value.location.y + self.offset.y
                            )
//                            self.offset.x += value.translation.width
//                            self.offset.y += value.translation.height
                            if !self.overLimit && !self.isSafe(region: rect, location: value.location) {
                                print("over limit")
                                self.overLimit = true
                                self.validPos =  value.location
                            } else {
                            }
                        }
                        .onEnded { value in
                            let rect = geometry.frame(in: .global)
                            print(value.location)
                            let nowSafe = self.isSafe(region: rect, location: value.location)
                            
                            print("overlimit: \(self.overLimit)")
                            print("nowSafe: \(nowSafe)")
                            
                            if self.overLimit && !nowSafe {
                                print("limit")
                                self.pos = CGPoint(
                                    x: self.validPos.x + self.offset.x,
                                    y: self.validPos.y + self.offset.y
                                )
                            }
                            self.overLimit = false
                        }
                )
                // .offset(x: self.offset.x, y: self.offset.y)
                .position(self.offset)
        }
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
                    .frame(width: 260, height: 160)
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
