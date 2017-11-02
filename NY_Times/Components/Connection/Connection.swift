//
//  Connection.swift
//  NY_Times
//
//  Created by Atisha Poojary on 31/10/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import Foundation

class Connection {
    
    func makeAPICall(withParameter url: String, param: Dictionary<String, Any>, completion:@escaping ((AnyObject) -> ())){
        let url: NSURL = NSURL(string: url)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod =  "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if !param.isEmpty{
            request.httpBody = try! JSONSerialization.data(withJSONObject: param, options: [])
        }
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if response == nil {
                completion("request nil" as AnyObject)
            }
            do {
                if data != nil{
                    let json = try JSONSerialization.jsonObject(with: data! as Data, options:.allowFragments)
                    if let dict = json as? NSDictionary {
                        completion(dict as AnyObject)
                    }
                }
            }
            catch let error as NSError {
                completion(error as AnyObject)
            }
        }
        task.resume()
    }
}


