//
//  ZSTabViewController.swift
//  ZSTabController
//
//  Created by 80263956 on 2019/8/7.
//  Copyright © 2019 guitarJason. All rights reserved.
//

import UIKit

protocol ZSTabViewControllerDelegate: class {
    func selectedTabAtIndex(_ tabVC: ZSTabViewController, index: Int)
}

extension ZSTabViewControllerDelegate {
    func selectedTabAtIndex(_ tabVC: ZSTabViewController, index: Int) {}
}

class ZSTabViewController: UIViewController {

    weak var delegate: ZSTabViewControllerDelegate?
    
    private lazy var contentScrollView: UIScrollView = {
        let _contentScrollView = UIScrollView.init()
        _contentScrollView.isPagingEnabled = true
        _contentScrollView.isScrollEnabled = !disableContentScroll
        _contentScrollView.delegate = self
        _contentScrollView.showsVerticalScrollIndicator = false
        _contentScrollView.showsHorizontalScrollIndicator = false
        return _contentScrollView
    }()
    
    lazy var tabHeader: ZSTabHeaderView = {
        let _tabHeader = ZSTabHeaderView.init(frame: CGRect.zero)
        _tabHeader.delegate = self
        return _tabHeader
    }()
    
    //MARK: 属性设置
    /** 内容部分是否禁止滚动 */
    var disableContentScroll: Bool = false {
        didSet {
            contentScrollView.isScrollEnabled = !disableContentScroll
        }
    }
    
    /** tab栏的高度，默认44.0 */
    private var _tabHeight: CGFloat = 44.0
    var tabHeight: CGFloat {
        get {
            return _tabHeight
        }
        set {
            _tabHeight = newValue < 0 ? 44.0 : newValue
        }
    }
    
    /** 选中的tab索引，对外只读属性 */
    private(set) var selectedIndex: Int = 0
    
    /** 所有tab标题 */
    var tabTitles: [String] = []
    
    /** 内容视图，可以是viewController或者view。设置该属性前必须先设置tabTitles，值后就会开始布局 */
    var tabContents:[AnyObject] = [] {
        didSet {
            // tabTitles个数和tabContents个数必须相等
            assert(tabTitles.count == tabContents.count, "tabTitles个数和tabContents个数必须相等")
            tabHeader.tabTitles = tabTitles
            self.setupContentView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        if #available(iOS 11, *) {
            contentScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(contentScrollView)
        self.view.addSubview(tabHeader)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 布局frame
        let viewW = self.view.bounds.size.width
        let viewH = self.view.bounds.size.height
        tabHeader.frame = CGRect.init(x: 0, y: 0, width: viewW, height: tabHeight)
        contentScrollView.frame = CGRect.init(x: 0, y: tabHeader.frame.maxY, width: viewW, height: viewH - tabHeader.frame.maxY)
        contentScrollView.contentSize = CGSize.init(width: contentScrollView.frame.width * CGFloat(tabContents.count), height: contentScrollView.frame.height)
        
        for index in 0..<contentScrollView.subviews.count {
            let contentView = contentScrollView.subviews[index]
            contentView.frame = CGRect.init(x: CGFloat(index) * contentScrollView.frame.width, y: 0, width: contentScrollView.frame.width, height: contentScrollView.frame.height)
        }
    }
    
    func setupContentView() {
        // 移除之前的
        for subView in contentScrollView.subviews {
            subView.removeFromSuperview()
        }
        for childVC in self.children {
            childVC.removeFromParent()
        }
        
        // 添加子控件
        for index in 0..<tabContents.count {
            let content = tabContents[index]
            var contentView: UIView?
            if let contentV = content as? UIView {
                contentView = contentV
            } else if let contentVC = content as? UIViewController {
                contentView = contentVC.view
                self.addChild(contentVC)
            } else {
                assert(false, "tabContents的内容非UIViewController，也非UIView")
            }
            
            contentScrollView.addSubview(contentView!)
        }
        
        self.viewDidLayoutSubviews()
    }
    
    /** 修改某个tab的标题 */
    func changeTitle(_ title: String, ofIndex index: Int) {
        tabHeader.changeTitle(title, index: index)
    }

    /** 修改索引 */
    func changeSeletedIndex(_ index: Int, animate: Bool) {
        if index > tabContents.count || index == selectedIndex{
            return
        }
        selectedIndex = index
        tabHeader.changeSeletedIndex(selectedIndex)
        contentScrollView.setContentOffset(CGPoint.init(x: contentScrollView.bounds.width * CGFloat(selectedIndex), y: 0), animated: false)
        delegate?.selectedTabAtIndex(self, index: selectedIndex)
    }
}

extension ZSTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        if index != selectedIndex {
            selectedIndex = index
            tabHeader.changeSeletedIndex(index, animated: true)
        }
    }
}

extension ZSTabViewController: ZSTabHeaderViewDelegate {
    func selectedTabAtIndex(_ headerView: ZSTabHeaderView, index: Int) {
        if index > tabContents.count || selectedIndex == index{
            return
        }
        
        selectedIndex = index
        // 这里不要动画，否则会跟scrollViewDidScroll的代码冲突
        contentScrollView.setContentOffset(CGPoint.init(x: contentScrollView.bounds.width * CGFloat(selectedIndex), y: 0), animated: false)
        delegate?.selectedTabAtIndex(self, index: selectedIndex)
    }
}
