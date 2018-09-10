//
//  userViewController.swift
//  gtdv1.0
//
//  Created by RCY-FUDAN on 2018/5/25.
//  Copyright © 2018年 DAMING GROUP. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
//import SQLite
var userstatus:String!

class UserViewController: UIViewController,UITextFieldDelegate {

//    var avPlayer: AVPlayer!
//    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false




    override func viewDidLoad() {
        super.viewDidLoad()
        self.password.delegate = self;
        self.email.delegate = self;

//        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "sunset.jpg")!)
        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }



    @IBOutlet weak var costomer_code: UITextField!

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    @IBAction func login(_ sender: UIButton) {




        var emailtext = email.text  as! String
        if email.text == ""{
            emailtext = "unspecified"
        }
        var passwordtext = password.text  as! String
        if password.text == ""{
            passwordtext = "unspecified"
        }
        var customerCode = costomer_code.text  as! String
        if customerCode == ""{
            customerCode = "unspecified"
        }

        
        let parameters11: Parameters=["email":emailtext,
                                      "password":passwordtext,"client":"commandline"]



        let parameters1: Parameters =    ["grant_type":"password",
                                          "username":emailtext,
                                          "password":passwordtext,
                                          "client_id":"ro.client",
                                          "client_secret":"secret",
                                          "customer_code":customerCode]


        Alamofire.request("https://auth-dev.veima.com/connect/token",method: .post, parameters: parameters1).responseJSON {
            response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            //print(request?.allHTTPHeaderFields)
            // response serialization result
            if "\(response.result)"=="SUCCESS"{
                // self.uploadstatus.text =  "have uploaded sucessfully,please come on!"
                print("u have upload successfully")
                self.performSegue(withIdentifier: "goQRScanPage", sender: nil)
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
    }


}

