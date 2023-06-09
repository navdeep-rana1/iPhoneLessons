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
        let (sut, _) = makeSUT()
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

        XCTAssertEqual(receivedFeed.count, 11, "Expected 11 items from the backend")
        XCTAssertEqual(receivedFeed[0].name, lessonAt(index: 0).name)
        XCTAssertEqual(receivedFeed[1].name, lessonAt(index: 1).name)
        XCTAssertEqual(receivedFeed[2].name, lessonAt(index: 2).name)
        XCTAssertEqual(receivedFeed[9].name, lessonAt(index: 9).name)
        XCTAssertEqual(receivedFeed[10].name, lessonAt(index: 10).name)
    }
    
    func makeSUT(url: URL = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!) -> (RemoteLessonLoader, HTTPClient){
        let client = URLSession.shared
        let sut = RemoteLessonLoader(url: url, client: client)
        trackForMemoryLeaks(ofInstance: sut)
        return (sut, client)
    }
    
    private func lessonAt(index: Int) -> LessonFeed{
        return LessonFeed(id: arrayIDs[index], name: arrayNames[index], description: "some description", thumbnail: anyURL(), videoURL: anyURL())
    }
    
    let arrayNames = ["The Key To Success In iPhone Photography",
                      "How To Choose The Correct iPhone Camera Lens",
                      "5 Unique Ways To Release The iPhone's Shutter",
                      "3 Secret iPhone Camera Features For Perfect Focus",
                      "Setting The Correct Exposure For Your Photos",
                      "How To Pick The Correct iPhone Camera Settings",
                      "How To Preserve Your Memories With iPhone Live Photos",
                      "How To Capture Stunning Long Exposure Photos",
                      "How To Take Outstanding Panoramic iPhone Photos",
                      "How To Capture Unique iPhone Street Photography",
                      "Secrets For Capturing Beautiful iPhone Portrait Photos"]
    
    let arrayIDs = [950, 7991, 1486, 3657, 400, 851, 3722, 3679, 2372, 4850, 5630]
    
    func anyURL() -> URL{
        return URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
    }
}
