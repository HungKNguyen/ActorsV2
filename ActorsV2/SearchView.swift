//
//  SearchView.swift
//  ActorsV2
//
//  Created by Hung K Nguyen on 02/11/2022.
//

import SwiftUI

struct SearchView: View {
  @State var searchText : String = ""
  @State var searchReply : SearchReply
  @State var buttonDisabled : Bool = false
  
  private func endEditing() {
    UIApplication.shared.endEditing()
  }
  
  var body: some View {
    VStack {
      TextField("", text: $searchText).textFieldStyle(.roundedBorder).padding()
      HStack {
        Button("Search Movies") {
          buttonDisabled = true
          AppData.instance.doMoviesSearch(text: searchText) { result in
            switch result {
            case .success(let reply):
              searchReply = reply
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
            buttonDisabled = false
          }
        }.buttonStyle(.borderedProminent)
          .padding().disabled(buttonDisabled)
        Spacer()
        Button("Search Series") {
          buttonDisabled = true
          AppData.instance.doSeriesSearch(text: searchText) { result in
            switch result {
            case .success(let reply):
              searchReply = reply
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
            buttonDisabled = false
          }
        }.buttonStyle(.borderedProminent)
          .padding().disabled(buttonDisabled)
      }
      List {
        ForEach(searchReply.results) {res in
          NavigationLink(destination: SeriesMovieView(id: res.id)) {
            Text(res.title)
          }
        }
      }
      Spacer()
    }.onTapGesture(count: 2) {endEditing()}
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView(searchReply: SearchReply())
  }
}
