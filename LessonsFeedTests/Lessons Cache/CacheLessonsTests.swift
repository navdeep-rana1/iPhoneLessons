//
//  CacheLessonsTests.swift
//  LessonsFeedTests
//
//  Created by Nav on 25/04/23.
//

import Foundation
import XCTest
import LessonsFeed

class LocalLessonLoader{
    private let cache: LessonCache
    
    init(cache: LessonCache) {
        self.cache = cache
    }
    func save(lesson: [LessonFeed]){
        cache.deleteCache{ [weak self] error in
            if error == nil{
                self?.cache.insert(cache: lesson)
            }
        }
    }
    
}


class LessonCache{
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCount = 0
    var insertCallCount = 0
    var deletionCompletion = [(Error?) -> Void]()
    
    func deleteCache(completion: @escaping (Error?) -> Void){
        deleteCount += 1
        deletionCompletion.append(completion)
        
    }
    
    func insert(cache: [LessonFeed]){
        insertCallCount += 1
    }
    
    func completeDeletion(with error: Error?, at index: Int){
        deletionCompletion[index](error)
    }
}


class CacheLessonsTests: XCTestCase{
    func test_init_doesnotDeleteAnySavedCache(){
        let cache = LessonCache()
        _ = LocalLessonLoader(cache: cache)
        
        XCTAssertEqual(cache.deleteCount, 0)
    }
    
    func test_save_deletesAnyPreviouslySavedCache(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        sut.save(lesson: lessons)
        XCTAssertEqual(cache.deleteCount, 1)
    }
    
    func test_save_doesnotInsertNewCacheOnDeletionError(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        sut.save(lesson: lessons)
        cache.completeDeletion(with: anyError(), at: 0)
        XCTAssertEqual(cache.insertCallCount, 0)
    }
    
    func test_save_insertsNewCacheOnDeletionSuccess(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        sut.save(lesson: lessons)
        cache.completeDeletion(with: nil, at: 0)
        XCTAssertEqual(cache.insertCallCount, 1)
    }
    
    
    func makeSUT() -> (LocalLessonLoader, LessonCache){
        let cache = LessonCache()
        let sut = LocalLessonLoader(cache: cache)
        return (sut, cache)
    }
    
    func makeLesson() -> LessonFeed{
        let random = Int.random(in: 100..<1000)
        return LessonFeed(id: random, name: "A name for lesson", description: "A lesson description", thumbnail: anyURL(), videoURL: anyURL())
    }
    
    func anyURL() -> URL{
        return URL(string: "http://anyurl.com")!
    }
    
    func anyError() -> NSError{
        NSError(domain: "Any error", code: 10)
    }
                          
}
