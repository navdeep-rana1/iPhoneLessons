//
//  LessonFeed.swift
//  LessonsFeed
//
//  Created by Nav on 23/04/23.
//

import Foundation

public struct LessonFeed: Equatable{
    public let id : Int
    public let name: String
    public let description: String
    public let thumbnail: URL
    public let videoURL: URL
}


extension LessonFeed: Codable{
    private enum CodingKeys: String, CodingKey{
        case id
        case name
        case description
        case thumbnail
        case videoURL = "video_url"
    }
}
struct Root: Codable{
    let lessons: [LessonFeed]
}

enum LessonLoaderResult{
    case success([LessonFeed])
    case failure(Error)
}

protocol LessonLoader{
    
    func load(completion: @escaping (LessonLoaderResult) -> Void)
}

public enum HTTPClientResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteLessonLoader{
    private let url: URL
    private let client: HTTPClient
    
   public enum Error: Swift.Error{
        case noConnectivity
        case invalidData
    }
    
    public enum Result: Equatable{
        case success([LessonFeed])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void){
        client.get(from: url){result in
            switch result{
            case let .success(data, _):
                if let root = try? JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.lessons))
                }else{
                    completion(.failure(.invalidData))
                }

            case .failure(_):
                completion(.failure(.noConnectivity))
            }
        }
    }
}
