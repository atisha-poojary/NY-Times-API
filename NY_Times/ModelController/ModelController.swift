 //
//  ModelController.swift
//  NY_Times
//
//  Created by Atisha Poojary on 10/24/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

 import UIKit
 import SystemConfiguration

 public protocol APIMethodDelegate {
    func isInternetAvailable() -> Bool
    func getRequest(withParameter url: String, param: Dictionary<String, Any>, completion:@escaping ((AnyObject) -> ()))
 }
 
 public protocol DateDelegate {
    func dateConverter(isoDate: String) -> String
 }
 
 public protocol UIImageViewDelegate {
    func downloadedFromLink(link: String, contentMode mode: UIViewContentMode)
    func downloadedFromURL(url: URL, contentMode mode: UIViewContentMode)
 }
 
 class ModelController: APIMethodDelegate, DateDelegate{
    func isInternetAvailable() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func getRequest(withParameter url: String, param: Dictionary<String, Any>, completion:@escaping ((AnyObject) -> ())){
        let url: NSURL = NSURL(string: url)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "GET"
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

 
 extension UIImageView: UIImageViewDelegate {
    public func downloadedFromLink(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFromURL(url: url, contentMode: mode)
    }
    
    public func downloadedFromURL(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
                
            }
            }.resume()
    }
 }

