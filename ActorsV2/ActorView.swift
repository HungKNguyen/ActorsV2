//
//  ActorView.swift
//  ActorsV2
//
//  Created by Hung K Nguyen on 03/11/2022.
//

import SwiftUI

struct ActorView: View {
  @Environment(\.defaultMinListRowHeight) var minRowHeight
  let id : String
  @State var actorBio : ActorBio = ActorBio()
  @State var favorited = false
  var body: some View {
    ScrollView {
      VStack {
        HStack {
          Text(actorBio.name).font(.title)
          Spacer()
          Button {
            if favorited {
              AppData.instance.removeFromFavorite(id: id)
            } else {
              AppData.instance.addToFavorite(id: id, name: actorBio.name)
            }
            AppData.instance.saveChanges()
            favorited = !favorited
          } label: {
            if favorited {
              Image(systemName: "heart.rectangle.fill")
            } else {
              Image(systemName: "heart.rectangle")
            }
          }.font(.title)
        }.padding()
        VStack {
          AsyncImage(url: URL(string: actorBio.image))  { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .scaledToFill()
            default:
              Image(systemName: "photo")
            }
          }.padding(EdgeInsets(top: 0, leading: 100, bottom: 0, trailing: 100))
          Text(actorBio.summary)
            .padding()
          Text("Known For:").font(.title3)
          List {
            ForEach(actorBio.knownFor) { role in
              NavigationLink(destination: SeriesMovieView(id: role.id)) {
                HStack {
                  Text(role.title)
                  Spacer()
                  Text("-")
                  Spacer()
                  Text(role.role).font(.caption)
                }
              }
            }
          }.frame(minHeight: minRowHeight * (CGFloat(actorBio.knownFor.count) + 1))
        }
      }
    }
    .onAppear {
      AppData.instance.getActorBio(id:id) { result in
        switch result {
        case .success(let data):
          actorBio = data
          favorited = AppData.instance.isFavorite(id: id)
        case .failure(let error):
          switch error {
          case .TransportError:
            print("Transport Error")
          case .HTTPError(let status):
            print("HTTP Status \(status)")
          case .JSONError:
            print("Cannot convert from JSON")
          case.ServerError(let message):
            print("Server error: \(message)")
          }
        }
      }
    }
  }
}

struct ActorView_Previews: PreviewProvider {
  static var previews: some View {
    ActorView(id: "")
  }
}
