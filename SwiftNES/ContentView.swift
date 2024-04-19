//
//  ContentView.swift
//  SwiftNES
//
//  Created by Jamie Le Souef on 8/4/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  
  var nes = NES()
  
  @State private var screen: [[NES.Color]] = []
  @State var screenPointer: Int = 0
  
  var body: some View {
    NavigationSplitView {
      List {
        ForEach(items) { item in
          NavigationLink {
            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
          } label: {
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
          }
        }
        .onDelete(perform: deleteItems)
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
    } detail: {
      
      Grid(horizontalSpacing: 0, verticalSpacing: 0) {
        if screen.count > 0 {
          ForEach(0...screen.count-1, id: \.self) { i in
            ForEach(screen[i], id: \.self) { color in
              let c = color.rawValue
              Text("\(c)").font(.custom("Courier", size: 5))
            }
          }
        }
      }
      
      
      Button(action: start) {
        Text("Start")
      }
      
      Button(action: stop) {
        Text("Stop")
      }
    }
    .onAppear {
      nes.screenUpdater = { screen in
        DispatchQueue.main.async {
          // Update the screen
        }
      }
      NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { keyEvent in
        switch keyEvent.type {
        case .keyUp: nes.didReceiveButtonUp(keyCode: keyEvent.keyCode)
        case .keyDown: nes.didReceiveButtonDown(keyCode: keyEvent.keyCode)
        default: return keyEvent
          
        }
        return nil
      }
    }
  }
  
  private func buildScreen(from screen: [NES.Color]) {
    
    var index = 0
    var b: [[NES.Color]] = []
    
    for i in 0x00...0x1f {
      for j in 0x00...0x1f {
        b[i][j] = screen[index]
        index += 1
      }
    }
    
    self.screen = b
  }
  
  private func start() {
    DispatchQueue.global(qos: .userInteractive).async {
      nes.powerOn()
    }
  }
  
  func stop() {
    DispatchQueue.global(qos: .userInteractive).async {
      nes.powerOff()
    }
  }
  private func addItem() {
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
