//
//  Extentions.swift
//  TIK TIK
//
//  Created by Apple on 15/09/20.
//  Copyright © 2020 Rao Mudassar. All rights reserved.
//

import Foundation
import AVKit
import UIKit

extension AVMutableComposition {
    
    func mergeVideo(_ urls: [URL], completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil, nil)
            return
        }
        
        let outputURL = documentDirectory.appendingPathComponent("mergedVideo_\(Date()).mp4")
        UserDefaults.standard.set(outputURL, forKey: "mergedVideo")
        // If there is only one video, we dont to touch it to save export time.
        if let url = urls.first, urls.count == 1 {
            do {
                try FileManager().copyItem(at: url, to: outputURL)
                completion(outputURL, nil)
            } catch let error {
                completion(nil, error)
            }
            return
        }
        
        let maxRenderSize = CGSize(width: 1280.0, height: 720.0)
        var currentTime = CMTime.zero
        var renderSize = CGSize.zero
        // Create empty Layer Instructions, that we will be passing to Video Composition and finally to Exporter.
        var instructions = [AVMutableVideoCompositionInstruction]()

        urls.enumerated().forEach { index, url in
            let asset = AVAsset(url: url)
            let assetTrack = asset.tracks.first!
            
            // Create instruction for a video and append it to array.
            let instruction = AVMutableComposition.instruction(assetTrack, asset: asset, time: currentTime, duration: assetTrack.timeRange.duration, maxRenderSize: maxRenderSize)
            instructions.append(instruction.videoCompositionInstruction)
            
            // Set render size (orientation) according first video.
            if index == 0 {
                renderSize = instruction.isPortrait ? CGSize(width: maxRenderSize.height, height: maxRenderSize.width) : CGSize(width: maxRenderSize.width, height: maxRenderSize.height)
            }
            
            do {
                let timeRange = CMTimeRangeMake(start: .zero, duration: assetTrack.timeRange.duration)
                // Insert video to Mutable Composition at right time.
                try insertTimeRange(timeRange, of: asset, at: currentTime)
                currentTime = CMTimeAdd(currentTime, assetTrack.timeRange.duration)
            } catch let error {
                completion(nil, error)
            }
        }
        
        // Create Video Composition and pass Layer Instructions to it.
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = instructions
        // Do not forget to set frame duration and render size. It will crash if you dont.
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = renderSize
        
        guard let exporter = AVAssetExportSession(asset: self, presetName: AVAssetExportPreset1280x720) else {
            completion(nil, nil)
            return
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        // Pass Video Composition to the Exporter.
        exporter.videoComposition = videoComposition
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                completion(exporter.outputURL, nil)
            }
        }
    }
    
    static func instruction(_ assetTrack: AVAssetTrack, asset: AVAsset, time: CMTime, duration: CMTime, maxRenderSize: CGSize)
        -> (videoCompositionInstruction: AVMutableVideoCompositionInstruction, isPortrait: Bool) {
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)

            // Find out orientation from preffered transform.
            let assetInfo = orientationFromTransform(assetTrack.preferredTransform)
            
            // Calculate scale ratio according orientation.
            var scaleRatio = maxRenderSize.width / assetTrack.naturalSize.width
            if assetInfo.isPortrait {
                scaleRatio = maxRenderSize.height / assetTrack.naturalSize.height
            }
            
            // Set correct transform.
            var transform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
            transform = assetTrack.preferredTransform.concatenating(transform)
            layerInstruction.setTransform(transform, at: .zero)
            
            // Create Composition Instruction and pass Layer Instruction to it.
            let videoCompositionInstruction = AVMutableVideoCompositionInstruction()
            videoCompositionInstruction.timeRange = CMTimeRangeMake(start: time, duration: duration)
            videoCompositionInstruction.layerInstructions = [layerInstruction]
            
            return (videoCompositionInstruction, assetInfo.isPortrait)
    }
    
    static func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        
        switch [transform.a, transform.b, transform.c, transform.d] {
        case [0.0, 1.0, -1.0, 0.0]:
            assetOrientation = .right
            isPortrait = true
            
        case [0.0, -1.0, 1.0, 0.0]:
            assetOrientation = .left
            isPortrait = true
            
        case [1.0, 0.0, 0.0, 1.0]:
            assetOrientation = .up
            
        case [-1.0, 0.0, 0.0, -1.0]:
            assetOrientation = .down

        default:
            break
        }
    
        return (assetOrientation, isPortrait)
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: SET Text Feild max count
private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        if let t = textField.text {
            textField.text = String(t.prefix(maxLength))
        }
    }
}

extension String {

   

    //Validate Email
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }

    //validate PhoneNumber
    var isPhoneNumber: Bool {

        let charcter  = NSCharacterSet(charactersIn: "+0123456789").inverted
        var filtered:NSString!
        let inputString:NSArray = self.components(separatedBy: charcter) as NSArray
        filtered = inputString.componentsJoined(by: "") as NSString
        return  self == filtered as String

    }
}
