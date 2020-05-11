//
//  AlbumImagePickerTableViewCell.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/11.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit
import SnapKit
// 相簿列表单元格
class AlbumImagePickerTableViewCell: UITableViewCell {

    // 封面
    var coverImageView: UIImageView = UIImageView()
    // 相簿名称标签
    var titleLabel: UILabel = UILabel()
    // 照片数量标签
    var countLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutMargins = .zero
        self.accessoryType = .disclosureIndicator

        // 属性设置
        titleLabel.textColor = .gray
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        
        self.contentView.addSubview(coverImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(countLabel)
        coverImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(self.contentView.snp.height)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(coverImageView.snp.right).offset(10)
        }
        countLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
