//
//  News.swift
//  NY_Times
//
//  Created by Atisha Poojary on 10/29/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import UIKit

class News: Decodable {
    var slug_name: String?
    var multimedia: [AnyObject]?
    var format: String?
    var published_date: String?
    var byline: String?
    var title: String?
    var abstract: String?
    var url: String?
}
