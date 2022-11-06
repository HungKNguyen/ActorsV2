//
//  SeriesMovieView.swift
//  ActorsV2
//
//  Created by Hung K Nguyen on 03/11/2022.
//

import SwiftUI

struct SeriesMovieView: View {
  @State var id : String
  @State var seriesData : SeriesData = SeriesData()
  var body: some View {
    VStack {
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
        VStack {
          Text(seriesData.year).font(.title2)
          Spacer()
          Text(seriesData.plot)
          Spacer()
        }.padding()
        VStack {
          AsyncImage(url: URL(string: seriesData.image))  { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .scaledToFill()
            default:
              Image(systemName: "photo")
            }
          }.padding()
        }
      }
      List {
        ForEach(seriesData.actorList) {person in
          NavigationLink(destination: ActorView(id: person.id)) {
            HStack {
              Text(person.asCharacter)
              Spacer()
              Text("(\(person.name))").font(.caption)
            }
          }
        }
      }
      Spacer()
    }.navigationTitle(seriesData.title)
      .onAppear {
        AppData.instance.getMovieSeriesDetails(id:id) { result in
          switch result {
          case .success(let data):
            seriesData = data
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

struct SeriesMovieView_Previews: PreviewProvider {
  static var previews: some View {
    SeriesMovieView(id: "")
  }
}
