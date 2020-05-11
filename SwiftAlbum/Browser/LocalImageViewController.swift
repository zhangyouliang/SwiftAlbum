//
//  LocalImageViewController.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/11.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit


class LocalImageViewController: BaseCollectionViewController {
    
    override var name: String { "本地图片" }
    
    override var remark: String { "最简单的场景，展示本地图片" }
    
    override func makeDataSource() -> [ResourceModel] {
        makeLocalDataSource()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.jx.dequeueReusableCell(BaseCollectionViewCell.self, for: indexPath)
        cell.imageView.image = self.dataSource[indexPath.item].localName.flatMap { UIImage(named: $0) }
        return cell
    }
    
    override func openPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath) {
        // 实例化
        let browser = JXPhotoBrowser()
        // 浏览过程中实时获取数据总量
        browser.numberOfItems = {
            self.dataSource.count
        }
        // 刷新Cell数据。本闭包将在Cell完成位置布局后调用。
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            let indexPath = IndexPath(item: context.index, section: indexPath.section)
            browserCell?.imageView.image = self.dataSource[indexPath.item].localName.flatMap { UIImage(named: $0) }
        }
        // 可指定打开时定位到哪一页
        browser.pageIndex = indexPath.item
        // 展示
        browser.show()
    }
}