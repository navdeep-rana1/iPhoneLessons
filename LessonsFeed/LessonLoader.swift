//
//  LessonLoader.swift
//  LessonsFeed
//
//  Created by Nav on 24/04/23.
//

import Foundation

public enum LessonLoaderResult{
    case success([LessonFeed])
    case failure(Error)
}

public protocol LessonLoader{
    
    func load(completion: @escaping (LessonLoaderResult) -> Void)
}
