//
//  News.swift
//  NY_Times
//
//  Created by Atisha Poojary on 10/29/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import UIKit

class News{
    var slug_name: String?
    var multimedia: [AnyObject]?
    var format: String?
    var published_date: String?
    var byline: String?
    var title: String?
    var abstract: String?
    var url: String?
    
    init(slug_name: String?, multimedia: [AnyObject]?, format: String?, published_date: String?, byline: String?, title: String?, abstract: String?, url: String?) {
        
        self.slug_name = slug_name
        self.multimedia = multimedia
        self.format = format
        self.published_date = published_date
        self.byline = byline
        self.title = title
        self.abstract = abstract
        self.url = url
    }
}
