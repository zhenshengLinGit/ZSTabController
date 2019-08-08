//
//  ViewController.swift
//  ZSTabController
//
//  Created by 80263956 on 2019/8/7.
//  Copyright © 2019 guitarJason. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabVC = ZSTabViewController()
        tabVC.view.frame = CGRect.init(x: 0, y: 100, width: self.view.bounds.width, height:self.view.bounds.height - 100)
        self.view.addSubview(tabVC.view)
        self.addChild(tabVC)
        
        tabVC.tabTitles = ["全部","联系人","群组","文件","聊天记录","我组织的","我组织的","我组织的","我组织的"];
        //    _tabVC.tabTitles = @[@"首页",@"日历",@"我组织的"];
        let testVC1 = TestViewController()
        let testVC2 = TestViewController()
        let testVC3 = TestViewController()
        let testVC4 = TestViewController()
        let testVC5 = TestViewController()
        let testVC6 = TestViewController()
        let testVC7 = TestViewController()
        let testVC8 = TestViewController()
        let testVC9 = TestViewController()
        tabVC.tabContents = [testVC1, testVC2, testVC3, testVC4, testVC5, testVC6, testVC7, testVC8, testVC9]

        tabVC.tabHeight = 44
        tabVC.tabHeader.normalTextColor = UIColor.gray
        tabVC.tabHeader.selectedTextColor = UIColor.red
        tabVC.tabHeader.indicatorColor = UIColor.red
        tabVC.tabHeader.normalTextFont = UIFont.systemFont(ofSize: 16)
        tabVC.tabHeader.selectedTextFont = UIFont.systemFont(ofSize: 16)
        
        tabVC.delegate = self
//        tabVC.disableContentScroll = true
        
        tabVC.changeSeletedIndex(3, animate: false)
    }


}


extension ViewController: ZSTabViewControllerDelegate {
    func selectedTabAtIndex(_ tabVC: ZSTabViewController, index: Int) {
        print("索引更新了- \(index)")
    }
}
