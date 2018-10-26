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


    var username : String!
    var password : String!
    var id : String!


    // MARK: -
    // MARK: Basic
    override func viewDidLoad() {
        super.viewDidLoad()
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
        }else{
            textField.isSecureTextEntry = true
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
    }

    func checkAccount (){

        //        let account : Parameters = ["grant_type":"password",
        //                                     "username":"gaojian",
        //                                     "password":"191870",
        //                                     "client_id":"ro.client",
        //                                     "client_secret":"secret",
        //                                     "customer_code":"1334"]

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

        Alamofire.request("https://auth-dev.veima.com/connect/token",method: .post, parameters: account).responseJSON{
            response in
            print("Response: \(String(describing: response.response))") // http url response
            let httpStatusCode = response.response?.statusCode

//            let result = response.result.value
//            let answer = JSON(result)
            if (httpStatusCode == 200){
                self.performSegue(withIdentifier: "logsuccess", sender: nil)
                //                let token = "nihao"
                //                print(token)
                //                UserDefaults.standard.set(token, forKey: "token")
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
