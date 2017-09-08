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
    
    @objc private func touchedEvent(_ tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            self.dismiss()
        }
    }
    
    @objc private func focusActionButtonClick(_ sender: UIButton) {
        
    }
    
    @objc private func actionButtonClick(_ sender: UIButton) {
        
    }
    
    
    //设置布局
    private func layoutSubviews(features: [[FeatureHandlerItem]]) {
        
        guard features.count != 0 else {
            return
        }
        
        guard let _ = self.window?.bounds else {
            return
        }
        
        self.guidePageFeatures = features
        
        let containerView: UIView = UIView(frame: (self.window?.bounds)!)
        containerView.backgroundColor = UIColor.clear
        self.guidePageContainerView = containerView
        self.window?.addSubview(self.guidePageContainerView!)
        
        //点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchedEvent(_:)))
        containerView.addGestureRecognizer(tap)
        
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
        
        let containerView = self.guidePageContainerView
        //var indictorImageView: UIImageView?
        var introduceView: UIView?
        var button: UIButton?
        
        //绘制镂空高亮区域
        var featureItemFrame = featureHandlerItem.focusView != nil ? featureHandlerItem.focusView?.convert((featureHandlerItem.focusView?.bounds)!, to: containerView) : featureHandlerItem.focusFrame
        
        
        let shapeLayer = containerView?.layer.sublayers?.first as! CAShapeLayer
        let bezierPath = UIBezierPath(cgPath: shapeLayer.path!)
        
        featureItemFrame?.origin.x += featureHandlerItem.focusInsets.left
        featureItemFrame?.origin.y += featureHandlerItem.focusInsets.top
        featureItemFrame?.size.width += featureHandlerItem.focusInsets.right - featureHandlerItem.focusInsets.left
        featureItemFrame?.size.height += featureHandlerItem.focusInsets.bottom - featureHandlerItem.focusInsets.top
        
        bezierPath.append(UIBezierPath(roundedRect: featureItemFrame!, cornerRadius: featureHandlerItem.focusCornerRadius))
        shapeLayer.path = bezierPath.cgPath
        
        //镂空区域添加操作按钮
        let focusActionButton = UIButton(type: .custom)
        focusActionButton.frame = featureItemFrame!
        focusActionButton.backgroundColor = UIColor.clear
        focusActionButton.addTarget(self, action: #selector(focusActionButtonClick(_:)), for: .touchUpInside)
        containerView?.addSubview(focusActionButton)
        
        //根据配置信息增加介绍页和完成button
        
        //introduce
        if let introduce = featureHandlerItem.introduce {
            
            guard let _ = featureHandlerItem.introduceFrame else {
                return
            }
            
            let frame = featureHandlerItem.introduceFrame!
            
            let type = featureHandlerItem.introduce?.components(separatedBy: ".").last?.lowercased()
            if type == "png"
                || type == "jpg"
                || type == "jpeg" {
                
                //介绍页为图片
                let introduceImage: UIImage = UIImage(named: introduce)!
                let imageSize = featureItemFrame?.size
                let imageView: UIImageView = UIImageView(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: (imageSize?.width)!, height: (imageSize?.height)!))
                imageView.clipsToBounds = true
                imageView.contentMode = .scaleAspectFit
                imageView.image = introduceImage
                introduceView = imageView
                
            } else {
                
                let introduceLabel = UILabel()
                introduceLabel.backgroundColor = UIColor.clear
                introduceLabel.numberOfLines = 0
                introduceLabel.text = introduce
                introduceLabel.font = featureHandlerItem.introduceFont
                introduceLabel.textColor = featureHandlerItem.introduceTextColor
                introduceLabel.frame = frame
                introduceView = introduceLabel
                
            }
            
            containerView?.addSubview(introduceView!)
        }
        
        //button
        if let _ = featureHandlerItem.action {
            
            guard let _ = featureHandlerItem.buttonFrame else {
                return
            }
            
            let frame = featureHandlerItem.buttonFrame!
            
            button = UIButton(frame: frame)
            if let imageName = featureHandlerItem.buttonBackgroundImageName {
                let image: UIImage = (UIImage(named: imageName)?.resizableImage(withCapInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)))!
                button?.setImage(image, for: .normal)
            }
            if let title = featureHandlerItem.buttonTitle {
                button?.setTitle(title, for: .normal)
            }
            button?.sizeToFit()
            button?.addTarget(self, action: #selector(actionButtonClick(_:)), for: .touchUpInside)
            containerView?.addSubview(button!)
            
        }
        
    }
    
    
    
    
    
}
