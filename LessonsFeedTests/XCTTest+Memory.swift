//
//  XCTTest+Memory.swift
//  LessonsFeed
//
//  Created by Nav on 24/04/23.
//

import Foundation
import XCTest
extension XCTestCase{
     func trackForMemoryLeaks(ofInstance instance: AnyObject, file: StaticString = #file, line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential Memory leak, Instance no deallocated", file: file, line: line)
        }
    }
}
