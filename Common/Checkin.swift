//
//  Checkin.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/15/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Check into a movie or episode. This should be tied to a user action to manually indicate they are watching something. The item will display as watching on the site, then automatically switch to watched status once the duration has elapsed.
     
     **Note**: If a checkin is already in progress, a `409` HTTP status code will returned. The response will contain an `expires_at` timestamp which is when the user can check in again.
     */
    @discardableResult
    public func checkIn(movie: RawJSON?, episode: RawJSON?, completionHandler: @escaping SuccessCompletionHandler) -> URLSessionDataTask? {
        
        // JSON
        var json: RawJSON = [
            "app_version": "1.2",
            "app_date": "2016-01-23"
        ]
        
        if let movie = movie {
            json["movie"] = movie
        }
        else if let episode = episode {
            json["episode"] = episode
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions(rawValue: 0))
            
            // Request
            guard var request = mutableRequestForURL(path: "checkin", authorization: true, HTTPMethod: .POST) else { return nil }
            request.httpBody = jsonData
            
            let dataTask = session.dataTask(with: request) { (data, response, error) -> Void in
                guard error == nil else { return completionHandler( .Fail) }
                
                guard
                    let HTTPResponse = response as? HTTPURLResponse,
                    (HTTPResponse.statusCode == StatusCodes.SuccessNewResourceCreated ||
                        HTTPResponse.statusCode == StatusCodes.Conflict) else { return completionHandler( .Fail) }
                
                if HTTPResponse.statusCode == StatusCodes.SuccessNewResourceCreated {
                    // Started watching
                    completionHandler( .Success)
                }
                else { // Already watching something
                    completionHandler( .Fail)
                }
            }
            dataTask.resume()
            
            return dataTask
        }
        catch {
            completionHandler( .Fail)
        }
        
        return nil
    }
    
    /**
     Removes any active checkins, no need to provide a specific item.
     */
    @discardableResult
    public func deleteActiveCheckins(completionHandler: @escaping SuccessCompletionHandler) -> URLSessionDataTask? {
        // Request
        guard let request = mutableRequestForURL(path: "checkin", authorization: true, HTTPMethod: .DELETE) else {
            completionHandler( .Fail)
            return nil
        }
        
        let dataTask = session.dataTask(with: request) { (data, response, error) -> Void in
            guard error == nil else { return completionHandler( .Fail) }
            
            // Check response
            guard
                let HTTPResponse = response as? HTTPURLResponse,
                HTTPResponse.statusCode == StatusCodes.SuccessNoContentToReturn else { return completionHandler( .Fail) }
            
            completionHandler( .Success)
        }
        dataTask.resume()
        
        return dataTask
    }
}
