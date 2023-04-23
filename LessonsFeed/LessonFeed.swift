//
//  LessonFeed.swift
//  LessonsFeed
//
//  Created by Nav on 23/04/23.
//

import Foundation

struct LessonFeed{
    let id : Int
    let name: String
    let description: String
    let thumbnail: URL
    let videoURL: URL
}


enum LessonLoaderResult{
    case success([LessonFeed])
    case failure(Error)
}

protocol LessonLoader{
    
    func load(completion: @escaping (LessonLoaderResult) -> Void)
}

enum HTTPClientResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

class RemoteLessonLoader{
    private let url: URL
    private let client: HTTPClient
    
    enum Error: Swift.Error{
        case noConnectivity
        case invalidData
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error) -> Void){
        client.get(from: url){result in
            switch result{
            case .success(_, _):
                completion(.invalidData)
            case .failure(_):
                completion(.noConnectivity)
            }
        }
    }
}
