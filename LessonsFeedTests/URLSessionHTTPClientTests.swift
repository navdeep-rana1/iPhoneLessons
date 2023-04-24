//
//  URLSessionHTTPClientTests.swift
//  LessonsFeedTests
//
//  Created by Nav on 24/04/23.
//
import Foundation
import XCTest
import LessonsFeed

class URLSessionHTTPClient: HTTPClient{
    private let session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url){_, _, error in
            guard error != nil else { return }
            completion(.failure(error!))
            
        }.resume()
    }

}

final class URLSessionHTTPClientTests: XCTestCase {

    
    
    func test_getFromURL_assertCorrectRequestWithRightURLisInvoked(){
        URLProtocolStubs.registerStub()
        let exp = expectation(description: "Wait for request")

        URLProtocolStubs.observeRequest = { request in
            XCTAssertEqual(request.url, URL(string: "https://iphonephotographyschool.com/test-api/lessons")!)
            XCTAssertEqual(request.httpMethod, "GET")
        
            exp.fulfill()
        }
        
        makeSUT().get(from: anyURL()) { _ in
        }
        
        wait(for: [exp], timeout: 1)
        URLProtocolStubs.unRegisterStub()
        
    }
    func test_getFromURL_failsOnRequestError(){
        URLProtocolStubs.registerStub()
        let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
        let error = anyError()
        URLProtocolStubs.stub(data: nil, response: nil, error: error)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request to complete")
        makeSUT().get(from: url) { result in
            switch result{
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
            case .success(_,_):
                XCTFail("Expected failure but got success instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStubs.unRegisterStub()
    }
    
    func test_getFromURL_getsData(){
        URLProtocolStubs.registerStub()
        let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
        let error = anyError()
        URLProtocolStubs.stub(data: nil, response: nil, error: error)
        let exp = expectation(description: "Wait for request to complete")
        makeSUT().get(from: url) { result in
            switch result{
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
            case .success(_,_):
                XCTFail("Expected failure but got success instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStubs.unRegisterStub()
    }
    
    
    func makeSUT() -> HTTPClient{
        return URLSessionHTTPClient()
    }
    func anyError() -> NSError{
        NSError(domain: "Any error", code: 10)
    }
    
    func anyURL() -> URL{
        return URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
    }
    
    private class URLProtocolStubs: URLProtocol{
        private static var stub: Stub?
        private struct Stub{
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?){
            URLProtocolStubs.stub = Stub(data: data, response: response, error: error)
        }
        
        static func registerStub(){
            URLProtocol.registerClass(URLProtocolStubs.self)

        }
        
        static func unRegisterStub(){
            URLProtocol.unregisterClass(URLProtocolStubs.self)
            URLProtocolStubs.observeRequest = nil

        }
        override class func canInit(with request: URLRequest) -> Bool {
            URLProtocolStubs.observeRequest?(request)
           return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        static var observeRequest: ((URLRequest) -> Void)?
        override func startLoading() {
            if let error = URLProtocolStubs.stub?.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            if let data = URLProtocolStubs.stub?.data{
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStubs.stub?.response{
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
    
}
