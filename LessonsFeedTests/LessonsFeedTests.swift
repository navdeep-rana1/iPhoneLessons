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
        let (sut, client) = makeSUT()
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
        
        sut.load{ receivedError = $0 }
        client.complete(with: anyError())
        XCTAssertEqual(receivedError, .noConnectivity)
        
    }
    
    func test_load_deliversInvalidDataOn200StatusCode(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        var receivedError: RemoteLessonLoader.Error?
        
        sut.load{ receivedError = $0 }
        
        let invalidData = Data(bytes: "Invalid data".utf8)
        client.complete(with: 200, data: invalidData)
        XCTAssertEqual(receivedError, .invalidData)
        
    }
    
    func test_load_deliversInvalidDataOnNon200StatusCode(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let sampleCodes = [199, 201, 404, 500, 504]
        var receivedError = [RemoteLessonLoader.Error]()
        
        
        let invalidData = Data(bytes: "Invalid data".utf8)
        
        sampleCodes.enumerated().forEach{ index, element in
            sut.load{ error in
                receivedError.append(error)
            }
            client.complete(with: element, data: invalidData, at: index)
            XCTAssertEqual(receivedError, [.invalidData])
            receivedError = []
        }
        
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
