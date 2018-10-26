//
//  HistoryList.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/9/19.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit

class HistoryList: NSObject, Codable {
    var result = ""
    var time = ""


    init(result: String, time: String) {
        super.init()
        self.result = result
        self.time = time

    }


}
