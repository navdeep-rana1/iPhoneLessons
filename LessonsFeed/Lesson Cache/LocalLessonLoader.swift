//
//  LocalLessonLoader.swift
//  LessonsFeed
//
//  Created by Nav on 25/04/23.
//

import Foundation

public final class LocalLessonLoader{
    private let cache: LessonCache
    
    public init(cache: LessonCache) {
        self.cache = cache
    }
    
    public func save(lesson: [LessonFeed], completion: @escaping (Error?) -> Void){
        cache.deleteCache{ [weak self] error in
            if error == nil{
                self?.cache.insert(cache: lesson, completion: completion)
            }else{
                completion(error)
            }
        }
    }

    
}
