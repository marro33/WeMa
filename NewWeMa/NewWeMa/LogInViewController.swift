//
//  ViewController.swift
//  NewWeMa
//
//  Created by Gaojian on 2018/9/8.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit
import Alamofire



class LogInViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var idTextfield: UITextField!
    @IBOutlet weak var loginBtn: UIButton!

    let requestURL = "https://auth.veima.com/connect/token"
    let requestURL_test = "https://auth-dev.veima.com/connect/token"
    var url = ""


    var username : String!
    var password : String!
    var id : String!


    // MARK: -
    // MARK: Basic
    override func viewDidLoad() {
        super.viewDidLoad()


        //时间戳
        let date = Date()
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let time = dateFormat.string(from: date)
        print(time)

        //       设置点击手势监听
        let guesture = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.tapOutofKeyboard(_:)))
        self.view.addGestureRecognizer(guesture)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        initTextField(usernameTextfield)
        initTextField(passwordTextfield)
        initTextField(idTextfield)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: -
    // MARK: private methods


    //自动退键盘
    @objc func tapOutofKeyboard(_ guesture: UITapGestureRecognizer){
        usernameTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
        idTextfield.resignFirstResponder()
    }

    //初始化输入框
    fileprivate func initTextField(_ textField: UITextField) {
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.autocorrectionType = UITextAutocorrectionType.no

        if textField.restorationIdentifier == "1"{
            textField.keyboardType = UIKeyboardType.emailAddress
        }else if textField.restorationIdentifier == "2"{
            textField.isSecureTextEntry = true
//            textField.keyboardType = UIKeyboardType.numberPad
        }else{
            textField.keyboardType = UIKeyboardType.numberPad
        }

        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


    // MARK: - Basics for login
    @IBAction func usernameDone() {
        passwordTextfield.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }


    @IBAction func passwordDone() {
        idTextfield.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func idDone() {
        dismiss(animated: true, completion: nil)
        loginBtn.becomeFirstResponder()
    }

    @IBAction func loginBtn(_ sender: UIButton) {
        print("tapping")
        //        self.dismiss(animated: true, completion: nil)

        checkAccount()

//        if !UserDefaults.standard.bool(forKey: "loging"){
//            checkAccount()
//            UserDefaults.standard.set(true, forKey: "loged")
//        }
    }

    @IBAction func easyGate(_ sender: Any) {
//        self.performSegue(withIdentifier: "logsuccess", sender: nil)
//
//
//        let vc = WebViewController()
//        self.navigationController?.pushViewController(vc, animated: true)


        self.showActionSheet()
    }

    func showActionSheet() {
        let alert = UIAlertController(title: "Information", message: "登录遇到问题", preferredStyle: UIAlertController.Style.actionSheet)

        let web = UIAlertAction(title: "进入迅亚", style: UIAlertAction.Style.default, handler: {(alert:UIAlertAction) -> Void in

            let vc = WebViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        })

        let scan = UIAlertAction(title: "免登陆进入", style: UIAlertAction.Style.destructive, handler: {(alert:UIAlertAction) -> Void in

            self.performSegue(withIdentifier: "logsuccess", sender: nil)
        })

        let test = UIAlertAction(title: "测试模式登陆进入", style: UIAlertAction.Style.destructive, handler: {(alert:UIAlertAction) -> Void in

            if !UserDefaults.standard.bool(forKey: "test"){
                print("test mode")
                UserDefaults.standard.set(true, forKey: "test")
                self.loginBtn.setTitle("测试模式", for: .normal)
            }else{
                print("normal")
                UserDefaults.standard.set(false, forKey: "test")
                self.loginBtn.setTitle("登录", for: .normal)
            }
        })
        let cancel = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)

        alert.addAction(web)
        alert.addAction(scan)
        alert.addAction(test)
        alert.addAction(cancel)
        self.present(alert,animated: true, completion: nil)
    }


    func checkAccount (){

        //        let account : Parameters = ["grant_type":"password",
        //                                     "username":"gaojian",
        //                                     "password":"191870",
        //                                     "client_id":"ro.client",
        //                                     "client_secret":"secret",
        //                                     "customer_code":"1334"]


        if !UserDefaults.standard.bool(forKey: "test"){
            url = requestURL
        }else{
            url = requestURL_test
        }
        print(url)


        username = usernameTextfield.text as? String
        password = passwordTextfield.text as? String
        id = idTextfield.text as? String

        print(username + password + id)

        let account : Parameters = ["grant_type":"password",
                                    "username":username!,
                                    "password":password!,
                                    "client_id":"ro.client",
                                    "client_secret":"secret",
                                    "customer_code":id!]



        Alamofire.request(url,method: .post, parameters: account).responseJSON{
            response in
            
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))") // http url response
            let httpStatusCode = response.response?.statusCode
            

            if (httpStatusCode == 200){
                self.performSegue(withIdentifier: "logsuccess", sender: nil)

                let value = response.result.value as! Dictionary<String, Any>
                //            let answer = JSON(result)
                //            print(value)
                var token = value["access_token"] as! String
                token = "Bearer " + token
                print(token)

                //                let token = "nihao"
                //                print(token)
                UserDefaults.standard.set(token, forKey: "token")
//
//                let token = "\(answer["access_token"])"
//                token = "Bearer " + token
//                print(token)

            }else{
                print("failue log")

                let alert = UIAlertController(title: "登录失败", message: "请重新输入账号密码", preferredStyle: UIAlertController.Style.alert)
                let okey = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alert.addAction(okey)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
