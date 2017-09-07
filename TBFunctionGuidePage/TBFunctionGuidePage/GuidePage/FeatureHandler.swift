//
//  FeatureHandler.swift
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

class FeatureHandler: NSObject {
    //高亮元素
    public var focusView: UIView?
    //高亮元素frame
    public var focusFrame: CGRect?
    //高亮元素圆角半径
    public var focusCornerRadius: CGFloat = 0
    //高亮元素Insets
    public var focusInsets: UIEdgeInsets = UIEdgeInsets()
}
