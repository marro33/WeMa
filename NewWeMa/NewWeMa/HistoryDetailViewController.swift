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



    @IBOutlet weak var tranCode: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var serialID: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var comArea: UILabel!


    var result = ""
    var goodsname = ""
    var clientName = ""
    var clientCode = ""
    var clientAreaName = ""

    var headerstring = ""

    let requestURL = "https://api.veima.com/lgs/api/LogisticsCodeQuery?logisticsCode="

    let requestURL_test = "https://api-dev.veima.com/lgs/api/LogisticsCodeQuery?logisticsCode="
    var url = ""

    // MARK:- BASIC
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UserDefaults.standard.string(forKey: "token") as! String  )
        headerstring = UserDefaults.standard.string(forKey: "token") as! String

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tranCode.text = result
        do{
            self.requestsever()
        }catch ErrorType.invalidURL{
            
        }catch ErrorType.invaliedResult{

        }
    }

    // MARK:- REQUEST FOR MESSAGE


    enum ErrorType: Error {
        case invalidURL
        case invaliedResult
    }



    func  requestsever(){
        let headers: HTTPHeaders = ["authorization": headerstring]


        if !UserDefaults.standard.bool(forKey: "test"){
            url = requestURL
        }else{
            url = requestURL_test
        }
        print(url)

        url += result


//        print(">>>>>>>>>>> \(requestURL)")

        Alamofire.request(url, method: .get,headers: headers).responseJSON {
            response in
                        print("Request: \(String(describing: response.request))")   // original url request
                        print("Response: \(String(describing: response.response))") // http url response
                        print("Result: \(response.result)")                         // response serialization result
            if "\(response.result)"=="SUCCESS"{
                print("开始解析JSON")

                let detail = response.result.value as! Dictionary<String, Any>
                let data = detail["data"] as! Dictionary<String, Any>
                print(data)

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
            }else{
                self.showAlert()
            }



        }

    }


    func showAlert(){

        let alert = UIAlertController(title: "结果加载失败", message: "请重新登录", preferredStyle: .alert)
        let action = UIAlertAction (title: "登录", style: .default, handler: {
            (alerts: UIAlertAction) -> Void in

            let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)

            let viewController = mainStoryboard.instantiateInitialViewController() as! UINavigationController
            self.present(viewController, animated: true, completion: nil)

        })
        let action2 = UIAlertAction (title: "取消", style: .cancel, handler: {
            (alerts: UIAlertAction) -> Void in

        })
        alert.addAction(action)
        alert.addAction(action2)
        present(alert,animated: true,completion: nil)
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
