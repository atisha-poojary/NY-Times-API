//
//  CustomTableViewCell.swift
//  NY_Times
//
//  Created by Atisha Poojary on 10/24/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImage: UIImageView?
    @IBOutlet weak var imageByLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint?
    
    var  news: News? {
        didSet {
//            if (self.cache.object(forKey: "\(news.slug_name!)" as AnyObject) != nil){
//                cell.thumbnailImage.image = self.cache.object(forKey: "\(news.slug_name!)" as AnyObject) as? UIImage }
//            else{
//                if let multimediaArr: [AnyObject] = news.multimedia {
//                    for multimediaDict in multimediaArr{
//                        let dict: [String:AnyObject] = multimediaDict as! [String:AnyObject]
//                        if dict["format"] as! String == "mediumThreeByTwo440"{
//                            //cell.thumbnailImage.downloadedFromLink(link: dict["url"] as! String)
//                            cell.imageViewHeightConstraint!.constant = 242
//                        }
//                    }
//                }
//                else{
//                    cell.imageViewHeightConstraint!.constant = 0
//                }
//            }
            //dateLabel.text = news.dateConverter(isoDate:(news.published_date!))
            
            if let multimediaArr = news?.multimedia as? [Any] {
                for multimediaDict in multimediaArr{
                    let dict: [String:AnyObject] = multimediaDict as! [String:AnyObject]
                    if dict["format"] as! String == "mediumThreeByTwo440"{
                        imageViewHeightConstraint!.constant = 242
                    }
                }
            }
            else{
                imageViewHeightConstraint!.constant = 0
            }
            imageByLabel?.text = news?.byline
            
            let attributedString = NSMutableAttributedString(string:"\((news?.title!) ?? "")\n")
            
            let attrs = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0)]
            let abstract = NSMutableAttributedString(string:(news?.abstract)!, attributes:attrs)
            attributedString.append(abstract)
            
            descriptionLabel?.attributedText = attributedString
        }
    }
}
