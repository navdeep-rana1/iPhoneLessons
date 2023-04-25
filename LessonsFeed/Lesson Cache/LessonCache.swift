//
//  LessonCache.swift
//  LessonsFeed
//
//  Created by Nav on 25/04/23.
//

import Foundation

public protocol LessonCache{
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCache(completion: @escaping DeletionCompletion)
    func insert(cache: [LessonFeed], completion: @escaping InsertionCompletion)
    
}
