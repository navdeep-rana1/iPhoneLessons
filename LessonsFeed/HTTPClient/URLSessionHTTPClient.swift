//
//  File.swift
//  LessonsFeed
//
//  Created by Nav on 24/04/23.
//

import Foundation

 extension URLSession: HTTPClient{
    public struct UnexpectedErrorOccured: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        dataTask(with: url){data, response, error in
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
