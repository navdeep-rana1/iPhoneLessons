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
    struct UnexpectedErrorOccured: Error {}
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url){data, response, error in
            if let error = error{
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            }else{
                completion(.failure(UnexpectedErrorOccured()))
            }
            
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
    
    func test_getFromURL_assertThatSUTCanHandleAllInvalidValues(){
        URLProtocolStubs.registerStub()

        let invalidData = Data.init("invalid data".utf8)
        let anyError = anyError()
        let invalidResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 3, textEncodingName: nil)
        XCTAssertNotNil(shouldFailWithError(data: nil, response: nil, error: nil))
        XCTAssertNotNil(shouldFailWithError(data: invalidData, response: nil, error: nil))
        XCTAssertNotNil(shouldFailWithError(data: invalidData, response: nil, error: anyError))
        XCTAssertNotNil(shouldFailWithError(data: invalidData, response: invalidResponse, error: anyError))
        URLProtocolStubs.unRegisterStub()

    }
    
    func test_getFromURL_succeedsWithValidData(){
        URLProtocolStubs.registerStub()
        let response = anyHTTPURLReponse()
        URLProtocolStubs.stub(data: validData(), response: response, error: nil)
        let exp = expectation(description: "Wait for request")
        makeSUT().get(from: URL(string: "http://google.com")!) { result in
            switch result{
            case .failure:
                XCTFail("Expected success but recieved error")
            case let .success(data, receivedResponse):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(data, self.validData())
                XCTAssertEqual(receivedResponse.url, response.url)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStubs.unRegisterStub()

    }
    
    func validData() -> Data{
        Data.init("A valid Data representation from HTTPURL".utf8)
    }
    func anyHTTPURLReponse() -> HTTPURLResponse{
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient{
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(ofInstance: sut, file: file, line: line)
        return sut
    }
    
    private func trackForMemoryLeaks(ofInstance instance: AnyObject, file: StaticString = #file, line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential Memory leak, Instance no deallocated", file: file, line: line)
        }
    }
    
    func shouldFailWithError( data: Data?, response: URLResponse?, error: Error?) -> Error?{
        URLProtocolStubs.registerStub()
        let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
        URLProtocolStubs.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for request to complete")
        var receivedError: NSError?
        makeSUT().get(from: url) { result in
            switch result{
            case .failure(let error as NSError):
                receivedError = error
            default:
                XCTFail("Expected to fail")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStubs.unRegisterStub()
        return receivedError
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
            URLProtocolStubs.stub = nil
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
