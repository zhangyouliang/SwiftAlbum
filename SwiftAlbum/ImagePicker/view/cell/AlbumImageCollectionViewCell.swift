//
//  AlbumImageCollectionViewCell.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/11.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit


protocol AlbumImageCollectionViewCellDeletate:class {
    func selectedIconClick(_ indexPath: IndexPath?,selected:Bool)
    func imageClick(_ indexPath: IndexPath?)
}

// 图片缩略图集合页单元格
class AlbumImageCollectionViewCell: UICollectionViewCell {

    // 显示缩略图
    lazy var imageView: UIImageView = {
       return UIImageView()
    }()
    
    // 显示选中状态的图标
    lazy var selectedIcon:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "btn_checkbox"), for: .normal)
        btn.setImage(UIImage(named: "btn_checkbox_a"), for: .selected)
        btn.addTarget(self, action: #selector(self.selectedAction), for: .touchUpInside)
        return btn
    }()
    
    
    // 设置是否选中
    open override var isSelected: Bool {
        didSet{
            selectedIcon.isSelected = isSelected
        }
    }
    
    weak var delegate:AlbumImageCollectionViewCellDeletate?
    
    // 当前 cell 坐标
    var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(selectedIcon)
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.imageViewAction))
        imageView.addGestureRecognizer(tap)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        selectedIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 播放动画，是否选中的图标改变时使用
    func playAnimate() {
        // 图标先缩小，再放大
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.selectedIcon.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4, animations: {
                self.selectedIcon.transform = CGAffineTransform.identity
            })
        }, completion: nil)
    }
    @objc func imageViewAction(){
        guard let action = self.delegate else {
            return
        }
        action.imageClick(self.indexPath)
    }
    @objc func selectedAction(sender:UIButton){
        guard let action = self.delegate else {
            return
        }
        sender.isSelected = !sender.isSelected
        action.selectedIconClick(self.indexPath, selected: sender.isSelected)
    }
}
