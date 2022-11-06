//
//  ContentView.swift
//  ActorsV2
//
//  Created by Hung K Nguyen on 02/11/2022.
//

import SwiftUI

struct MainView: View {
  @Environment(\.scenePhase) var scenePhase
  @State var selection = 1
  var body: some View {
    NavigationView {
      TabView(selection: $selection) {
        SearchView(searchReply: SearchReply())
          .tabItem {
            Label("Search", systemImage: "questionmark")
          }.tag(1)
        FavView()
          .tabItem {
            Label("Favorite", systemImage: "heart.fill")
          }.tag(2)
      }.navigationTitle(selection == 1 ? "Search" : "Favorites")
    }.onChange(of: scenePhase) { newPhase in
      if newPhase == .background {
        AppData.instance.saveChanges()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
