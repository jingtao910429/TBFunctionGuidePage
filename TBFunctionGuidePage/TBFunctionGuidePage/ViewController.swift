//
//  ViewController.swift
//  TBFunctionGuidePage
//
//  Created by Mac on 2017/9/6.
//  Copyright © 2017年 LiYou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 150, y: 250, width: 100, height: 50))
        button.addTarget(self, action: #selector(go), for: .touchUpInside)
        button.backgroundColor = UIColor.gray
        self.view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func go() {
        
        //根据配置设置功能引导，点击方法action存在与否决定button是否显示
        let noFocus: FeatureHandlerItem = FeatureHandlerItem()
        
        noFocus.featureType = .noFocus
//        let introduceWidth = UIScreen.main.bounds.width - 100
        noFocus.introduceFrame = CGRect(x: (UIScreen.main.bounds.width - 150)/2.0, y: 50, width: 150, height: 0)
        noFocus.introduce = "load.png"
        noFocus.focusAction = { [weak self] sender in
            print("----")
        }
        
        noFocus.buttonBackgroundImageName = "try.png"
        noFocus.buttonFrame = CGRect(x: 0, y: 0, width: 0, height: 40)
        noFocus.action = { [weak self] sender in
            print("++++")
            
        }
        
        let item: FeatureHandlerItem = FeatureHandlerItem(focusView: self.button, focusCornerRadius: 10, focusInsets: UIEdgeInsets(top: -10, left: -10, bottom: 10, right: 10))
        item.featureType = .all
        
        let introduceWidth = UIScreen.main.bounds.width - 100
        item.introduceFrame = CGRect(x: 20, y: 0, width: introduceWidth, height: 0)
        item.introduce = "homeMore.png"
        item.focusAction = { [weak self] sender in
            print("----")
        }
        
        item.buttonBackgroundImageName = "know.png"
        item.buttonFrame = CGRect(x: introduceWidth/4.0 - 20, y: 0, width: introduceWidth/2.0, height: 40)
        item.action = { [weak self] sender in
            print("++++")
            
        }
        
        self.navigationController?.view.show(features: [[noFocus], [item]], key: "keys", version: "1.0");
    }

}

