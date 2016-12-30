//
//  ViewController.swift
//  EmbedViewControllerDemo
//
//  Created by zhangweiwei on 2016/12/25.
//  Copyright © 2016年 erica. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    lazy var tv: UITableView = {
       
        let tv = UITableView()
        
        tv.dataSource = self
        
        return tv
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "啊哈哈"
        view.addSubview(tv)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        tv.frame = view.bounds
    }
    
    
}

extension ViewController: UITableViewDataSource{
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(arc4random_uniform(100))
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let kUITableViewCellReuseID = "UITableViewCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: kUITableViewCellReuseID)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: kUITableViewCellReuseID)
            
        }
        
        cell.textLabel?.text = "我是第几行\(indexPath.row)"
        
        return cell
    }
    
    override var targetView: UIView {
        
        return self.tv
    }
    
//    override var sectionTitle: String? {
//        return "我是标题"
//    }
    
    
    override var sectionTitleColor: UIColor? {
        return UIColor.blue
    }
    
    override var sectionImage: UIImage? {
        return UIImage(named: "icon")
    }
    
    
}

