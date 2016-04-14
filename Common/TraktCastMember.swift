//
//  TraktCastMember.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct CastMember: TraktProtocol {
    public let character: String
    public let person: Person
    
    // Initialize
    public init?(json: RawJSON?) {
        guard let json = json,
            character = json["character"] as? String,
            person = Person(json: json["person"] as? RawJSON) else { return nil }
        
        self.character = character
        self.person = person
    }
}
