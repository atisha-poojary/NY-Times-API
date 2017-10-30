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
    
    let apiKey = "4ff00b29642f478cb1e55487aa7dd1f7"
    var cache:NSCache<AnyObject, AnyObject>!
    var refreshCtrl = UIRefreshControl()
    var pageNo:Int=0
    var limit:Int=20
    var offset:Int=0
    var newsArr = [News]()
    let modelClass = ModelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cache = NSCache()
        refreshCtrl.addTarget(self, action: #selector(self.refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshCtrl)
        reloadTableView(limit: "20", offset: "0")
    }
    
    @objc func refreshTableView(){
        reloadTableView(limit: "20", offset: "0")
    }
    
    @objc func reloadTableView(limit: String, offset: String){
        callNewsWireAPI(limit, offset)
    }
    
    func callNewsWireAPI(_ limit: String, _ offset: String){
        ModelController().getRequest(withParameter: "http://api.nytimes.com/svc/news/v3/content/all/all.json?limit=\(limit)&offset=\(offset)&api-key=\(apiKey)", param: [:]){(result) -> () in
            if let status = result["status"] as? String{
                if status == "OK"{
                    self.parseResult(result:(result["results"] as? [AnyObject])!)
                }
                else{
                    self.showError(message: "Oops! Server error. Please try again later.")
                }
            }
            else{
                if let message = result["message"] as? String{
                    self.showError(message: message)
                }
                else{
                    self.showError(message: "Oops! Server error. Please try again later.")
                }
            }
        }
    }
    
    func parseResult(result: [AnyObject]){
        for dataDict in result{
            let news = News(slug_name: dataDict["slug_name"] as? String,
                            multimedia: dataDict["multimedia"] as? [AnyObject],
                            format: dataDict["format"] as? String,
                            published_date: dataDict["published_date"] as? String,
                            byline: dataDict["byline"] as? String,
                            title: dataDict["title"] as? String,
                            abstract: dataDict["abstract"] as? String,
                            url: dataDict["url"] as? String)
            
            newsArr.append(news)
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
            self.refreshCtrl.endRefreshing()
        }
    }
    
    func showError(message: String){
        DispatchQueue.main.async{
            let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = (self.tableView?.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell!)
        
        let news = self.newsArr[indexPath.row]
        
        if (self.cache.object(forKey: "\(news.slug_name!)" as AnyObject) != nil){
            cell.thumbnailImage.image = self.cache.object(forKey: "\(news.slug_name!)" as AnyObject) as? UIImage }
        else{
            if let multimediaArr: [AnyObject] = news.multimedia {
                for multimediaDict in multimediaArr{
                    let dict: [String:AnyObject] = multimediaDict as! [String:AnyObject]
                    if dict["format"] as! String == "mediumThreeByTwo440"{
                        cell.thumbnailImage.downloadedFromLink(link: dict["url"] as! String)
                        cell.imageViewHeightConstraint!.constant = 242
                    }
                }
            }
            else{
                cell.imageViewHeightConstraint!.constant = 0
            }
        }
        cell.dateLabel.text = modelClass.dateConverter(isoDate:(news.published_date!))
        
        cell.imageByLabel.text = news.byline
        
        let attributedString = NSMutableAttributedString(string:"\((news.title!))\n")
        
        let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)]
        let abstract = NSMutableAttributedString(string:(news.abstract)!, attributes:attrs)
        attributedString.append(abstract)
        
        cell.descriptionLabel.attributedText = attributedString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath.row+1 == self.newsArr.count {
            pageNo = pageNo+1
            limit = limit+10
            offset = limit * pageNo
            reloadTableView(limit: "\(limit)", offset: "\(offset)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = self.newsArr[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.urlString = news.url
        self.navigationController?.show(vc, sender: nil)
    }
}

