//
//  AlbumImageCollectionViewController.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/11.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit
import Photos


// 图片缩略图集合页控制器
class AlbumImageCollectionViewController: UIViewController {
    // 用于显示所有图片缩略图的collectionView
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 下方工具栏
    @IBOutlet weak var toolBar: UIToolbar!
    
    // 取得的资源结果，用了存放的PHAsset
    var assetsFetchResults: PHFetchResult<PHAsset>!
    
    // 带缓存的图片管理对象
    var imageManager: PHCachingImageManager!
    
    // 缩略图大小
    var assetGridThumbnailSize: CGSize!
    
    // 每次最多可选择的照片数量
    var maxSelected: Int = Int.max
    
    // 照片选择完毕后的回调
    var completeHandler: ((_ assets: [PHAsset])->())?
    
    // 完成按钮
    var completeButton: AlbumImageCompleteButton!
    // 预览按钮
    var prevButton: UIButton!
    
    private let cellID:String = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(AlbumImageCollectionViewCell.self, forCellWithReuseIdentifier: self.cellID)
        // 背景色设置为白色（默认是黑色）
        self.collectionView.backgroundColor = UIColor.white
        
        // 初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
        
        let cols:CGFloat = 4
        let spacing:CGFloat = 5
        
        let width = (self.view.bounds.width - (spacing * (cols+1)))/cols
        assetGridThumbnailSize = CGSize(width: width, height: width)
        
        //创建布局对象
        let layout = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        //设置 cell 的大小
        layout.itemSize = assetGridThumbnailSize
        //最小行间距
        layout.minimumLineSpacing = spacing
        //最小列间距
        layout.minimumInteritemSpacing = spacing
        //设置item块的大小 (可以用于自适应)
        //layout.estimatedItemSize = CGSize(width: 20, height: 60)
        //设置滚动方向
        layout.scrollDirection = .vertical
        // 设置 section 的内边距
        layout.sectionInset = UIEdgeInsets(top: spacing,left: spacing,bottom: spacing,right: spacing);
        
        
        // 允许多选
        self.collectionView.allowsMultipleSelection = true
        
        // 添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain,
                                           target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        // 添加下方工具栏的完成按钮
        completeButton = AlbumImageCompleteButton()
        completeButton.addTarget(target: self, action: #selector(finishSelect))
        completeButton.center = CGPoint(x: UIScreen.main.bounds.width - 50, y: 22)
        completeButton.isEnabled = false
        toolBar.addSubview(completeButton)
        // 预览按钮
        prevButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
        prevButton.addTarget(self, action: #selector(self.prevTarget), for: .touchUpInside)
        prevButton.center = CGPoint(x: 50, y: 22)
        prevButton.setTitle("预览", for: .normal)
        prevButton.setTitleColor(.gray, for: .disabled)
        //prevButton.setTitleColor(.black, for: .normal)
        prevButton.isEnabled = false
        toolBar.addSubview(prevButton)
    }
    
    @objc func prevTarget(){
        var assets:[PHAsset] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths{
                assets.append(assetsFetchResults[indexPath.row] )
            }
        }
        if let firstIndexPath = self.collectionView.indexPathsForSelectedItems?.first{
            self.openLocalPhotoBrowser(with: collectionView, indexPath: firstIndexPath, data: assets)
        }
        
    }
    // MARK: Helper
    // 重置缓存
    func resetCachedAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    // 取消按钮点击
    @objc func cancel() {
        // 退出当前视图控制器
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // 获取已选择个数
    func selectedCount() -> Int {
        return self.collectionView.indexPathsForSelectedItems?.count ?? 0
    }
    
    // 完成按钮点击
    @objc func finishSelect(){
        // 取出已选择的图片资源
        var assets:[PHAsset] = []
        if let indexPaths = self.collectionView.indexPathsForSelectedItems{
            for indexPath in indexPaths{
                assets.append(assetsFetchResults[indexPath.row] )
            }
        }
        // 调用回调函数
        self.navigationController?.dismiss(animated: true, completion: {
            self.completeHandler?(assets)
        })
    }
    func openLocalPhotoBrowser(with collectionView: UICollectionView, indexPath: IndexPath,data:[PHAsset]) {
        // 实例化
        let browser = JXPhotoBrowser()
        // 浏览过程中实时获取数据总量
        browser.numberOfItems = {
            data.count
        }
        // 刷新Cell数据。本闭包将在Cell完成位置布局后调用。
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            let indexPath = IndexPath(item: context.index, section: indexPath.section)
            let asset = data[indexPath.row]
            // 加载原图
            let originalImageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            self.imageManager.requestImage(for: asset, targetSize: originalImageSize, contentMode: .aspectFill, options: nil) {
                (image, _) in
                browserCell?.imageView.image = image
            }
        }
        // 可指定打开时定位到哪一页
        browser.pageIndex = indexPath.item
        // 展示
        browser.show()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
// 图片缩略图集合页控制器UICollectionViewDataSource,UICollectionViewDelegate协议方法的实现
extension AlbumImageCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // CollectionView项目
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults.count
    }
    
    // 获取单元格
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 获取storyboard里设计的单元格，不需要再动态添加界面元素
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AlbumImageCollectionViewCell
        let asset = self.assetsFetchResults[indexPath.row]
        // 获取缩略图
        self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize, contentMode: .aspectFill, options: nil) {
            (image, _) in
            cell.imageView.image = image
        }
        cell.indexPath = indexPath // 一定要设置!!!
        cell.delegate = self
        return cell
    }
}
// MARK: AlbumImageCollectionViewCellDeletate
extension AlbumImageCollectionViewController:AlbumImageCollectionViewCellDeletate{
    
    func imageClick(_ indexPath: IndexPath?) {
        var assets:[PHAsset] = []
        for i in 0..<self.assetsFetchResults.count{
            assets.append(self.assetsFetchResults[i])
        }
        self.openLocalPhotoBrowser(with: collectionView, indexPath: indexPath!, data: assets)
    }
    func selectedIconClick(_ indexPath: IndexPath?, selected: Bool) {
        if let cell = collectionView.cellForItem(at: indexPath!) as? AlbumImageCollectionViewCell {
            if selected {
                // 单元格选中响应
                // 设置为选中状态
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                // 获取选中的数量
                let count = self.selectedCount()
                // 如果选择的个数大于最大选择数
                if count > self.maxSelected {
                    // 设置为不选中状态
                    collectionView.deselectItem(at: indexPath!, animated: false)
                    // 弹出提示
                    let title = "你最多只能选择\(self.maxSelected)张照片"
                    let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title:"我知道了", style: .cancel, handler:nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                    // 如果不超过最大选择数
                else{
                    cell.isSelected = true
                    // 改变完成按钮数字，并播放动画
                    completeButton.num = count
                    if count > 0 && !self.completeButton.isEnabled{
                        completeButton.isEnabled = true
                        prevButton.isEnabled = true
                    }
                    cell.playAnimate()
                }
            }else{
                // 单元格取消选中响应
                // 设置为不选中状态
                collectionView.deselectItem(at: indexPath!, animated: false)
                // 获取选中的数量
                let count = self.selectedCount()
                completeButton.num = count
                // 改变完成按钮数字，并播放动画
                if count == 0{
                    completeButton.isEnabled = false
                    prevButton.isEnabled = false
                }
                cell.playAnimate()
            }
            
        }
    }
    
    
    
}
