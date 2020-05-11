//
//  NormalVCProtocol.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/11.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit

protocol NormalVCProtocol {
    /// 名称
    var name: String {
        get set
    }
    
    /// 说明
    var remark: String {
        get set
    }
}
