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
  
  let nes = NES()
  
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
      Text("Select an item")
    }
    .onAppear {
      NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { keyEvent in
        guard let value = Controller.Button(rawValue: keyEvent.keyCode) else {
          return keyEvent
        }
        
        switch keyEvent.type {
        case .keyUp: nes.controller.didReceiveButtonUp(button: value)
        case .keyDown: nes.controller.didReceiveButtonDown(button: value)
        default: return nil
          
        }
        return nil
      }
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
