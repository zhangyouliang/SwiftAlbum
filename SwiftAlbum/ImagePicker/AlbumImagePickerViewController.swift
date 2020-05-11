//
//  AlbumImagePickerViewController.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/10.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit
import Photos

// 相簿列表项
struct AlbumItem {
    // 封面
    var cover:UIImage
    // 相簿名称
    var title:String?
    // 相簿内的资源
    var fetchResult:PHFetchResult<PHAsset>
}

class AlbumImagePickerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    // 相簿列表项集合
    var items: [AlbumItem] = []
    
    // 带缓存的图片管理对象
    var imageManager: PHCachingImageManager?
    
    // 每次最多可选择的照片数量
    var maxSelected: Int = Int.max
    
    // 照片选择完毕后的回调
    var completeHandler: ((_ assets:[PHAsset])->())?
    
    private let cellID:String = "cell"
    private let cellHeight:CGFloat = 55
    
    
    // 从xib或者storyboard加载完毕就会调用
    // MARK: life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            
            // 列出所有系统的智能相册
            let smartOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: smartOptions)
            self.convertCollection(collection: smartAlbums)
            
            // 列出所有用户创建的相册
            let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self.convertCollection(collection: userCollections as! PHFetchResult<PHAssetCollection>)
            
            // 相册按包含的照片数量排序（降序）
            self.items.sort { (item1, item2) -> Bool in
                return item1.fetchResult.count > item2.fetchResult.count
            }
            
            // 异步加载表格数据,需要在主线程中调用reloadData() 方法
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                
                // 首次进来后直接进入第一个相册图片展示页面（相机胶卷）
                self.jumpImageCollectionVC(index: 0,animated: false)
            }
        })
        // 初始化和重置缓存
        self.imageManager = PHCachingImageManager()
        self.resetCachedAssets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题
        title = "照片"
        // 设置表格相关样式属性
        self.tableView.separatorInset = .zero
        self.tableView.rowHeight = cellHeight
        // 自适应高
        //self.tableView.rowHeight = UITableView.automaticDimension;
        //self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView(frame: .zero)
        // 添加导航栏右侧的取消按钮
        let rightBarItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action:#selector(cancelBtnClicked) )
        self.navigationItem.rightBarButtonItem = rightBarItem
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(AlbumImagePickerTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    // 取消按钮点击监听方法
    @objc func cancelBtnClicked() {
        // 退出当前vc
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // 页面跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 如果是跳转到展示相簿缩略图页面
        if segue.identifier == "showImages"{
            // 获取照片展示控制器
            guard let imageCollectionVC = segue.destination
                as? AlbumImageCollectionViewController,
                let cell = sender as? AlbumImagePickerTableViewCell else{
                    return
            }
            // 设置回调函数
            imageCollectionVC.completeHandler = completeHandler
            
            // 设置标题
            imageCollectionVC.title = cell.titleLabel.text
            
            // 设置最多可选图片数量
            imageCollectionVC.maxSelected = self.maxSelected
            guard  let indexPath = self.tableView.indexPath(for: cell) else { return }
            
            // 获取选中的相簿信息
            let fetchResult = self.items[indexPath.row].fetchResult
            
            // 传递相簿内的图片资源
            imageCollectionVC.assetsFetchResults = fetchResult
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Helpers
    // 由于系统返回的相册集名称为英文，我们需要转换为中文
    private func titleOfAlbumForChinese(title:String?) -> String? {
        if title == "Slo-mo" {
            return "慢动作"
        } else if title == "Recently Added" {
            return "最近添加"
        } else if title == "Recents" {
            return "最近项目"
        } else if title == "Favorites" {
            return "个人收藏"
        } else if title == "Recently Deleted" {
            return "最近删除"
        } else if title == "Videos" {
            return "视频"
        } else if title == "All Photos" {
            return "所有照片"
        } else if title == "Selfies" {
            return "自拍"
        } else if title == "Screenshots" {
            return "屏幕快照"
        } else if title == "Camera Roll" {
            return "相机胶卷"
        } else if title == "Animated" {
            return "动图"
        }
        return title
    }
    func jumpImageCollectionVC(index:Int,animated:Bool = true){
        if let imageCollectionVC = self.storyboard?
            .instantiateViewController(withIdentifier: "ImageCollectionVC")
            as? AlbumImageCollectionViewController{
            imageCollectionVC.title = self.items.first?.title
            imageCollectionVC.assetsFetchResults = self.items[index].fetchResult
            imageCollectionVC.completeHandler = self.completeHandler
            imageCollectionVC.maxSelected = self.maxSelected
            self.navigationController?.pushViewController(imageCollectionVC, animated: animated)
        }
    }
    // 判断是否已经存在
    private func hasInItems(title:String?) -> Bool{
        var has:Bool = false
        for item in self.items {
            if item.title == title{
                has = true
                break
            }
        }
        return has
    }
    // 转化处理获取到的相簿
    private func convertCollection(collection:PHFetchResult<PHAssetCollection>){
        for i in 0..<collection.count{
            
            // 获取出但前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            let c = collection[i]
            let assetsFetchResult = PHAsset.fetchAssets(in: c , options: resultsOptions)
            // 没有图片的空相簿不显示
            if assetsFetchResult.count > 0 {
                let title = titleOfAlbumForChinese(title: c.localizedTitle)
                // 获取缩略图
                guard let lastObject = assetsFetchResult.lastObject else {
                    return
                }
                self.imageManager?.requestImage(for: lastObject, targetSize: CGSize(width: self.cellHeight, height: self.cellHeight), contentMode: .aspectFill, options: nil) { (image, _) in
                    if image != nil && !self.hasInItems(title: title){
                        self.items.append(AlbumItem(cover: image!, title: title, fetchResult: assetsFetchResult))
                    }
                }
            }
        }
    }
    
    
    // 重置缓存
    func resetCachedAssets() {
        self.imageManager?.stopCachingImagesForAllAssets()
    }

}

// 相簿列表页控制器UITableViewDelegate,UITableViewDataSource协议方法的实现
// MARK: UITableViewDelegate, UITableViewDataSource
extension AlbumImagePickerViewController: UITableViewDelegate, UITableViewDataSource {
    // 设置单元格内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            // 同一形式的单元格重复使用，在声明时已注册
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
                as? AlbumImagePickerTableViewCell
            
            let item = self.items[indexPath.row]
            cell?.coverImageView.image = item.cover
            cell?.titleLabel.text = "\(item.title ?? "") "
            cell?.countLabel.text = "（\(item.fetchResult.count)）"
            return cell!
    }
    
    // 表格单元格数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // 表格单元格选中
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.jumpImageCollectionVC(index: indexPath.row)
    }
}

