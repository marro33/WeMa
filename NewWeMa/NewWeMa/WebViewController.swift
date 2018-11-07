//
//  WebViewController.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/10/30.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var url = URL(string: "http://www.siiatech.com")

    override func viewDidLoad() {
        super.viewDidLoad()

//        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//        webView.frame = rect

        let request = URLRequest(url: url!)
        
        webView.loadRequest(request)
//        self.view.addSubview(webView)
        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
