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
