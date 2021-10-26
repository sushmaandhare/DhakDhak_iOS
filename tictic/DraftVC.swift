//
//  DraftVC.swift
//  TIK TIK
//
//  Created by Apple on 09/10/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import UIKit
import AVKit

class DraftVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    var draftArr : [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.navigationController?.navigationBar.isHidden = false
        self.title = "Select Video"
        let placesData = UserDefaults.standard.object(forKey: "Draft") as? NSData

        if let placesData = placesData {
            draftArr = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as! [URL]
        }
        print(draftArr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    // Collectionview Deleagte methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return draftArr.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:DraftCell = self.collectionview.dequeueReusableCell(withReuseIdentifier: "DraftCell", for: indexPath) as! DraftCell
        let obj = draftArr[indexPath.item]
        cell.btnClose.tag = indexPath.item
        cell.btnClose.addTarget(self, action: #selector(DraftVC.onTapClose(_:)), for:.touchUpInside)
        
        if let thumbnailImage = getThumbnailImage(forUrl: obj) {
           
            cell.video_image.image = thumbnailImage
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = draftArr[indexPath.item]
        let player = AVPlayer(url: obj)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: PlayerVC = storyboard.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerVC
        vc.myPlayer = player
        vc.myVideoURL = obj
        vc.fromDraftVC = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let noOfCellsInRow = 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
        // return CGSize(width: collectionView.layer.frame.width / 3, height:  collectionView.layer.frame.width / 3)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    @objc func onTapClose(_ sender: UIButton) {
        draftArr.remove(at: sender.tag)
        let draftData = NSKeyedArchiver.archivedData(withRootObject: draftArr)
         UserDefaults.standard.set(draftData, forKey: "Draft")
        collectionview.reloadData()
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
