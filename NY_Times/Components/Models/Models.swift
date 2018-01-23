//
//  Models.swift
//  NY_Times
//
//  Created by Atisha Poojary on 23/01/18.
//  Copyright © 2018 Atisha Poojary. All rights reserved.
//

import UIKit

struct Result: Codable {
    var status: String?
    var copyright: String?
    var num_results: Int?
    var results: [News]?
}

struct News: Codable {
    var multimedia: MultimediaType?
    var format: String?
    var published_date: String?
    var byline: String?
    var title: String?
    var abstract: String?
    var url: String?
   
}

struct Multimedia: Codable {
    var caption: String?
    var url: String?
}

enum MultimediaType: Codable {
    case array([Multimedia?])
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .array(container.decode(Array.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .string(container.decode(String.self))
            } catch DecodingError.typeMismatch {
                throw DecodingError.typeMismatch(MultimediaType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let array):
            try container.encode(array)
        case .string(let string):
            try container.encode(string)
        }
    }
}
