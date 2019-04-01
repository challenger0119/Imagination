//
//  MemerySpaceTableViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/28.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
let memoryReusableIdentifier = "memoryReusableIdentifier"

class MemorySpaceController: UITableViewController {

    enum SectionType:String {
        case Video = "视频", Audio = "录音", Image = "照片", Deletable = "可酌情删除的数据"
    }
    
    struct FileInfo {
        var name:String
        var size:Int
        var suffix:String
    }
    
    var cellcontent:[(data:[FileInfo],type:SectionType)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func loadData(){

        do {
            var videoInfos:[FileInfo] = []
            var audioInfos:[FileInfo] = []
            var imageInfos:[FileInfo] = []
            
            var files:[String] = []
            let videos = try FileManager.default.contentsOfDirectory(atPath: FileManager.videoFilePath())
            files.append(contentsOf: videos)
            let audios = try FileManager.default.contentsOfDirectory(atPath: FileManager.audioFilePath())
            files.append(contentsOf: audios)
            let images = try FileManager.default.contentsOfDirectory(atPath: FileManager.imageFilePath())
            files.append(contentsOf: images)
            for file in files {
                let nameArray = file.components(separatedBy: ".")
                if nameArray.count >= 2 {
                    switch nameArray[1] {
                    case FileManager.imageFormat:
                        let attr = try FileManager.default.attributesOfItem(atPath: FileManager.imageFilePathWithName(name: file))
                        let size = attr[.size] as! Int
                        imageInfos.append(FileInfo(name: nameArray[0], size:size,suffix:nameArray[1]))
                    case FileManager.audioFormat:
                        let attr = try FileManager.default.attributesOfItem(atPath: FileManager.audioFilePathWithName(name: file))
                        let size = attr[.size] as! Int
                        audioInfos.append(FileInfo(name: nameArray[0], size: size,suffix:nameArray[1]))
                    case FileManager.videoFormat:
                        let attr = try FileManager.default.attributesOfItem(atPath: FileManager.videoFilePathWithName(name: file))
                        let size = attr[.size] as! Int
                        videoInfos.append(FileInfo(name: nameArray[0], size: size,suffix:nameArray[1]))
                        
                    default:
                        break
                    }
                }
            }
            if videoInfos.count > 0 {
                cellcontent.append((videoInfos, .Video))
            }
            if audioInfos.count > 0 {
                cellcontent.append((audioInfos, .Audio))
            }
            if imageInfos.count > 0 {
                cellcontent.append((imageInfos, .Image))
            }
        }catch{
            
            Dlog(error.localizedDescription)
            return
        }

        var otherInfos:[FileInfo] = []
        var tsize:Int = 0
        do{
            let backupfile = try FileManager.default.contentsOfDirectory(atPath: FileManager.backupFilePath())
            for file in backupfile {
                let nameArray = file.components(separatedBy: ".")
                if nameArray.count == 2 {
                    let atr = try FileManager.default.attributesOfItem(atPath: FileManager.backupFilePath(withName: file))
                    let size = atr[FileAttributeKey("NSFileSize")] as! Int
                    tsize += size
                }
            }
            otherInfos.append(FileInfo(name: "备份文件", size: tsize,suffix:""))
            
            let exportfile = try FileManager.default.contentsOfDirectory(atPath: FileManager.exportFilePath())
            tsize = 0
            for file in exportfile {
                let nameArray = file.components(separatedBy: ".")
                if nameArray.count == 2 {
                    let atr = try FileManager.default.attributesOfItem(atPath: FileManager.exportFilePath(withName: file))
                    let size = atr[FileAttributeKey("NSFileSize")] as! Int
                    tsize += size
                }
            }
            otherInfos.append(FileInfo(name: "导出文件", size: tsize,suffix:""))
            
            cellcontent.append((otherInfos, .Deletable))
        }catch{
            Dlog(error.localizedDescription)
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellcontent.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellcontent[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = MemorySpaceHeaderView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 40))
        view.leftLabel.text = cellcontent[section].type.rawValue
        var fsize:Int = 0
        for finfo in cellcontent[section].data{
            fsize += finfo.size / 1024
        }
        if fsize / 1024 > 0 {
            view.rightLabel.text = String.init(format: "%.1f", Float(fsize) / 1024)+"MB"
        }else{
            view.rightLabel.text = "\(fsize)KB"
        }
        return view
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: memoryReusableIdentifier, for: indexPath)

        cell.textLabel?.text = cellcontent[indexPath.section].data[indexPath.row].name
        let fsize = cellcontent[indexPath.section].data[indexPath.row].size / 1024
        if fsize / 1024 > 0 {
            cell.detailTextLabel?.text = String.init(format: "%.1f", Float(fsize) / 1024)+"MB"
        }else{
            cell.detailTextLabel?.text = String(fsize)+"KB"
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let type = cellcontent[indexPath.section].type
        let file = cellcontent[indexPath.section].data[indexPath.row]
        switch type {
        case .Video:
            let playView = AVPlayerViewController()
            let playitem = AVPlayerItem(asset: AVAsset(url: URL.init(fileURLWithPath: FileManager.videoFilePathWithName(name: file.name+"."+file.suffix))))
            let player = AVPlayer(playerItem: playitem)
            playView.player = player
            self.present(playView, animated: true, completion: {
            })
        case .Audio:
            let vc = AudioViewController(withFile: file.name+"."+file.suffix)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            self.present(nav, animated: true, completion: {
                
            })
        case .Image:
            let vc = ImageViewController(withImage: UIImage.init(contentsOfFile: FileManager.imageFilePathWithName(name: file.name+"."+file.suffix))!)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            self.present(nav, animated: true, completion: {
                
            })
        case .Deletable:
            let alert = UIAlertController(title: "提示", message: file.name+"是备份或导出过程的缓存，只保存最近一次，左滑可以删除", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - UITableViewDelegate
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return cellcontent[indexPath.section].type == .Deletable
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row == 0{
                do{
                    let backupfile = try FileManager.default.contentsOfDirectory(atPath: FileManager.backupFilePath())
                    for file in backupfile {
                        if  !FileManager.deleteFile(atPath: FileManager.backupFilePath(withName: file)) {
                            Dlog("delete fail \(file)")
                        }
                    }
                    cellcontent[indexPath.section].data[indexPath.row].size = 0
                }catch{
                    Dlog(error.localizedDescription)
                }

            }else if indexPath.row == 1{
                do{
                    let backupfile = try FileManager.default.contentsOfDirectory(atPath: FileManager.exportFilePath())
                    for file in backupfile {
                        if !FileManager.deleteFile(atPath: FileManager.exportFilePath(withName: file)) {
                            Dlog("delete fail \(file)")
                        }
                    }
                    cellcontent[indexPath.section].data[indexPath.row].size = 0
                }catch{
                    Dlog(error.localizedDescription)
                }
            }
            tableView.reloadData()
        }
        
    }
}
