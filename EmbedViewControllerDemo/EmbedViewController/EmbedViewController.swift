//
//  EmbedViewController.swift
//  EmbedViewControllerDemo
//
//  Created by zhangweiwei on 2016/12/25.
//  Copyright © 2016年 erica. All rights reserved.
//

import UIKit

protocol EmbedViewControllerEmbedTarget {
    var targetView: UIView { get }
    var sectionTitle: String? { get }
    var sectionImage: UIImage? { get }
    var sectionSelectedImage: UIImage? { get }
    var sectionTitleColor: UIColor? { get }
    var sectionTitleSelectedColor: UIColor? { get }
    var sectionTitleFont: UIFont? { get }
}

extension UIViewController: EmbedViewControllerEmbedTarget {
    
    internal var sectionSelectedImage: UIImage? {
        return nil
    }
    
    internal var sectionTitleSelectedColor: UIColor? {
        return nil
    }

    internal var sectionTitleColor: UIColor? {
        return nil
    }
    
    internal var sectionTitleFont: UIFont? {
        return nil
    }
    
    internal var sectionTitle: String? {
        return title
    }
    
    internal var sectionImage: UIImage? {
        return nil
    }

    
    internal var targetView: UIView {
        return view
    }
    
    

}

@objc protocol EmbedViewControllerDelegate{
    
    @objc optional func embedViewController(_ embedViewController: EmbedViewController, didChanged progress: CGFloat)
    
    @objc optional func embedViewController(_ embedViewController: EmbedViewController, didSelected index: Int)
    
}

// MARK: - Setter
extension EmbedViewController {
    
    func set(_ index: Int, animate: Bool) {
        
        if index >= childViewControllers.count { return }
        
        self.index = index
        
        embedCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animate)
 
    }
    
}

private let kUICollectionViewCellReuseID = "UICollectionViewCell"

class EmbedViewController: UIViewController {
    
    init(viewControllers: [UIViewController]) {
        
        super.init(nibName: nil, bundle: nil)
        
        viewControllers.forEach { (vc) in
            addChildViewController(vc)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var embedHeaderView: UIView?{
        didSet{
            embedTableView.tableHeaderView = embedHeaderView
        }
    }
    var embedSectionView: UIView?{
        didSet{
            embedTableView.reloadData()
        }
    }
    var embedFooterView: UIView?{
        didSet{
            
            embedTableView.tableFooterView = embedFooterView
        }
    }
    
    var index: Int = 0
    var progress: CGFloat = 0
    
    var progressClosure: ((_ progress: CGFloat) -> ())?
    var indexClosure: ((_ index: Int) -> ())?
    
    var delegate: EmbedViewControllerDelegate?
    
    
    fileprivate lazy var defaultEmbedSectionView: EmbedSectionView = {
       
        var items = [EmbedSectionItem]()
        self.childViewControllers.forEach { (vc) in
            
            let item = EmbedSectionItem()
            
            item.title = vc.sectionTitle
            item.image = vc.sectionImage
            
            if let selectedImage = vc.sectionSelectedImage {
                item.selectedImage = selectedImage
            }
            
            if let color = vc.sectionTitleColor {
                item.color = color
            }
            
            
            if let selectedColor = vc.sectionTitleSelectedColor {
                item.selectedColor = selectedColor
            }
            
            
            if let font = vc.sectionTitleFont {
                item.font = font
            }
            
            items.append(item)
            
        
        }
        
        let defaultEmbedSectionView = EmbedSectionView(items: items)
        
        defaultEmbedSectionView.frame.size.height = 44
        
        defaultEmbedSectionView.indexClosure = {[unowned self] index in
            
            
            self.embedCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            
        }

        return defaultEmbedSectionView
        
    }()
    
    fileprivate lazy var embedTableView: EmbedTableView = {
        let embedTableView = EmbedTableView()
        
        embedTableView.translatesAutoresizingMaskIntoConstraints = false
        
        embedTableView.dataSource = self
        embedTableView.delegate = self
        
        return embedTableView
    }()
    
    fileprivate lazy var embedCollectionViewLayout: UICollectionViewFlowLayout = {
       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
        
    }()
    
    fileprivate lazy var embedCollectionView: UICollectionView = {
       
        let embedCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.embedCollectionViewLayout)
        
        embedCollectionView.isPagingEnabled = true
        embedCollectionView.showsHorizontalScrollIndicator = false
        embedCollectionView.showsVerticalScrollIndicator = false
        embedCollectionView.bounces = false
        embedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        embedCollectionView.dataSource = self
        embedCollectionView.delegate = self
        
        embedCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kUICollectionViewCellReuseID)
        
        return embedCollectionView
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        
        
        
    }
    
    fileprivate var adjustTopLayoutGuide: CGFloat {
        
        if let nav = navigationController, nav.navigationBar.isTranslucent, automaticallyAdjustsScrollViewInsets {
            
            return nav.navigationBar.frame.maxY
        }
        
        return 0
       
    }
    
    fileprivate var shouldNotify = true
    
    fileprivate var previousContentOffsetY: CGFloat = 0
    
    
    deinit {
        
        childViewControllers.forEach { (vc) in
            
            guard let scrollView = vc.targetView as? UIScrollView else {
                return
            }
            
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
        
    }
    
}


// MARK: - Event
extension EmbedViewController {
    
    // KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let scrollView = object as? UIScrollView, shouldNotify else {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        
        let sectionOffsetY = embedTableView.rect(forSection: 0).origin.y - adjustTopLayoutGuide
        
        if (embedTableView.contentOffset.y < sectionOffsetY && offsetY > previousContentOffsetY) || offsetY < 0 {
            
            shouldNotify = false
            scrollView.contentOffset.y = 0
            shouldNotify = true
            
        }
        
        if offsetY <= 0 {
            
            childViewControllers.forEach({ (vc) in
                
                guard vc.view != scrollView, let sv = vc.view as? UIScrollView, sv.contentOffset.y != 0 else {
                    return
                }
                shouldNotify = false
                sv.contentOffset.y = 0
                shouldNotify = true
            })
            
        }
        
        previousContentOffsetY = scrollView.contentOffset.y
        
    }
    
}

// MARK: - Private Method
extension EmbedViewController {
    
    
    
    func setupUI(){
        
        view.addSubview(embedTableView)
        
        childViewControllers.forEach { (vc) in
            
  
            let view = vc.targetView
            
            if view is UIScrollView {
                
                let sv = view as! UIScrollView
                
                sv.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
                
            }
            
        }
        
        
        
        
        
   
    }
    
    func setupLayout(){
        
        let left = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: embedTableView, attribute: .left, multiplier: 1, constant: 0)
        
        let right = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: embedTableView, attribute: .right, multiplier: 1, constant: 0)
        
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: embedTableView, attribute: .top, multiplier: 1, constant: 0)
        
        let bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: embedTableView, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([left, right, top, bottom])
        
    }
    
}

// MARK: - UIScrollViewDelegate
extension EmbedViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == embedTableView {
            
            let offsetY = scrollView.contentOffset.y
            
            let sectionOffsetY = embedTableView.rect(forSection: 0).origin.y - adjustTopLayoutGuide
            
            if offsetY > sectionOffsetY || previousContentOffsetY > 0 {
                scrollView.contentOffset.y = sectionOffsetY
            }
            
        }else {
            
            progress = scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width)
            
            delegate?.embedViewController?(self, didChanged: progress)
            
            progressClosure?(progress)
            
            
            if embedSectionView == nil {
                defaultEmbedSectionView.progress = progress
            }
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView != embedCollectionView {
            return
        }
        
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if index == self.index { return }
        
        self.index = index
        
        previousContentOffsetY = 0
        
        delegate?.embedViewController?(self, didSelected: index)
        indexClosure?(index)
        
        if embedSectionView == nil {
            
            defaultEmbedSectionView.index = index
            
        }
        
    }
    
    
}

// MARK: - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension EmbedViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.bounds.size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return childViewControllers.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kUICollectionViewCellReuseID, for: indexPath)
        
        cell.contentView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        if let view = childViewControllers[indexPath.item].view {
            
            view.frame = cell.contentView.bounds
            
            cell.contentView.addSubview(view)
            
        }
        
        
        return cell
        
    }
    
    
    
}

// MARK: - UITableViewDataSource,UITableViewDelegate
extension EmbedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return tableView.bounds.height - (embedSectionView?.frame.height ?? defaultEmbedSectionView.frame.height) - (embedFooterView?.frame.height ?? 0) - adjustTopLayoutGuide
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let kUITableViewCellReuseID = "UITableViewCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: kUITableViewCellReuseID)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: kUITableViewCellReuseID)
            cell.selectionStyle = .none
            cell.contentView.addSubview(embedCollectionView)
            
            let left = NSLayoutConstraint(item: cell.contentView, attribute: .left, relatedBy: .equal, toItem: embedCollectionView, attribute: .left, multiplier: 1, constant: 0)
            
            let right = NSLayoutConstraint(item: cell.contentView, attribute: .right, relatedBy: .equal, toItem: embedCollectionView, attribute: .right, multiplier: 1, constant: 0)
            
            let top = NSLayoutConstraint(item: cell.contentView, attribute: .top, relatedBy: .equal, toItem: embedCollectionView, attribute: .top, multiplier: 1, constant: 0)
            
            let bottom = NSLayoutConstraint(item: cell.contentView, attribute: .bottom, relatedBy: .equal, toItem: embedCollectionView, attribute: .bottom, multiplier: 1, constant: 0)
            
            cell.contentView.addConstraints([left, right, top, bottom])
            
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return embedSectionView?.frame.height ?? defaultEmbedSectionView.frame.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return embedSectionView ?? defaultEmbedSectionView
    }
}


// MARK: - EmbedTableView
fileprivate class EmbedTableView: UITableView, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        
        panGestureRecognizer.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        
        if otherGestureRecognizer.view is UICollectionView {
            
            return false
            
        }
        
        return true
    }
    
}

