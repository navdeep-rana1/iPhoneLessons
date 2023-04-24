//
//  LessonFeed.swift
//  LessonsFeed
//
//  Created by Nav on 23/04/23.
//

import Foundation

public struct LessonFeed: Equatable{
    public let id : Int
    public let name: String
    public let description: String
    public let thumbnail: URL
    public let videoURL: URL
    
    public init(id: Int, name: String, description: String, thumbnail: URL, videoURL: URL) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.videoURL = videoURL
    }
}


extension LessonFeed: Codable{
    private enum CodingKeys: String, CodingKey{
        case id
        case name
        case description
        case thumbnail
        case videoURL = "video_url"
    }
}


