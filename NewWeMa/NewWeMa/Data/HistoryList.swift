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
//    var items: HistoryListItem

    init(result: String) {
        self.result = result
//        self.items =
        super.init()
    }
}
