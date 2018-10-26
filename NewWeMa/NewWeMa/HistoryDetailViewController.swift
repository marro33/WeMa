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
        //        print(UserDefaults.standard.string(forKey: "token") as! String  )
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tranCode.text = result
    }

    var headerstring = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkQ0MDNCMEI3OUU0Q0QxMERDNEFEMjQyOEYxQTkwQzhENDZCRjQwNTEiLCJ0eXAiOiJKV1QiLCJ4NXQiOiIxQU93dDU1TTBRM0VyU1FvOGFrTWpVYV9RRkUifQ.eyJuYmYiOjE1Mzc0MjYxMTQsImV4cCI6MTUzNzQ2MjExNCwiaXNzIjoiaHR0cHM6Ly9hdXRoLWRldi52ZWltYS5jb20iLCJhdWQiOlsiaHR0cHM6Ly9hdXRoLWRldi52ZWltYS5jb20vcmVzb3VyY2VzIiwiYXBpMSIsImhvc3QiLCJsZ3MiLCJsZ3NfQmluZEdvb2RzIiwibG90dGVyeSIsInFtcyIsInNtcyIsInN5cyIsIndlY2hhdHNtcyIsInlvdXNoaTE1ODciXSwiY2xpZW50X2lkIjoicm8uY2xpZW50Iiwic3ViIjoiMzc4IiwiYXV0aF90aW1lIjoxNTM3NDI2MTE0LCJpZHAiOiJsb2NhbCIsIm9yZ2FuaXphdGlvblBlcm1pc3Npb25zIjoiW10iLCJ1c2VyUGVybWlzc2lvbnMiOiJbMzc4XSIsImN1c3RvbWVySWQiOiIxIiwib3JnSWQiOiIxMSIsImN1c3RvbWVyQ29kZSI6IjEzMzQiLCJ1c2VybmFtZSI6IumrmOWBpSIsImFjY291bnQiOiJnYW9qaWFuIiwicm9sZUlkcyI6IlsxNjhdIiwic2NvcGUiOlsib3BlbmlkIiwicHJvZmlsZSIsImFwaTEiLCJob3N0IiwibGdzIiwibGdzX0JpbmRHb29kcyIsImxvdHRlcnkiLCJxbXMiLCJzbXMiLCJzeXMiLCJ3ZWNoYXRzbXMiLCJ5b3VzaGkxNTg3Iiwib2ZmbGluZV9hY2Nlc3MiXSwiYW1yIjpbInB3ZCJdfQ.s1kDja1uMBsBawwFhgQFay1gGi9yB2Jb21as3EUVDR1Tzh93eVNklmJhwLCTd6TyK0d3XHWnE6oHpDKVDO9Kg-_k50Q0oEaaJt1r8dZTwC_BsW47Zr63mHqtsrZm6jJyeJbEpsCNlnMgoPgy_NF7Voeyt3m30IALM5d9jd4HNIYo_LPTXQmNarfUoGK0YRXWkIrxAMuxNTZQkYS_Mp3Dtnn5yvdlwpEmIpLe_e9zI77SWl88xnz45mPVF665ht9dCcQ-OmobVd50STFZ8VE6B91zf5BbNB6ovh9887qyEOP7MkpveZ2eOkD62BY6S7LcnMhwzY29zAaPUVSV2sIVKQ"



    func  requestsever(){
        let headers: HTTPHeaders = [
            "authorization": headerstring
        ]
        Alamofire.request("https://api-dev.veima.com/lgs/api/LogisticsCodeQuery?logisticsCode=004444834349",method: .get,headers: headers).responseJSON {
            response in
            //            print("Request: \(String(describing: response.request))")   // original url request
            //            print("Response: \(String(describing: response.response))") // http url response
            //            print("Result: \(response.result)")                         // response serialization result


            if "\(response.result)"=="SUCCESS"{
                //self.uploadstatus.text =  "have uploaded sucessfully,please come on!"
            }


            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                print(type(of: json))
            }


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

        //self.pridetableview.reloadData()

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
