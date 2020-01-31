//
//  RoomView.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/22.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Foundation
import SwiftUI
import YoutubeKit

// room view
struct RoomView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showSheet: Bool = true
    @State private var roomID: String = ""
    
    private var state: RoomState {
        get {
            return self.store.state.roomState
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Room: \(self.state.room?.data.roomID ?? "---") 予約リスト")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .padding(.bottom, 20.0)
                    
                    Spacer()
                }
            
                ForEach(self.state.room?.tracks ?? []) { track in
                    TrackView(track: track)
                        .padding(.bottom, 10.0)
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: self.$showSheet) {
            VStack {
                Text("部屋の作成")
                    .font(.largeTitle)
                    .bold()
                    .padding(.vertical, 20.0)
                
                Text("プレイリストを共有するための部屋を作成します")
                    .padding()
                    .font(.caption)
                
                TextField("Enter Room ID", text: self.$roomID)
                    .padding()
                
                Button(action: {
                    if !self.roomID.isEmpty {
                        self.store.dispatch(RoomAction.subscribe(roomID: self.roomID))
                        self.showSheet = false
                    }
                }) {
                    Text("部屋に入る")
                }
                .padding()
                .disabled(self.roomID.isEmpty)
                .foregroundColor(.white)
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(10)
                
                Spacer()
            }
        }
    }
}
