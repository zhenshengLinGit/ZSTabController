//
//  TestViewController.swift
//  ZSTabController
//
//  Created by 80263956 on 2019/8/8.
//  Copyright © 2019 guitarJason. All rights reserved.
//

import UIKit

var myIndex = 1
class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let label = UILabel.init(frame: CGRect.init(x: 100, y: 100, width: 200, height: 100))
        label.text = "我是测试\(myIndex)"
        myIndex += 1
        self.view.addSubview(label)
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
