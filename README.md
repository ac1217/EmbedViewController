# EmbedViewController
UITableView嵌套滚动框架,swift3.0实现,简单易用,快速集成类似两个tableView嵌套滚动需求
使用方法

```     
        // 初始化传入要显示的子控制器
        let evc = EmbedViewController(viewControllers: vcs)
        
        // 设置 herderView,记得给个高度哦
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
        headerView.backgroundColor = UIColor.red
        evc.embedHeaderView = headerView
        
        // 设置自定义的 sectionView,如果不穿,默认使用内部的sectionView,那子控制器需要遵守EmbedViewControllerEmbedTarget协议
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 35))
        sectionView.backgroundColor = UIColor.blue
        evc.embedSectionView = sectionView
        
        // 设置 footerView
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        footerView.backgroundColor = UIColor.purple
        evc.embedFooterView = footerView
        
        
        navigationController?.pushViewController(evc, animated: true)
        
 ```


``` 
  // 子控制器实现协议定制section样式,仅当使用默认的sectionView才有效
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

```
