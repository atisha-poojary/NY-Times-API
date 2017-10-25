//
//  DetailViewController.swift
//  NY_Times
//
//  Created by Atisha Poojary on 10/25/17.
//  Copyright © 2017 Atisha Poojary. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
}
