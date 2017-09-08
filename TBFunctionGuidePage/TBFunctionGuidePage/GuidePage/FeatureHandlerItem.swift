//
//  FeatureHandlerItem.swift
//  TBFunctionGuidePage
//
//  Created by Mac on 2017/9/7.
//  Copyright © 2017年 LiYou. All rights reserved.
//

import UIKit

//单布局元素在界面上垂直居中时，是将介绍文案布局顶部，还是底部
enum AlignmentPriority {
    //顶部优先
    case top
    //底部优先
    case bottom
}

typealias HandlerAction = (_ sender: UIButton) -> Void
typealias HandlerFocusAction = (_ sender: UIButton) -> Void

class FeatureHandlerItem: NSObject {
    
    //镂空显示元素 - 两种呈现方式 View/Frame
    //高亮元素
    public var focusView: UIView?
    //高亮元素frame
    public var focusFrame: CGRect?
    //高亮元素圆角半径
    public var focusCornerRadius: CGFloat = 0
    //高亮元素Insets
    public var focusInsets: UIEdgeInsets = UIEdgeInsets()
    //高亮元素Action
    public var focusAction: HandlerFocusAction?
    
    //动作按钮
    //动作按钮frame
    public var buttonFrame: CGRect?
    //动作按钮title
    public var buttonTitle: String?
    //动作按钮image
    public var buttonBackgroundImageName: String?
    //动作按钮action
    public var action: HandlerAction?
    
    //功能介绍页
    public var introduceFrame: CGRect?
    //功能介绍页图片 判断后缀存在后缀按图片处理，否则处理为文本
    public var introduce: String?
    //文本字体
    public var introduceFont: UIFont?
    //文本颜色
    public var introduceTextColor: UIColor?
    
    //指示视图（功能拓展）
    public var indicatorImageName: String?
    
    //视图显示优先顺序
    public var alignmentPriority: AlignmentPriority?
    
    init(focusView: UIView?, focusCornerRadius: CGFloat = 0, focusInsets: UIEdgeInsets = UIEdgeInsets()) {
        self.focusView = focusView
        self.focusCornerRadius = focusCornerRadius
        self.focusInsets = focusInsets
    }
    
    init(focusFrame: CGRect?, focusCornerRadius: CGFloat = 0, focusInsets: UIEdgeInsets = UIEdgeInsets()) {
        self.focusFrame = focusFrame
        self.focusCornerRadius = focusCornerRadius
        self.focusFrame = focusFrame
    }
}
