//
//  EmbedSectionView.swift
//  EmbedViewControllerDemo
//
//  Created by zhangweiwei on 2016/12/29.
//  Copyright © 2016年 erica. All rights reserved.
//

import UIKit

class EmbedSectionItem {
    
    var title: String?
    var image: UIImage?
    var selectedImage: UIImage?
    var color: UIColor = UIColor.black
    var selectedColor: UIColor = UIColor.red
    var font: UIFont = UIFont.systemFont(ofSize: 14)
    
    
    fileprivate var isSelected = false
}

private let kEmbedSectionItemCellReuseID = "EmbedSectionItemCell"

class EmbedSectionItemCell: UICollectionViewCell {
    
    var item: EmbedSectionItem? {
        
        didSet{
            
            guard let item = item else {
                return
            }
            
            btn.setTitle(item.title, for: .normal)
            btn.setImage(item.image, for: .normal)
            btn.setTitleColor(item.color, for: .normal)
            btn.setTitleColor(item.selectedColor, for: .selected)
            btn.titleLabel?.font = item.font
            btn.setImage(item.selectedImage, for: .selected)
            
            btn.isSelected = item.isSelected
            
        }
        
    }
    
    fileprivate lazy var btn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.isUserInteractionEnabled = false
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(btn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        btn.frame = bounds
    }
    
}

class EmbedSectionView: UIView {
    
    var progress: CGFloat = 0 {
        
        didSet{
            
            
            indicatorView.frame.origin.x = (collectionView.contentSize.width - layout.itemSize.width) * progress
            
        }
        
    }
    
    var indexClosure: ((_ index: Int) -> ())?

    var items: [EmbedSectionItem]
    
    var maxDisplayCount = 5
    
    var index = 0{
        
        didSet {
            
            let indexPath = IndexPath(item: index, section: 0)
            
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            let centerX = layout.itemSize.width * (CGFloat(index) + 0.5)
            
            UIView.animate(withDuration: 0.25) {
                
                self.indicatorView.center.x = centerX
                
            }
            
            collectionView.reloadData()
            
        }
        
    }
    
    fileprivate lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    fileprivate lazy var indicatorView: UIView = {
        
        let indicatorView = UIView()
        
        indicatorView.backgroundColor = UIColor.red
        
        return indicatorView
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        
        let c = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        
        c.dataSource = self
        c.delegate = self
        
        c.backgroundColor = UIColor.clear
        c.register(EmbedSectionItemCell.self, forCellWithReuseIdentifier: kEmbedSectionItemCellReuseID)
        
        c.showsVerticalScrollIndicator = false
        
        c.showsHorizontalScrollIndicator = false
//        c.bounces = false
        
        return c
        
    }()
    
    init(items: [EmbedSectionItem]) {
        
        self.items = items
        
        super.init(frame: .zero)
        
        addSubview(collectionView)
        
        collectionView.addSubview(indicatorView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        
        var itemW: CGFloat = 0
        
        if items.count > maxDisplayCount {
            itemW = bounds.width / CGFloat(maxDisplayCount)
        }else {
            itemW = bounds.width / CGFloat(items.count)
        }
        
        layout.itemSize = CGSize(width: itemW, height: collectionView.frame.height)
        
        indicatorView.frame.size.height = 2
        
        indicatorView.frame.origin.y = collectionView.bounds.height - indicatorView.frame.height
        
        indicatorView.frame.size.width = itemW
        
    }
    
    
}

extension EmbedSectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kEmbedSectionItemCellReuseID, for: indexPath) as!  EmbedSectionItemCell
        
        let item = items[indexPath.item]
        item.isSelected = index == indexPath.item
        
        cell.item = items[indexPath.item]
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if index == indexPath.item { return }
        
        index = indexPath.item
        indexClosure?(indexPath.item)
        
        
        
        
    }
    
    
    
}

