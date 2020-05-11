//
//  UIViewController+Extension.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/11.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit
import Photos

extension UIViewController {
    // AlbumImagePicker提供给外部调用的接口，同于显示图片选择页面
    func presentAlbumImagePicker(maxSelected:Int = Int.max, completeHandler:((_ assets:[PHAsset])->())?) -> AlbumImagePickerViewController? {
        
        if let vc = UIStoryboard(name: "AlbumImagePicker", bundle: nil).instantiateViewController(withIdentifier: "imagePickerVC") as? AlbumImagePickerViewController {
            //设置选择完毕后的回调
            vc.completeHandler = completeHandler
            
            //设置图片最多选择的数量
            vc.maxSelected = maxSelected
            
            //将图片选择视图控制器外添加个导航控制器，并显示
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: nil)
            return vc
        }
        return nil
    }
}
