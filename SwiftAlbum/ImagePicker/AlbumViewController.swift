//
//  AlbumViewController.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/11.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//


import UIKit
import Photos

class AlbumViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,NormalVCProtocol {
    
    /// 名称
    var name: String = "图片选择"
    
    /// 说明
    var remark: String = "自定义图片选择器"
    
    // 存放图片的数组
    var imageArray = [UIImage]()
    
    // 存放图片等collectionview
    var collectionView: UICollectionView!
    
    // 最大图片张数
    let maxImageCount = 9
    
    // 添加图片按钮
    var addButton: UIButton!
    
    // 选择上传图片方式弹窗
    var addImageAlertViewController: UIAlertController!
    
    // 缩略图大小
    var imageSize: CGSize!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = name
        self.navigationController?.navigationBar.isTranslucent = false
        
        // 设置背景色
        self.view.backgroundColor = .groupTableViewBackground
        
        // 设置添加图片按钮相关属性
        addButton = UIButton(type: .custom)
        addButton.setTitle("添加图片", for: .normal)
        addButton.addTarget(self, action: #selector(addItem(_:)), for: .touchUpInside)
        addButton.backgroundColor = UIColor.init(red: 164 / 255, green: 193 / 255, blue: 244 / 255, alpha: 1)
        addButton.frame = CGRect(x: 20, y: 35, width: 100, height: 25)
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 8.0
        
        // 设置collection的layout
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        // 列间距
        layout.minimumInteritemSpacing = 10
        // 行间距
        layout.minimumLineSpacing = 10
        // 偏移量
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        
        // 设置collectionview的大小、背景色、代理、数据源
        collectionView = UICollectionView(frame: CGRect(origin: CGPoint(x: 10, y: 60), size: self.view.bounds.size), collectionViewLayout: layout)
        collectionView.backgroundColor = .gray
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 注册cell
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell")
        
        // 选择上传照片方式的弹窗设置
        addImageAlertViewController = UIAlertController(title: "请选择上传方式", message: "相册或者相机", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let cameraAction = UIAlertAction(title: "拍照", style: .default, handler: {
            (action: UIAlertAction) in self.cameraAction()
        })
        let albumAction = UIAlertAction(title: "从相册选择", style: .default, handler: {
            (action: UIAlertAction) in self.albumAction()
        })
        self.addImageAlertViewController.addAction(cancelAction)
        self.addImageAlertViewController.addAction(cameraAction)
        self.addImageAlertViewController.addAction(albumAction)
        
        self.view.addSubview(addButton)
        self.view.addSubview(collectionView)
        
        
        // 自动弹出
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.albumAction()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 获取缩略图的大小
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        self.imageSize = cellSize
    }
    
    // MARK: - 删除图片按钮监听方法
    @objc func removeItem(_ button: UIButton) {
        // 数据变更
        self.collectionView.performBatchUpdates({
            self.imageArray.remove(at: button.tag)
            let indexPath = IndexPath(item: button.tag, section: 0)
            let arr = [indexPath]
            self.collectionView.deleteItems(at: arr)
        }, completion: {(completion) in
            self.collectionView.reloadData()
        })
        
        // 判断是否使添加图片按钮生效
        if imageArray.count < 9 {
            self.addButton.isEnabled = true
            self.addButton.backgroundColor = UIColor.init(red: 164 / 255, green: 193 / 255, blue: 244 / 255, alpha: 1)
        }
    }
    
    // MARK: - 添加图片按钮监听方法
    @objc func addItem(_ button: UIButton) {
        self.present(addImageAlertViewController, animated: true, completion: nil)
    }
    
    // MARK: - 拍照监听方法
    func cameraAction() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 创建图片控制器
            let picker = UIImagePickerController()
            
            // 设置代理
            picker.delegate = self
            
            // 设置来源
            picker.sourceType = .camera
            
            // 允许编辑
            picker.allowsEditing = true
            
            // 打开相机
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else {
            // 弹出提示
            let title = "找不到相机"
            let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:"我知道了", style: .cancel, handler:nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - 相册监听方法
    func albumAction() {
        // 可选照片数量
        let count = maxImageCount - imageArray.count

        // 开始选择照片，最多允许选择count张
        _ = self.presentAlbumImagePicker(maxSelected: count) { (assets) in
            
            // 结果处理
            for asset in assets {
                // 从asset获取image
                let image = self.PHAssetToUIImage(asset: asset)
                
                // 数据变更
                self.collectionView.performBatchUpdates({
                    let indexPath = IndexPath(item: self.imageArray.count, section: 0)
                    let arr = [indexPath]
                    self.collectionView.insertItems(at: arr)
                    self.imageArray.append(image)
                }, completion: {(completion) in
                    self.collectionView.reloadData()
                })
                
                // 判断是否使添加图片按钮失效
                if self.imageArray.count > 8 {
                    self.addButton.isEnabled = false
                    self.addButton.backgroundColor = UIColor.darkGray
                }
            }
        }
    }
    
    // MARK: - 将PHAsset对象转为UIImage对象
    func PHAssetToUIImage(asset: PHAsset) -> UIImage {
        var image = UIImage()
        
        // 新建一个默认类型的图像管理器imageManager
        let imageManager = PHImageManager.default()
        
        // 新建一个PHImageRequestOptions对象
        let imageRequestOption = PHImageRequestOptions()
        
        // PHImageRequestOptions是否有效
        imageRequestOption.isSynchronous = true
        
        // 缩略图的压缩模式设置为无
        imageRequestOption.resizeMode = .none
        
        // 缩略图的质量为高质量，不管加载时间花多少
        imageRequestOption.deliveryMode = .highQualityFormat
        
        // 按照PHImageRequestOptions指定的规则取出图片
        imageManager.requestImage(for: asset, targetSize: self.imageSize, contentMode: .aspectFill, options: imageRequestOption, resultHandler: {
            (result, _) -> Void in
            image = result!
        })
        return image
    }
    
    // MARK: - 相机图片选择器
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 将相机刚拍好的照片拿出来
        let gotImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
        
        // 数据变更
        self.collectionView.performBatchUpdates({
            let indexPath = IndexPath(item: self.imageArray.count, section: 0)
            let arr = [indexPath]
            self.collectionView.insertItems(at: arr)
            self.imageArray.append(gotImage)
            print(self.imageArray.count)
            
        }, completion: {(completion) in
            self.collectionView.reloadData()
        })
        
        // 判断是否使添加图片按钮失效
        if imageArray.count > 8 {
            self.addButton.isEnabled = false
            self.addButton.backgroundColor = UIColor.darkGray
        }
        
        // 关闭此页面
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - collection代理方法实现
extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // 每个区的item个数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    // 分区个数
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 自定义cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = imageArray[indexPath.item]
        cell.button.addTarget(self, action: #selector(removeItem(_:)), for: UIControl.Event.touchUpInside)
        cell.button.tag = indexPath.row
        return cell
    }
    
    // 是否可以移动
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

