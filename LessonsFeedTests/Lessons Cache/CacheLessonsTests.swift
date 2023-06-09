//
//  CacheLessonsTests.swift
//  LessonsFeedTests
//
//  Created by Nav on 25/04/23.
//

import Foundation
import XCTest
import LessonsFeed




class LessonCacheSpy: LessonCache{
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    var deleteCount = 0
    var insertCallCount = 0
    var deletionCompletion = [(Error?) -> Void]()
    var insertionCompletion = [(Error?) -> Void]()
    
    enum ReceivedMessages: Equatable{
        case deleteCache
        case insertCache([LessonFeed])
    }
    var messages = [ReceivedMessages]()
    
    func deleteCache(completion: @escaping DeletionCompletion)
    {
        deleteCount += 1
        messages.append(.deleteCache)
        deletionCompletion.append(completion)
        
    }
    
    func insert(cache: [LessonFeed], completion: @escaping InsertionCompletion)
    {
        insertCallCount += 1
        insertionCompletion.append(completion)
        messages.append(.insertCache(cache))
    }
    
    func completeDeletion(with error: Error?, at index: Int)
    {
        deletionCompletion[index](error)
    }
    
    func completeInsertion(with error: Error?, at index: Int)
    {
        insertionCompletion[index](error)
    }
}


class CacheLessonsTests: XCTestCase{
    func test_init_doesnotDeleteAnySavedCache(){
        let cache = LessonCacheSpy()
        _ = LocalLessonLoader(cache: cache)
        
        XCTAssertEqual(cache.deleteCount, 0)
    }
    
    func test_save_deletesAnyPreviouslySavedCache(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        sut.save(lesson: lessons){_ in}
        XCTAssertEqual(cache.deleteCount, 1)
    }
    
    func test_save_doesnotInsertNewCacheOnDeletionError(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        sut.save(lesson: lessons){_ in}
        cache.completeDeletion(with: anyError(), at: 0)
        XCTAssertEqual(cache.insertCallCount, 0)
    }
    
    func test_save_insertsNewCacheOnDeletionSuccess(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        sut.save(lesson: lessons){_ in}
        cache.completeDeletion(with: nil, at: 0)
        XCTAssertEqual(cache.insertCallCount, 1)
    }
    
    func test_save_insertMethodIsInvokedAfterSuccesfulDeletion(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        let exp = expectation(description: "Wait for cache")
        sut.save(lesson: lessons){ error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        cache.completeDeletion(with: nil, at: 0)
        cache.completeInsertion(with: nil, at: 0)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(cache.messages, [LessonCacheSpy.ReceivedMessages.deleteCache, LessonCacheSpy.ReceivedMessages.insertCache(lessons)])
    }
    
    
    func test_save_failsWithErrorOnDeletionError(){
        let (sut, cache) = makeSUT()
        let lessons = [makeLesson(), makeLesson()]
        let deletionError = anyError()
        var receivedError: Error?
        let exp = expectation(description: "Wait for cache")
        sut.save(lesson: lessons){error in
            XCTAssertNotNil(error)
            receivedError = error
            exp.fulfill()
        }
        
        cache.completeDeletion(with: deletionError, at: 0)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(cache.messages, [.deleteCache])
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }
    
    func test_save_failsWithErrorOnInsertionError(){
            let (sut, cache) = makeSUT()
            let lessons = [makeLesson(), makeLesson()]
            let insertionError = anyError()
            var receivedError: Error?
            let exp = expectation(description: "Wait for cache")
            sut.save(lesson: lessons){error in
                XCTAssertNotNil(error)
                receivedError = error
                exp.fulfill()
            }
            
            cache.completeDeletion(with: nil, at: 0)
            cache.completeInsertion(with: insertionError, at: 0)
            wait(for: [exp], timeout: 1.0)
            XCTAssertEqual(cache.messages, [.deleteCache, .insertCache(lessons)])
            XCTAssertEqual(receivedError as NSError?, insertionError)
        }
    
    func test_save_completesWithNoErrorOnSuccesfullDeletionAndInsertion(){
            let (sut, cache) = makeSUT()
            let lessons = [makeLesson(), makeLesson()]
            let exp = expectation(description: "Wait for cache")
            sut.save(lesson: lessons){error in
                XCTAssertNil(error)
                exp.fulfill()
            }
            
            cache.completeDeletion(with: nil, at: 0)
            cache.completeInsertion(with: nil, at: 0)
            wait(for: [exp], timeout: 1.0)
            XCTAssertEqual(cache.messages, [.deleteCache, .insertCache(lessons)])
        }
    
    func test_save_callBackNotInvokedWhenInstanceDeallocated(){
        let (_, cache) = makeSUT()
        var sut: LocalLessonLoader? = LocalLessonLoader(cache: cache)
        let lessons = [makeLesson(), makeLesson()]
        var receivedErrors = [Error]()
        sut?.save(lesson: lessons){error in
            if let error{
                receivedErrors.append(error)
            }
        }
        sut = nil
        cache.completeDeletion(with: nil, at: 0)
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func makeSUT() -> (LocalLessonLoader, LessonCacheSpy){
        let cache = LessonCacheSpy()
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
