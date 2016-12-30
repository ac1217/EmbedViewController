//
//  TestViewController.swift
//  EmbedViewControllerDemo
//
//  Created by zhangweiwei on 2016/12/29.
//  Copyright © 2016年 erica. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var vcs = [UIViewController]()
        for _ in 0...4 {
            
            vcs.append(ViewController())
            
        }
        
        let vc = UIViewController()
        vcs.append(vc)
        
        let evc = EmbedViewController(viewControllers: vcs)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        headerView.backgroundColor = UIColor.red
        evc.embedHeaderView = headerView
        
        
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        sectionView.backgroundColor = UIColor.blue
        evc.embedSectionView = sectionView
        
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
//        footerView.backgroundColor = UIColor.purple
//        evc.embedFooterView = footerView
        
        navigationController?.pushViewController(evc, animated: true)
        
//        present(evc, animated: true, completion: nil)
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
