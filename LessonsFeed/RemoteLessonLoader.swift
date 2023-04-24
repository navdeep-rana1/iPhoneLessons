//
//  RemoteLessonLoader.swift
//  LessonsFeed
//
//  Created by Nav on 24/04/23.
//

import Foundation

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
        client.get(from: url){ result in
            switch result{
            case let .success(data, response):
                if let lessons = try? RemoteLessonsLocalFeed.lessonMapper(data: data, response: response){
                    completion(.success(lessons.toFeedLesson()))
                }else{
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                completion(.failure(.noConnectivity))
            }
        }
    }
}

struct Root: Codable{
    let lessons: [LocalLesson]
}
struct LocalLesson{
    public let id : Int
    public let name: String
    public let description: String
    public let thumbnail: URL
    public let videoURL: URL

}

extension LocalLesson: Codable{
    private enum CodingKeys: String, CodingKey{
        case id
        case name
        case description
        case thumbnail
        case videoURL = "video_url"
    }
}

 class RemoteLessonsLocalFeed{
    static func lessonMapper(data: Data, response: HTTPURLResponse) throws -> [LocalLesson]{
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else{
            throw RemoteLessonLoader.Error.invalidData
        }
        
        return root.lessons
    }
     
}

extension Array where Element == LocalLesson{
    func toFeedLesson() -> [LessonFeed]{
        return map{ LessonFeed(id: $0.id, name: $0.name, description: $0.description, thumbnail: $0.thumbnail, videoURL: $0.videoURL)}
    }
}
