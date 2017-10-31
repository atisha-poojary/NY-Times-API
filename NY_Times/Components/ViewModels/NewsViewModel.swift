//
//  NewsViewModel.swift
//  NY_Times
//
//  Created by Atisha Poojary on 31/10/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import Foundation

public protocol DateDelegate {
    func dateConverter(isoDate: String) -> String
}
class NewsViewModel: DateDelegate {
    
    var connection = Connection()
    var news = [News]()
    
    let apiKey = "4ff00b29642f478cb1e55487aa7dd1f7"
    var pageNo:Int=0
    var limit:Int=20
    var offset:Int=0
    
    func fetchNews(completion: ()->()){
        connection.makeAPICall(withParameter: "http://api.nytimes.com/svc/news/v3/content/all/all.json?limit=\(limit)&offset=\(offset)&api-key=\(apiKey)", param: [:]){ result in
            
            if let status = result["status"] as? String{
                if status == "OK"{
                    self.news = self.parseResult(result: result["results"] as! [AnyObject])
                }
            }
        }
    }
    
    func numberOfItemsInSection(section: Int) -> Int{
        return self.news.count
    }
    
    func parseResult(result: [AnyObject]) -> [News]{
        var parsedNews = [News]()
        for dataDict in result{
            let news = News(slug_name: dataDict["slug_name"] as? String,
                            multimedia: dataDict["multimedia"] as? [AnyObject],
                            format: dataDict["format"] as? String,
                            published_date: dataDict["published_date"] as? String,
                            byline: dataDict["byline"] as? String,
                            title: dataDict["title"] as? String,
                            abstract: dataDict["abstract"] as? String,
                            url: dataDict["url"] as? String)
            
            parsedNews.append(news)
        }
        return parsedNews
    }
    
    func dateConverter(isoDate: String) -> String {
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "dd MMM"
        
        guard let date = inputDateFormatter.date(from: isoDate) else {
            return ""
        }
        
        let resultString = outputDateFormatter.string(from: date)
        return resultString
    }
}
