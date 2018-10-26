//
//  SecondViewController.swift
//  PageControllView
//
//  Created by Gaojian on 2018/10/24.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.blue

        let secondImage = UIImage(named: "secondPage")
        let imageView = UIImageView(image: secondImage)
        imageView.frame = UIScreen.main.bounds
        self.view.addSubview(imageView)
        // Do any additional setup after loading the view.
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
