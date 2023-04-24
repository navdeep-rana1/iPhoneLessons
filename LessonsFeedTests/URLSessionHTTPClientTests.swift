//
//  URLSessionHTTPClientTests.swift
//  LessonsFeedTests
//
//  Created by Nav on 24/04/23.
//
import Foundation
import XCTest
import LessonsFeed

class URLSessionHTTPClient{
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

    func test_getFromURL_failsOnRequestError(){
        URLProtocolStubs.registerStub()
        let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
        let error = anyError()
        URLProtocolStubs.stub(url: url, error: error)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Wait for request to complete")
        sut.get(from: url) { result in
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
    
    func anyError() -> NSError{
        NSError(domain: "Any error", code: 10)
    }
    
    private class URLProtocolStubs: URLProtocol{
        private static var stubs = [URL: Stub]()
        private struct Stub{
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil){
            URLProtocolStubs.stubs[url] = Stub(error: error)
        }
        
        static func registerStub(){
            URLProtocol.registerClass(URLProtocolStubs.self)

        }
        
        static func unRegisterStub(){
            URLProtocol.unregisterClass(URLProtocolStubs.self)

        }
        override class func canInit(with request: URLRequest) -> Bool {
            if let url = request.url{
                return URLProtocolStubs.stubs[url] != nil
            }else{
                return false
            }
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStubs.stubs[url] else { return }
            if let error = stub.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
    
}
