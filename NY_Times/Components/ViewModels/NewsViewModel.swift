//
//  NewsViewModel.swift
//  NY_Times
//
//  Created by Atisha Poojary on 31/10/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import Foundation

fileprivate let apiKey = "4ff00b29642f478cb1e55487aa7dd1f7"
fileprivate let limit = "2"
fileprivate let offset = "2"

public protocol DateDelegate {
    func dateConverter(isoDate: String) -> String
}
class NewsViewModel: DateDelegate {
    static func fetchResult(_ completionHandler: @escaping (Result) -> ()) {
        let urlString = "http://api.nytimes.com/svc/news/v3/content/all/all.json?limit=\(limit)&offset=\(offset)&api-key=\(apiKey)"
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            guard let data = data else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Result.self, from: data)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    completionHandler(result)
                })
                
            } catch let err {
                print(err)
            }
            
        }) .resume()
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
