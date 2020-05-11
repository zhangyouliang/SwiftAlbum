//
//  ViewController.swift
//  SwiftAlbum
//
//  Created by Youliang Zhang on 2020/5/10.
//  Copyright © 2020 Youliang Zhang. All rights reserved.
//

import UIKit


class HomeViewController: UITableViewController {
    
    var dataSource: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // JXPhotoBrowser配置日志
        JXPhotoBrowserLog.level = .low
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.jx.registerCell(HomeTableViewCell.self)
        
        // 授权网络数据访问
        guard let url = URL(string: "http://www.baidu.com") else  {
            return
        }
        JXPhotoBrowserLog.low("Request: \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { (data, resp, _) in
            if let response = resp as? HTTPURLResponse {
                JXPhotoBrowserLog.low("Response statusCode: \(response.statusCode)")
            }
        }.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = [
            LocalImageViewController(),
            AlbumViewController(),
            YYWebImageViewController()
        ]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.jx.dequeueReusableCell(HomeTableViewCell.self)
        let vc = dataSource[indexPath.row]
        if let _vc = vc as? BaseCollectionViewController {
            cell.textLabel?.text = _vc.name
            cell.detailTextLabel?.text = _vc.remark
        }else if let _vc = vc as? NormalVCProtocol{
            cell.textLabel?.text = _vc.name
            cell.detailTextLabel?.text = _vc.remark
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        navigationController?.pushViewController(dataSource[indexPath.row], animated: true)
    }
}

class HomeTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
