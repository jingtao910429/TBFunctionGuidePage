//
//  GuidePageView.swift
//  TBFunctionGuidePage
//
//  Created by Mac on 2017/9/7.
//  Copyright © 2017年 LiYou. All rights reserved.
//

import UIKit
import Foundation

private let bundleInfo = Bundle.main.infoDictionary
private let defaults = UserDefaults.standard

private struct GuidePageLocalSet {
    //透明度
    static let opacity = Float(0.8)
    //填充色
    static let fillColor = UIColor.black.cgColor
}

extension UIView {
    
    private struct GuidePageViewKeys {
        static var guidePageNameKey = "UIView.GuidePageNameKey"
        static var guidePageContainerView = "UIView.GuidePageContainerView"
        static var guidePageFeatures = "UIView.GuidePageFeatures"
        //屏幕旋转
        static var guidePageRotationOberserver = "UIView.GuidePageRotationOberserver"
    }
    
    //设置是否需要功能引导
    var guidePageNameKey: String? {
        get {
            return objc_getAssociatedObject(self, &GuidePageViewKeys.guidePageNameKey) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &GuidePageViewKeys.guidePageNameKey,
                    newValue as String?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    //内容承载
    var guidePageContainerView: UIView? {
        get {
            return objc_getAssociatedObject(self, &GuidePageViewKeys.guidePageContainerView) as? UIView
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &GuidePageViewKeys.guidePageContainerView,
                    newValue as UIView?,
                    .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
    }
    
    //features集合
    //features 功能引导集合 
    //组织形式 [[FeatureHandlerItem]], 一级表示同一页面功能分次序显示、二级描述同一页面同一次显示功能个数
    var guidePageFeatures: [[FeatureHandlerItem]]? {
        get {
            return objc_getAssociatedObject(self, &GuidePageViewKeys.guidePageFeatures) as? [[FeatureHandlerItem]]
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &GuidePageViewKeys.guidePageFeatures,
                    newValue as [[FeatureHandlerItem]]?,
                    .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
    }
    
    //屏幕旋转
    var guidePageRotationOberserver: Any? {
        get {
            return objc_getAssociatedObject(self, &GuidePageViewKeys.guidePageRotationOberserver)
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &GuidePageViewKeys.guidePageRotationOberserver,
                    newValue as Any?,
                    .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
    }
}


extension UIView {
    static func hasShow(key: String = "", version: String = "") -> Bool {
        
        guard key != "", version != "" else {
            return false
        }
        
        guard let shortVersion = bundleInfo?["CFBundleShortVersionString"] as? String, shortVersion == version else {
            return false
        }
        
        if let result = defaults.object(forKey: UIView.keyCompent(key: key, version: version)) as? Bool{
            return result
        }
        
        return true
    }
    
    static func setStatus(key: String, isShow: Bool) {
        guard key != "" else {
            return
        }
        defaults.set(isShow, forKey: key)
        defaults.synchronize()
    }
    
    static func keyCompent(key: String, version: String) -> String {
        return "\(key)-\(version)"
    }
}

//公开及私有方法
extension UIView {
    
    func show(features: [[FeatureHandlerItem]], key: String, version: String) {
        
        if UIView.hasShow(key: key, version: version) || self.window == nil {
            return
        }
        self.dismiss()
        
        self.layoutSubviews(features: features)
        
        UIView.setStatus(key: UIView.keyCompent(key: key, version: version), isShow: true)
    }
    
    func dismiss() {
        guard self.guidePageContainerView != nil, self.guidePageNameKey != nil else {
            return
        }
        UIView.setStatus(key: self.guidePageNameKey!, isShow: true)
        self.guidePageContainerView?.removeFromSuperview()
        self.guidePageContainerView = nil
    }
    
    func touchedEvent(_ tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            self.dismiss()
        }
    }
    
    //设置布局
    private func layoutSubviews(features: [[FeatureHandlerItem]]) {
        
        guard features.count != 0 else {
            return
        }
        
        guard let _ = self.window?.bounds else {
            return
        }
        
        let containerView: UIView = UIView(frame: (self.window?.bounds)!)
        containerView.backgroundColor = UIColor.clear
        self.guidePageContainerView = containerView
        self.window?.addSubview(self.guidePageContainerView!)
        
        //点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchedEvent))
        containerView.addGestureRecognizer(tap)
        
        /*
         
         UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,self.window.bounds.size.width, self.window.bounds.size.height)cornerRadius:0];
         
         CAShapeLayer *shapeLayer = [CAShapeLayer layer];
         
         shapeLayer.path = path.CGPath;
         shapeLayer.fillRule = kCAFillRuleEvenOdd;
         shapeLayer.fillColor = [UIColor blackColor].CGColor;
         shapeLayer.opacity =0.8;
         
         [containerView.layer addSublayer:shapeLayer];
         
         
         NSMutableDictionary *actionDict = [NSMutableDictionary dictionary];
         [self setButtonActionsDictionary:actionDict];
         
         [featureItems enumerateObjectsUsingBlock:^(EAFeatureItem * featureItem, NSUInteger idx, BOOL * _Nonnull stop) {
         
         actionDict[@(idx)] = [featureItem.action copy];
         
         [self layoutWithFeatureItem:featureItem];
         
         }];
         */
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.window?.frame.width)!, height: (self.window?.frame.size.height)!), cornerRadius: 0)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.fillColor = GuidePageLocalSet.fillColor
        shapeLayer.opacity = GuidePageLocalSet.opacity
        containerView.layer.addSublayer(shapeLayer)
        
        
        features.forEach { (innerItems: [FeatureHandlerItem]) in
            innerItems.forEach({ (item) in
                self.layout(featureHandlerItem: item)
            })
        }
        
    }
    
    
    private func layout(featureHandlerItem: FeatureHandlerItem) {
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
