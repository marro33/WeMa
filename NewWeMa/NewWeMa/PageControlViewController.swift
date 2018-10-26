//
//  PageControlViewController.swift
//  PageControllView
//
//  Created by Gaojian on 2018/10/24.
//  Copyright © 2018年 Gaojian. All rights reserved.
//

import UIKit

class PageControlViewController: UIViewController, UIScrollViewDelegate {

    //添加相关属性
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    var isPageControlUsed = false
    var pageNum = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        var screenFrame = UIScreen.main.bounds
        let screenWidth = screenFrame.size.width
        let screedHeight = screenFrame.size.height

//        print(screenWidth + screedHeight)

        scrollView.frame = screenFrame
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(pageNum), height: screedHeight)
        scrollView.backgroundColor = UIColor.black
        scrollView.delegate = self

        let pcHeight: CGFloat = 50.0
        let pcRect = CGRect(x: 0, y: screedHeight - pcHeight, width: screenWidth, height: pcHeight)
        pageControl.frame = pcRect
        pageControl.numberOfPages = Int(pageNum)
        pageControl.currentPage = 0
        pageControl.backgroundColor = UIColor.gray
        pageControl.addTarget(self, action: #selector(PageControlViewController.pageControlDidChanged(_:)), for: UIControl.Event.valueChanged)

        let firstController = FirstViewController()
        screenFrame.origin.x = 0
        firstController.view.frame = screenFrame

        let secondController = SecondViewController()
        screenFrame.origin.x = screenFrame.size.width
        secondController.view.frame = screenFrame

        let thirdController = ThirdViewController()
        screenFrame.origin.x = screenFrame.size.width * 2
        thirdController.view.frame = screenFrame

        let bt = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 50, height: 50))
        bt.backgroundColor = UIColor.gray
        bt.setTitle("go", for: .normal)
        bt.addTarget(self, action: #selector(PageControlViewController.swipe(_:)), for: UIControl.Event.touchUpInside)
        self.view.addSubview(bt)
        self.view.bringSubview(toFront: bt)


//        let guesture = UITapGestureRecognizer(target: self, action: #selector(PageControlViewController.swipe(_ :)))
//        thirdController.view.addGestureRecognizer(guesture)

        scrollView.addSubview(firstController.view)
        scrollView.addSubview(secondController.view)
        scrollView.addSubview(thirdController.view)

        self.view.addSubview(scrollView)
//        self.view.addSubview(pageControl)
        // Do any additional setup after loading the view.
    }

        @objc func swipe(_ button:UIButton){
            print("swaping")
            self.performSegue(withIdentifier: "tologin", sender: nil)
        }

    @objc func pageControlDidChanged(_ sender:AnyObject){
        let crtPage = (CGFloat)(pageControl.currentPage)
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * crtPage
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
        isPageControlUsed = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if(!isPageControlUsed){
//            let pageWidth = scrollView.frame.size.width
//            //根据滚动视图的宽度值和横向位移量，计算当前页码
//            let page = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1
//            pageControl.currentPage = Int(page)
//            print(page)
//        }

        print("Scrolled:\(scrollView.contentOffset)")
        let twidth = CGFloat(pageNum - 1) * self.view.bounds.width

        if(scrollView.contentOffset.x > twidth){
            //z转到登录界面，但是重新设置navigationcbarcontroller为跟视图有些麻烦
            print("go")


            let mainStoryboard = UIStoryboard(name:"Main", bundle:nil)
            
            let viewController = mainStoryboard.instantiateInitialViewController() as! UINavigationController

            //方法一跳转太过突然，发现方法二依然可行
//            self.view.window?.rootViewController = viewController

            self.present(viewController, animated: true, completion: nil)

//            let ani = CATransition()
//            ani.duration = 2
//            ani.type = kCATransitionPush
//            ani.subtype = kCATransitionFromRight
//            self.view.exchangeSubview(at: 1, withSubviewAt: 0)
//            viewController.add(ani,for)

        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isPageControlUsed = false
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
