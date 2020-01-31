//
//  Draggable.swift
//  setori
//
//  Created by 鎌田大己 on 2020/01/31.
//  Copyright © 2020 wakame-tech. All rights reserved.
//

import Foundation
import SwiftUI

// Handle dragging
// TODO: calclate offset
// TODO: region restrict
struct DraggableView: ViewModifier {
    @State private var validPos: CGPoint = .zero
    @State private var pos: CGPoint = .zero
    @State private var offset: CGPoint = .zero
    @State private var overLimit: Bool = false
    
    init(initialPos: CGPoint) {
        self.pos = initialPos
    }
    
    func isSafe(region: CGRect, location: CGPoint) -> Bool {
        return region.contains(location)
    }
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .position(self.pos)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            let rect = geometry.frame(in: .global)
                            self.offset = CGPoint(
                                x: value.location.x - rect.origin.x,
                                y: value.location.y - rect.origin.y
                            )
                            self.pos = value.location
                            if !self.overLimit && !self.isSafe(region: rect, location: value.location) {
                                self.overLimit = true
                                self.validPos =  value.location
                            }
                        }
                        .onEnded { value in
                            let rect = geometry.frame(in: .global)
                            print(value.location)
                            let nowSafe = self.isSafe(region: rect, location: value.location)
                            
                            // はみ出ないようにする
                            if self.overLimit && !nowSafe {
                                self.pos = CGPoint(
                                    x: self.validPos.x + self.offset.x,
                                    y: self.validPos.y + self.offset.y
                                )
                            }
                            self.overLimit = false
                        }
                )
        }
  }
}

// Wrap `draggable()` in a View extension to have a clean call site
extension View {
    func draggable(initialPos: CGPoint) -> some View {
        return modifier(DraggableView(initialPos: initialPos))
    }
}
