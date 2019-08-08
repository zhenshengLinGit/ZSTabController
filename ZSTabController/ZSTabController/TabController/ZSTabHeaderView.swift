//
//  ZSTabHeaderView.swift
//  ZSTabController
//
//  Created by 80263956 on 2019/8/7.
//  Copyright © 2019 guitarJason. All rights reserved.
//

import UIKit

let defaulSelectedColor: UIColor = UIColor.orange
let tabUnscrollMaxCount = 5 // 一页最多容纳的标签个数
let tabViewTag = 1000

protocol ZSTabHeaderViewDelegate: class {
    func selectedTabAtIndex(_ headerView: ZSTabHeaderView, index: Int)
}

extension ZSTabHeaderViewDelegate {
    func selectedTabAtIndex(_ headerView: ZSTabHeaderView, index: Int) {}
}

class ZSTabHeaderView: UIView {

    weak var delegate: ZSTabHeaderViewDelegate?
    
    //MARK: 控件相关
    private lazy var tabViews: [UILabel] = {
        return [UILabel]()
    }()
    
    private lazy var contentView: UIScrollView = {
        let _contentView = UIScrollView.init()
        _contentView.bounces = false
        _contentView.showsHorizontalScrollIndicator = false
        if #available(iOS 11, *) {
            _contentView.contentInsetAdjustmentBehavior = .never
        }
        return _contentView
    }()
    
    private lazy var indicator: UIView = {
        let _indicator = UIView.init()
        _indicator.backgroundColor = indicatorColor
        return _indicator
    }()
    
    private lazy var bottomLine: UIView = {
        let _bottomLine = UIView.init()
        _bottomLine.backgroundColor = lineColor
        return _bottomLine
    }()
    
    //MARK: 属性设置相关
    /* 标签的名称集合，赋值之后就会开始布局 */
    var tabTitles: [String] = [] {
        didSet {
            self.setupDetail()
        }
    }
    
    /* 指示器的颜色 */
    var indicatorColor: UIColor = defaulSelectedColor {
        didSet {
            indicator.backgroundColor = indicatorColor
        }
    }
    
    /* 底部线的颜色 */
    var lineColor: UIColor = UIColor.init(white: 0.85, alpha: 1) {
        didSet {
            bottomLine.backgroundColor = lineColor
        }
    }
    
    /* 选中索引 */
    private var selectedIndex: Int = 0
    
    /* 标签的宽度 */
    var fixedTabWidth: CGFloat?
    private var tabWidth: CGFloat = 0
    
    var normalTextFont: UIFont = UIFont.systemFont(ofSize: 14)
    var selectedTextFont: UIFont = UIFont.systemFont(ofSize: 14)
    var normalTextColor: UIColor = UIColor.darkText
    var selectedTextColor: UIColor = defaulSelectedColor // 默认同指示器颜色
    
    // YES时会调整tab位置，使它总是在视图中间；NO时指示调整使得tab不被遮挡
    var indicatorAlwaysInCenter: Bool = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    func setupUI() {
        self.addSubview(contentView)
        self.addSubview(bottomLine)
        contentView.addSubview(indicator)
        contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickTabView(tap :))))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        let tabHeight = self.frame.size.height
        // tab的宽度，当tab的个数小于最大值时，宽度均分。
        if fixedTabWidth == nil {
            if tabTitles.count < tabUnscrollMaxCount && tabTitles.count > 0 {
                tabWidth = self.frame.width / CGFloat(tabTitles.count)
            } else {
                tabWidth = self.frame.width / CGFloat(tabUnscrollMaxCount)
            }
        } else {
            tabWidth = fixedTabWidth!
        }
        
        contentView.frame = self.bounds
        contentView.contentSize = CGSize.init(width: CGFloat(tabTitles.count) * tabWidth, height: 0)
        let lineHeight = 1 / UIScreen.main.scale
        bottomLine.frame = CGRect.init(x: 0, y: tabHeight - lineHeight, width: self.frame.width, height: lineHeight)
        indicator.frame = CGRect.init(x: CGFloat(selectedIndex) * tabWidth, y: tabHeight - 2, width: tabWidth, height: 2)
        
        for index in 0..<tabViews.count {
            let tabView = tabViews[index]
            tabView.frame = CGRect.init(x: CGFloat(index) * tabWidth, y: 0, width: tabWidth, height: tabHeight)
        }
        
        indicator.superview?.bringSubviewToFront(indicator)
    }
    
    func setupDetail() {
        
        // 先移除之前的
        for tabView in tabViews {
            tabView.removeFromSuperview()
        }
        tabViews.removeAll()
        
        let tabHeight = self.frame.size.height
        for index in 0..<tabTitles.count {
            
            // 标题Label
            let tabView = UILabel.init(frame: CGRect.init(x: CGFloat(index) * tabWidth, y: 0, width: tabWidth, height: tabHeight))
            tabView.textAlignment = .center
            tabView.font = normalTextFont
            tabView.textColor = normalTextColor
            tabView.text = tabTitles[index]
            contentView.addSubview(tabView)
            tabViews.append(tabView)
        }
    }
    
    // 更改标签的内容
    func changeTitle(_ title: String, index: Int) {
        if index < 0 || index > tabViews.count { return }
        let tabView = tabViews[index]
        tabView.text = title
    }
    
    // 更改选中索引
    func changeSeletedIndex(_ index: Int, animated: Bool = true) {
        
        if index == selectedIndex || index < 0 || index >= tabViews.count { return }
        
        // 取消之前的样式
        let lastTabView = tabViews[selectedIndex]
        lastTabView.textColor = normalTextColor
        lastTabView.font = normalTextFont
        
        selectedIndex = index
        let currentTabView = tabViews[selectedIndex]
        currentTabView.textColor = selectedTextColor
        currentTabView.font = selectedTextFont
        
        // 指示器位移
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.indicator.frame.origin.x = CGFloat(self.selectedIndex) * self.tabWidth
            }
        } else {
            indicator.frame.origin.x = CGFloat(selectedIndex) * tabWidth
        }
        
        // 将指示器保持在中间位置
        if indicatorAlwaysInCenter {
            let minOffsetX = CGFloat(0.0), maxOffsetX = contentView.contentSize.width - contentView.bounds.size.width
            let destCenterX = contentView.bounds.size.width / 2.0
            var destOffsetX = tabWidth * CGFloat(selectedIndex) + indicator.frame.width / 2.0 - destCenterX
            destOffsetX = max(minOffsetX, min(destOffsetX, maxOffsetX))
            contentView.setContentOffset(CGPoint.init(x: destOffsetX, y: 0), animated: animated)
        } else {
            // 当指示器在左右显示不全时，使其显示全
            if indicator.frame.origin.x < contentView.contentOffset.x {
                contentView.setContentOffset(CGPoint.init(x: indicator.frame.origin.x, y: 0), animated: animated)
            } else if indicator.frame.origin.x + tabWidth > contentView.contentOffset.x + contentView.bounds.size.width {
                contentView.setContentOffset(CGPoint.init(x: indicator.frame.origin.x + tabWidth - contentView.bounds.size.width, y: 0), animated: animated)
            }
        }
        
        // 回调
        self.delegate?.selectedTabAtIndex(self, index: selectedIndex)
        
    }
    
    //MARK: 回调
    @objc func clickTabView(tap: UITapGestureRecognizer) {
        let locationX = tap.location(in: contentView).x
        let index = Int(locationX / tabWidth)
        if index != selectedIndex {
            self.changeSeletedIndex(index)
        }
    }
}
