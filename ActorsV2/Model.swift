//
//  Model.swift
//  ActorsV2
//
//  Created by Hung K Nguyen on 02/11/2022.
//

import Foundation

struct SearchResult : Codable, Identifiable {
  let id : String
  let resultType : String
  let image : String
  let title : String
  let description : String
  
  init() {
    id = ""
    resultType = ""
    image = ""
    title = ""
    description = ""
  }
}

struct SearchReply : Codable {
  let searchType : String
  let expression : String
  let results : [SearchResult]
  let errorMessage : String
  
  init() {
    searchType = ""
    expression = ""
    results = []
    errorMessage = ""
  }
}

struct Actor : Codable, Identifiable {
  let id : String
  let image : String
  let name : String
  let asCharacter : String
  
  init() {
    id = ""
    image = ""
    name = ""
    asCharacter = ""
  }
  
  init(withId id : String) {
    self.id = id
    image = ""
    name = ""
    asCharacter = ""
  }
}

struct SeriesData : Codable {
  let id : String
  let title : String
  let year : String
  let image : String
  let plot : String
  let actorList : [Actor]
  
  init() {
    id = ""
    title = ""
    year = ""
    image = ""
    plot = ""
    actorList = []
  }
}

struct Role : Codable, Identifiable {
  let id : String
  let title : String
  let role : String
  
  init() {
    id = ""
    title = ""
    role = ""
  }
}

struct ActorBio : Codable {
  let id : String
  let name : String
  let image : String
  let summary : String
  let knownFor : [Role]
  
  init() {
    id = ""
    name = ""
    image = ""
    summary = ""
    knownFor = []
  }
}

struct Favorite : Codable, Identifiable {
  var id : String
  var name : String
  
  init(id: String, name: String) {
    self.id = id
    self.name = name
  }
}

enum APIError: Error {
  case TransportError
  case JSONError
  case HTTPError(Int)
  case ServerError(String)
}

class AppData : ObservableObject {
  @Published var favorites : [Favorite]
  let cache = URLCache.shared
  static let instance : AppData = AppData()
  let key = "k_40uwx5mm"
  let jsonDecoder = JSONDecoder()
  
  let favoriteArchiveURL: URL = {
    let documentsDirectories =
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = documentsDirectories.first!
    return documentDirectory.appendingPathComponent("favorites.plist")
  }()
  
  init() {
    do {
      let unarchiver = PropertyListDecoder()
      let data = try Data(contentsOf: favoriteArchiveURL)
      let loc = try unarchiver.decode(Array<Favorite>.self, from: data)
      favorites =  loc
    } catch {
      print("Fail to load favorites")
      favorites = []
    }
  }
  
  @discardableResult func saveChanges() -> Bool {
    do {
      let encoder = PropertyListEncoder()
      let data = try encoder.encode(favorites)
      try data.write(to: favoriteArchiveURL)
      return true
    } catch {
      print("Save favorites fail")
      return false
    }
  }
  
  func isFavorite(id: String) -> Bool {
    return favorites.contains(where: {$0.id == id})
  }
  
  func addToFavorite(id: String, name: String) {
    favorites.append(Favorite(id: id, name: name))
  }
  
  func removeFromFavorite(id: String) {
    favorites.removeAll(where: {$0.id == id})
  }
  
  func doSeriesSearch(text : String, callback : @escaping (Result<SearchReply, APIError>) -> Void) {
    let escapedString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    let urlStr = "https://imdb-api.com/en/API/SearchSeries/\(key)/\(escapedString!)"
    let url = URL(string: urlStr)
    let request = URLRequest(url: url!)
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      
      guard error == nil else {
        let result: Result<SearchReply, APIError>
        result = .failure(.TransportError)
        callback(result)
        return
      }
      
      let status = (response as! HTTPURLResponse).statusCode
      guard (200...299).contains(status) else {
        let result: Result<SearchReply, APIError>
        result = .failure(.HTTPError(status))
        callback(result)
        return
      }
      
      let result: Result<SearchReply, APIError>
      do {
        let reply = try self.jsonDecoder.decode(SearchReply.self, from: data!)
        if reply.errorMessage == "" {
          result = .success(reply)
          self.cache.storeCachedResponse(CachedURLResponse(response: response!, data: data!), for: request)
        } else {
          result = .failure(.ServerError(reply.errorMessage))
        }
      } catch {
        result = .failure(.JSONError)
      }
      
      callback(result)
    }
    if let cached = cache.cachedResponse(for: request) {
      print("Cache hit")
      let result: Result<SearchReply, APIError>
      let reply = try! self.jsonDecoder.decode(SearchReply.self, from: cached.data)
      result = .success(reply)
      callback(result)
    } else {
      print("Cache miss")
      task.resume()
    }
  }
  
  func doMoviesSearch(text : String, callback : @escaping (Result<SearchReply, APIError>) -> Void) {
    let escapedString = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    let urlStr = "https://imdb-api.com/en/API/SearchMovie/\(key)/\(escapedString!)"
    let url = URL(string: urlStr)
    let request = URLRequest(url: url!)
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      
      guard error == nil else {
        let result: Result<SearchReply, APIError>
        result = .failure(.TransportError)
        callback(result)
        return
      }
      
      let status = (response as! HTTPURLResponse).statusCode
      guard (200...299).contains(status) else {
        let result: Result<SearchReply, APIError>
        result = .failure(.HTTPError(status))
        callback(result)
        return
      }
      
      let result: Result<SearchReply, APIError>
      do {
        let reply = try self.jsonDecoder.decode(SearchReply.self, from: data!)
        if reply.errorMessage == "" {
          self.cache.storeCachedResponse(CachedURLResponse(response: response!, data: data!), for: request)
          result = .success(reply)
        } else {
          result = .failure(.ServerError(reply.errorMessage))
        }
      } catch {
        result = .failure(.JSONError)
      }
      
      callback(result)
    }
    if let cached = cache.cachedResponse(for: request) {
      print("Cache hit")
      let result: Result<SearchReply, APIError>
      let reply = try! self.jsonDecoder.decode(SearchReply.self, from: cached.data)
      result = .success(reply)
      callback(result)
    } else {
      print("Cache miss")
      task.resume()
    }
  }
  
  func getMovieSeriesDetails(id : String, callback : @escaping (Result<SeriesData, APIError>) -> Void) {
    let urlStr = "https://imdb-api.com/en/API/Title/\(key)/\(id)/FullActor,"
    let url = URL(string: urlStr)
    let request = URLRequest(url: url!)
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      
      guard error == nil else {
        let result: Result<SeriesData, APIError>
        result = .failure(.TransportError)
        callback(result)
        return
      }
      
      let status = (response as! HTTPURLResponse).statusCode
      guard (200...299).contains(status) else {
        let result: Result<SeriesData, APIError>
        result = .failure(.HTTPError(status))
        callback(result)
        return
      }
      
      let result: Result<SeriesData, APIError>
      do {
        let reply = try self.jsonDecoder.decode(SeriesData.self, from: data!)
        self.cache.storeCachedResponse(CachedURLResponse(response: response!, data: data!), for: request)
        result = .success(reply)
      } catch {
        result = .failure(.JSONError)
      }
      
      callback(result)
    }
    if let cached = cache.cachedResponse(for: request) {
      print("Cache hit")
      let result: Result<SeriesData, APIError>
      let reply = try! self.jsonDecoder.decode(SeriesData.self, from: cached.data)
      result = .success(reply)
      callback(result)
    } else {
      print("Cache miss")
      task.resume()
    }
  }
  
  func getActorBio(id: String, callback : @escaping (Result<ActorBio, APIError>) -> Void) {
    let urlStr = "https://imdb-api.com/en/API/Name/\(key)/\(id)"
    let url = URL(string: urlStr)
    let request = URLRequest(url: url!)
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
      
      guard error == nil else {
        let result: Result<ActorBio, APIError>
        result = .failure(.TransportError)
        callback(result)
        return
      }
      
      let status = (response as! HTTPURLResponse).statusCode
      guard (200...299).contains(status) else {
        let result: Result<ActorBio, APIError>
        result = .failure(.HTTPError(status))
        callback(result)
        return
      }
      
      let result: Result<ActorBio, APIError>
      do {
        let bio = try self.jsonDecoder.decode(ActorBio.self, from: data!)
        self.cache.storeCachedResponse(CachedURLResponse(response: response!, data: data!), for: request)
        result = .success(bio)
      } catch {
        result = .failure(.JSONError)
      }
      callback(result)
    }
    if let cached = cache.cachedResponse(for: request) {
      print("Cache hit")
      let result: Result<ActorBio, APIError>
      let bio = try! self.jsonDecoder.decode(ActorBio.self, from: cached.data)
      result = .success(bio)
      callback(result)
    } else {
      print("Cache miss")
      task.resume()
    }
  }
}
