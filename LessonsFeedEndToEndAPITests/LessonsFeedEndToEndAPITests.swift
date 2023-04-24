//
//  LessonsFeedEndToEndAPITests.swift
//  LessonsFeedEndToEndAPITests
//
//  Created by Nav on 24/04/23.
//

import XCTest
import LessonsFeed

final class LessonsFeedEndToEndAPITests: XCTestCase {

    func test_get_loadsLessonsFromAPI(){
        let (sut, client) = makeSUT()
        var receivedFeed = [LessonFeed]()
        let exp = expectation(description: "Wait for request to complete")
        sut.load { result in
            switch result{
            case let .success(feed):
                receivedFeed = feed
            case let .failure(error):
                XCTAssertNil(error)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)

        XCTAssertEqual(receivedFeed[0].name, "The Key To Success In iPhone Photography")
    }
    
    func makeSUT(url: URL = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!) -> (RemoteLessonLoader, URLSessionHTTPClient){
        let client = URLSessionHTTPClient()
        let sut = RemoteLessonLoader(url: url, client: client)
        return (sut, client)
    }
    
}
