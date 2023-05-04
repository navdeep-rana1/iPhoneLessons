//
//  LessonsFeedTests.swift
//  LessonsFeedTests
//
//  Created by Nav on 23/04/23.
//

import XCTest
@testable import LessonsFeed

final class LessonsFeedTests: XCTestCase {
    
    func test_init_doesnotRequestLoadFromClient(){
        let (_, client) = makeSUT()
        XCTAssertTrue(client.messages.isEmpty)
        
        
    }
    
    func test_load_requestsDataFromURL(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        sut.load{ _ in }
        XCTAssertEqual(client.messages[0].url, url)
    }
    
    func test_load_deliversNoConnectivityErrorOnClientError(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        var receivedError: RemoteLessonLoader.Error?
        
        sut.load{ result in
            switch result{
            case let .failure(error):
                receivedError = error as? RemoteLessonLoader.Error
            case .success(_):
                XCTFail("Expected error got success instead")
            }
        }
        client.complete(with: anyError())
        XCTAssertEqual(receivedError, .noConnectivity)
        
    }
    
    func test_load_deliversInvalidDataOn200StatusCode(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        var receivedError: RemoteLessonLoader.Error?
        
        sut.load{ result in
            switch result{
            case let .failure(error):
                receivedError = error as? RemoteLessonLoader.Error
            case .success(_):
                XCTFail("Expected error got success instead")
            }
        }
        
        let invalidData = Data.init("Invalid data".utf8)
        client.complete(with: 200, data: invalidData)
        XCTAssertEqual(receivedError, .invalidData)
        
    }
    
    func test_load_deliversInvalidDataOnNon200StatusCode(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let sampleCodes = [199, 201, 404, 500, 504]
        let invalidData = Data.init("Invalid data Representation".utf8)
        
        sampleCodes.enumerated().forEach{ index, element in
            var receivedError = [RemoteLessonLoader.Error?]()
            
            sut.load{ result in
                switch result{
                case let .failure(error):
                    receivedError.append(error as? RemoteLessonLoader.Error)
                case .success(_):
                    XCTFail("Expected error got success instead")
                }
            }
            
            client.complete(with: element, data: invalidData, at: index)
            XCTAssertEqual(receivedError, [.invalidData])
        }
        
    }
    
    func test_load_deliversEmptyJsonOn200StatusCode(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        var receivedLessonFeed: [LessonFeed]?
        sut.load{ result in
                  switch result{
                  case let .failure(error):
                      XCTAssertNil(error)
                  case let .success(feed):
                      receivedLessonFeed = feed

                  }
              }
        
        let emptyJson = Data.init("{\"lessons\" : []}".utf8)
        client.complete(with: 200, data: emptyJson)
        XCTAssertEqual(receivedLessonFeed, [])
        
    }
    
    
    func test_load_deliversLessonsOnStatusCode200WithValidData(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        let item1 = LessonFeed(id: 32, name: "some lesson", description: "some description", thumbnail: anyURL(), videoURL: anyURL())
        let item1Json = ["id": item1.id,
                         "name": item1.name,
                         "description": item1.description,
                         "thumbnail": item1.thumbnail.absoluteString,
                         "video_url": item1.videoURL.absoluteString] as! [String : Any]
        let item2 = LessonFeed(id: 342, name: "some other lesson", description: "some description", thumbnail: anyURL(), videoURL: anyURL())
        
        let item2Json = ["id": item2.id,
                         "name": item2.name,
                         "description": item2.description,
                         "thumbnail": item2.thumbnail.absoluteString,
                         "video_url": item2.videoURL.absoluteString] as! [String : Any]
        
        
        let arrayItems = ["lessons": [item1Json, item2Json]]
        let exp = expectation(description: "Wait for request")
        sut.load{ result in
            switch result{
            case let .success(lessons):
                XCTAssertEqual(lessons, [item1, item2])
            case .failure(_):
                XCTFail("Expected result with success but got failure")
            }
            exp.fulfill()
            
        }
        
        let jsonArray = try? JSONSerialization.data(withJSONObject: arrayItems,options: .fragmentsAllowed)
        
        client.complete(with: 200, data: jsonArray!)
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func makeLessonItemJSON() -> [String: Any]{
        let lesson = LessonFeed(id: 32, name: "some lesson", description: "some description", thumbnail: anyURL(), videoURL: anyURL())
        return ["id": lesson.id,
                "name": lesson.name,
                "description": lesson.description,
                "thumbnail": lesson.thumbnail,
                "video_url": lesson.videoURL]
    }
    
    func makeSUT(url: URL = URL(string: "http://anyurl.com")!) -> (RemoteLessonLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteLessonLoader(url: url, client: client)
        return (sut, client)
    }
   
    func anyURL() -> URL{
        return URL(string: "http://anyurl.com")!
    }
    
    func anyError() -> NSError{
        NSError(domain: "Any error", code: 10)
    }
    
    class HTTPClientSpy: HTTPClient{
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
        {
            messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0){
            messages[index].completion(.failure(error))
        }
         
        func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0){
            let urlResponse = HTTPURLResponse(url: messages[index].url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(.success(data, urlResponse))
        }
        
        
    }
    
}
