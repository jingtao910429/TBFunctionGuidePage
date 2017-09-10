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
        static var guidePageNameKey       = "UIView.GuidePageNameKey"
        static var guidePageContainerView = "UIView.GuidePageContainerView"
        static var guidePageFeatures      = "UIView.GuidePageFeatures"
        static var guidePageShowIndex     = "UIView.GuidePageShowIndex"
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
                    .OBJC_ASSOCIATION_COPY_NONATOMIC
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
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var guidePageShowIndex: Int? {
        get {
            return objc_getAssociatedObject(self, &GuidePageViewKeys.guidePageShowIndex) as? Int
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &GuidePageViewKeys.guidePageShowIndex,
                    newValue as Int?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
        
        guard let _ = defaults.object(forKey: UIView.keyCompent(key: key, version: version)) else {
            return false
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
        
        guard features.count != 0 else {
            return
        }
        
        if UIView.hasShow(key: key, version: version) || self.window == nil {
            return
        }
        
        self.dismiss()
        
        self.guidePageFeatures = features
        self.guidePageShowIndex = 1
        self.layoutSubviews(features: features.first!)
        
        self.guidePageNameKey = UIView.keyCompent(key: key, version: version)
        UIView.setStatus(key: self.guidePageNameKey!, isShow: true)
    }
    
    func dismiss() {
        
        guard self.guidePageContainerView != nil, self.guidePageNameKey != nil else {
            return
        }
        
        self.guidePageContainerView?.removeFromSuperview()
        self.guidePageContainerView = nil
        
        if self.guidePageShowIndex == self.guidePageFeatures?.count {
            UIView.setStatus(key: self.guidePageNameKey!, isShow: true)
        } else {
            self.guidePageShowIndex = self.guidePageShowIndex! + 1
            self.layoutSubviews(features: self.guidePageFeatures![self.guidePageShowIndex! - 1])
        }
        
    }
    
    @objc private func touchedEvent(_ tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            self.dismiss()
        }
    }
    
    @objc private func focusActionButtonClick(_ sender: UIButton) {
        if let action = sender.featureHandlerItem?.focusAction {
            action(sender)
        }
    }
    
    @objc private func actionButtonClick(_ sender: UIButton) {
        dismiss()
        
        if let action = sender.featureHandlerItem?.action {
            action(sender)
        }
    }
    
    //设置布局
    private func layoutSubviews(features: [FeatureHandlerItem]) {
        
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchedEvent(_:)))
        containerView.addGestureRecognizer(tap)
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: (self.window?.frame.width)!, height: (self.window?.frame.size.height)!), cornerRadius: 0)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.fillColor = GuidePageLocalSet.fillColor
        shapeLayer.opacity = GuidePageLocalSet.opacity
        containerView.layer.addSublayer(shapeLayer)
        
        features.forEach { (item) in
            self.layout(featureHandlerItem: item)
        }
    }
    
    
    private func layout(featureHandlerItem: FeatureHandlerItem) {
        
        let containerView = self.guidePageContainerView
        
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
        focusActionButton.featureHandlerItem = featureHandlerItem
        focusActionButton.frame = featureItemFrame!
        focusActionButton.backgroundColor = UIColor.clear
        focusActionButton.addTarget(self, action: #selector(focusActionButtonClick(_:)), for: .touchUpInside)
        containerView?.addSubview(focusActionButton)
        
        layoutNormal(featureItemFrame: featureItemFrame!, featureHandlerItem: featureHandlerItem, containerView: containerView!)
    }
    
    private func layoutNormal(featureItemFrame: CGRect, featureHandlerItem: FeatureHandlerItem, containerView: UIView) {
        
        var introduceView: UIView?
        var button: UIButton?
        
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
                guard let _ = UIImage(named: introduce) else {
                    return
                }
                let introduceImage: UIImage = UIImage(named: introduce)!
                let imageSize = introduceImage.size
                
                var width = frame.size.width
                var height = frame.size.height
                var positionY = frame.origin.y
                
                //根据类型进行页面调整,与业务有关
                switch featureHandlerItem.featureType {
                case .all:
                    width = frame.size.width - frame.origin.x
                    height = width * imageSize.height / imageSize.width
                    positionY = featureItemFrame.origin.y - height
                case .noFocus:
                    
                    height = width * imageSize.height / imageSize.width
                    positionY = (UIScreen.main.bounds.height - height)/2.0
                    
                    if let buttonFrame = featureHandlerItem.buttonFrame {
                        positionY -= 2 * buttonFrame.size.height
                    }
                case .none:
                    break
                }
                
                featureHandlerItem.introduceFrame?.origin.y = positionY
                featureHandlerItem.introduceFrame?.size.width = width
                featureHandlerItem.introduceFrame?.size.height = height
                
                let imageView: UIImageView = UIImageView(frame: featureHandlerItem.introduceFrame!)
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
            
            containerView.addSubview(introduceView!)
        }
        
        //button
        if let _ = featureHandlerItem.action {
            
            guard let _ = featureHandlerItem.buttonFrame else {
                return
            }
            
            let introduceFrame = featureHandlerItem.introduceFrame!
            
            var frame = featureHandlerItem.buttonFrame!
            
            switch featureHandlerItem.featureType {
            case .all:
                frame.origin.y = introduceFrame.origin.y + introduceFrame.size.height/2.0
            case .noFocus:
                frame.origin.y = introduceFrame.origin.y + introduceFrame.size.height + 60
                frame.origin.x = introduceFrame.origin.x - 10
                frame.size.width = introduceFrame.size.width
            case .none:
                break
            }
            
            button = UIButton(frame: frame)
            if let imageName = featureHandlerItem.buttonBackgroundImageName {
                guard let _ = UIImage(named: imageName) else {
                    return
                }
                let image: UIImage = UIImage(named: imageName)!
                button?.setImage(image, for: .normal)
            }
            if let title = featureHandlerItem.buttonTitle {
                button?.setTitle(title, for: .normal)
            }
            button?.imageView?.contentMode = .scaleAspectFit
            button?.featureHandlerItem = featureHandlerItem
            button?.addTarget(self, action: #selector(actionButtonClick(_:)), for: .touchUpInside)
            containerView.addSubview(button!)
            
        }
    }
    
    
    
}

extension UIButton {
    
    private struct ButtonViewKeys {
        static var FeatureHandlerItemKey       = "UIView.FeatureHandlerItemKey"
    }
    
    var featureHandlerItem: FeatureHandlerItem? {
        get {
            return objc_getAssociatedObject(self, &ButtonViewKeys.FeatureHandlerItemKey) as? FeatureHandlerItem
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &ButtonViewKeys.FeatureHandlerItemKey,
                    newValue as FeatureHandlerItem?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
