//
//  ViewController.swift
//  NY_Times
//
//  Created by Atisha Poojary on 10/19/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
    
    @IBOutlet weak var tableView: UITableView!
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    var resultArray: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        cache = NSCache()
        
        self.refreshTableView()
    }
    
    func refreshTableView(){
        ModelController().postRequest(withParameter: "http://api.nytimes.com/svc/news/v3/content/all/all.json?limit=5&offset=50&api-key=4ff00b29642f478cb1e55487aa7dd1f7", param: [:]){(result) -> () in
            if let status = result["status"] as? String{
                DispatchQueue.main.async{
                    if status == "OK"{
                        self.resultArray = (result["results"] as? NSArray)!
                        self.tableView.reloadData()
                    }
                    else{
                        let alert = UIAlertController(title: "Message", message: "Oops! Server error. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else{
                DispatchQueue.main.async{
                    let alert = UIAlertController(title: "Message", message: "Oops! Server error. Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:CustomTableViewCell = (self.tableView?.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell!)
        
        var dataDict: [String:AnyObject] = self.resultArray[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        if (self.cache.object(forKey: "\(dataDict["slug_name"] as! String)" as AnyObject) != nil){
            cell.thumbnailImage.image = self.cache.object(forKey: "\(dataDict["slug_name"] as! String)" as AnyObject) as? UIImage }
        else{
            let multimediaArr = dataDict["multimedia"] as? NSArray
            for multimediaDict in multimediaArr!{
                let dict: [String:AnyObject] = multimediaDict as! [String:AnyObject]
                if dict["format"] as! String == "mediumThreeByTwo440"{
                    let url:URL! = URL(string: dict["url"] as! String)
                    if url != nil{
                        self.task = self.session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                            if let data = try? Data(contentsOf: url){
                                DispatchQueue.main.async(execute: { () -> Void in
                                    let img:UIImage! = UIImage(data: data)
                                    if img != nil{
                                        self.cache.setObject(img, forKey: "\(dataDict["slug_name"] as! String)" as AnyObject)
                                        cell.thumbnailImage.image = img
                                    }
                                })
                            }
                        })
                        self.task.resume()
                    }
                }
            }
        }
        cell.dateLabel.text = (dataDict["published_date"] as! String)
        cell.imageByLabel.text = (dataDict["byline"] as! String)
        cell.descriptionLabel.text = (dataDict["abstract"] as! String)
       
        return cell
    }
}
