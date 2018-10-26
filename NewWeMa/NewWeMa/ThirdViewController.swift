//
//  ThirdViewController.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/10/24.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var getIn: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()

        let thirdImage = UIImage(named: "thirdPage")
        let imageView = UIImageView(image: thirdImage)
        imageView.frame = UIScreen.main.bounds
        self.view.addSubview(imageView)



    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchbegan")
    }

}
