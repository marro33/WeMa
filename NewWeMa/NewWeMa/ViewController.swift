//
//  ViewController.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/9/8.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    
        let parameters1: Parameters =    ["grant_type":"password",
                                          "username":"gaojian",
                                          "password":"191870",
                                          "client_id":"ro.client",
                                          "client_secret":"secret",
                                          "customer_code":"1334"]
        
        
        Alamofire.request("https://auth-dev.veima.com/connect/token",method: .post, parameters: parameters1).responseJSON {
            response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            //print(request?.allHTTPHeaderFields)
            // response serialization result
            if "\(response.result)"=="SUCCESS"{
                // self.uploadstatus.text =  "have uploaded sucessfully,please come on!"
                print("u have upload successfully")
                //self.performSegue(withIdentifier: "gomainpage", sender: nil)
                //userstatus = "logined"
                
                do {
                    print(response.data)
                    //let database = try Connection("users.sqlite")
                    //let usertable = Table("users")
                    /*
                     
                     note it is using video.sift var
                     */
                    //  let insert = userstable.insert(dbpassword <- passwordtext, dbemail <- emailtext,status <- "logined")
                    //let rowid = try database.run(insert)
                    
                    
                    
                }catch{print(error)}
                
                
                
                
                
            }
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                if "\(json)" == "logined"{
                    
                }
                
                
            }
            
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
