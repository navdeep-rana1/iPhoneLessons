//
//  CacheLessonsTests.swift
//  LessonsFeedTests
//
//  Created by Nav on 25/04/23.
//

import Foundation
import XCTest

class LocalLessonLoader{
    private let cache: LessonCache
    init(cache: LessonCache) {
        self.cache = cache
    }
    func save(){
        cache.deleteCount += 1
    }
    
}
class LessonCache{
    var deleteCount = 0
}


class CacheLessonsTests: XCTestCase{
    func test_init_doesnotDeleteAnySavedCache(){
        let cache = LessonCache()
        _ = LocalLessonLoader(cache: cache)
        
        XCTAssertEqual(cache.deleteCount, 0)
    }
    
    func test_save_deletesAnyPreviouslySavedCache(){
        let (sut, cache) = makeSUT()
        sut.save()
        XCTAssertEqual(cache.deleteCount, 1)
    }
    
    func makeSUT() -> (LocalLessonLoader, LessonCache){
        let cache = LessonCache()
        let sut = LocalLessonLoader(cache: cache)
        return (sut, cache)
    }
}
