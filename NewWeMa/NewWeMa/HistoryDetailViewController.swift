//
//  HistoryDetailViewController.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/10/14.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit
import Alamofire
//import SwiftyJSON


class HistoryDetailViewController: UIViewController {


    var result = ""
    @IBOutlet weak var tranCode: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var serialID: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var comArea: UILabel!



    override func viewDidLoad() {
        super.viewDidLoad()
//        tranCode.text = result
        //        requestsever()
                print("hello")
                print(UserDefaults.standard.string(forKey: "token") as! String  )
        headerstring = UserDefaults.standard.string(forKey: "token") as! String

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tranCode.text = result
        self.requestsever()

    }

    var headerstring = ""



    func  requestsever(){
        let headers: HTTPHeaders = [
            "authorization": headerstring
        ]
        Alamofire.request("https://api-dev.veima.com/lgs/api/LogisticsCodeQuery?logisticsCode=004444834349",method: .get,headers: headers).responseJSON {
            response in
//                        print("Request: \(String(describing: response.request))")   // original url request
//                        print("Response: \(String(describing: response.response))") // http url response
//                        print("Result: \(response.result)")                         // response serialization result


//            if "\(response.result)"=="SUCCESS"{
//                //self.uploadstatus.text =  "have uploaded sucessfully,please come on!"
//            }
//
//
//            if let json = response.result.value {
//                //print("JSON: \(json)") // serialized json response
//                print(type(of: json))
//            }

            print("开始解析")
            let detail = response.result.value as! Dictionary<String, Any>
            let data = detail["data"] as! Dictionary<String, Any>
            var fd = data["fDepotName"] as! String
            var log = data["logisticsCode"] as! String
            var bat = data["batchNo"] as! String
            var goodsname = data["goodsName"] as! String
            var clientName = data["clientName"] as! String
            var clientCode = data["clientCode"] as! String
            var clientAreaName = data["clientAreaName"] as! String


            self.productName.text = goodsname
            self.serialID.text = bat
            self.companyName.text = clientName
            self.comArea.text = clientAreaName

            print(data)
            print(fd + log + bat )

            //            let result = response.result.value
            //            let answer = JSON(result)
            //            print(answer)
            //            print(answer["data"]["fDepotName"])
            //            self.fdepotname.text = "\(answer["data"]["fDepotName"])"
            //            print(answer["data"]["logisticsCode"])
            //            self.logisticscode.text = "\(answer["data"]["logisticsCode"])"
            //            print(answer["data"]["batchNo"])
            //            self.batchcode.text = "\(answer["data"]["batchNo"])"
            //            print(answer["data"]["goodsName"])
            //            self.goodsname.text = "\(answer["data"]["goodsName"] )"

        }

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
