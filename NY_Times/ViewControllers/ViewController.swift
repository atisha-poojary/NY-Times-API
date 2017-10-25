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
    
    var cache:NSCache<AnyObject, AnyObject>!
    var resultArray: NSArray = []
    let apiKey = "4ff00b29642f478cb1e55487aa7dd1f7"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cache = NSCache()
        self.refreshTableView()
    }
    
    func refreshTableView(){
        ModelController().postRequest(withParameter: "http://api.nytimes.com/svc/news/v3/content/all/all.json?limit=5&offset=50&api-key=\(apiKey)", param: [:]){(result) -> () in
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
                if let message = result["message"] as? String{
                    DispatchQueue.main.async{
                        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
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
            if let multimediaArr = dataDict["multimedia"] as? NSArray {
                for multimediaDict in multimediaArr{
                    let dict: [String:AnyObject] = multimediaDict as! [String:AnyObject]
                    if dict["format"] as! String == "mediumThreeByTwo440"{
                        cell.thumbnailImage.downloadedFrom(link: dict["url"] as! String)
                    }
                }
            }
        }
        cell.dateLabel.text = ModelController().dateConverter(isoDate:(dataDict["published_date"] as! String))
        cell.imageByLabel.text = (dataDict["byline"] as! String)
        cell.descriptionLabel.text = "\((dataDict["title"] as! String)) \n\((dataDict["abstract"] as! String))"
        
        let attributedString = NSMutableAttributedString(string:"\((dataDict["title"] as! String))\n")
        
        let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17.0)]
        let abstract = NSMutableAttributedString(string:(dataDict["abstract"] as! String), attributes:attrs)
        attributedString.append(abstract)

        cell.descriptionLabel.attributedText = attributedString
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dataDict: [String:AnyObject] = self.resultArray[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.urlString = (dataDict["url"] as! String)
        self.navigationController?.show(vc, sender: nil)
    }
}
