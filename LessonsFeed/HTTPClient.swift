//
//  HTTPClient.swift
//  LessonsFeed
//
//  Created by Nav on 24/04/23.
//

import Foundation

public enum HTTPClientResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
