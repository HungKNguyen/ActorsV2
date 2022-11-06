//
//  FavView.swift
//  ActorsV2
//
//  Created by Hung K Nguyen on 02/11/2022.
//

import SwiftUI

struct FavView: View {
  @StateObject var data = AppData.instance
  var body: some View {
    VStack {
      List (data.favorites) { person in
        NavigationLink(destination: ActorView(id: person.id)) {
          HStack {
            Text(person.name)
          }
        }
      }
      Spacer()
    }
  }
}

struct FavView_Previews: PreviewProvider {
  static var previews: some View {
    FavView()
  }
}
