//
//  UITextViewHashtagExtension.swift
//  TIK TIK
//
//  Created by Mac on 19/02/21.
//  Copyright © 2021 Rao Mudassar. All rights reserved.
//
import Foundation
import UIKit

extension UITextView {

    func resolveHashTags() {

        // turn string in to NSString
        let nsText = NSString(string: self.text)

        // this needs to be an array of NSString.  String does not work.
        let words = nsText.components(separatedBy: CharacterSet(charactersIn: "#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_").inverted)

        // you can staple URLs onto attributed strings
        let attrString = NSMutableAttributedString()
        
        attrString.setAttributedString(self.attributedText)

        // tag each word if it has a hashtag
        for word in words {
            if word.count < 3 {
                continue
            }

            // found a word that is prepended by a hashtag!
            // homework for you: implement @mentions here too.
            if word.hasPrefix("#") {

                // a range is the character position, followed by how many characters are in the word.
                // we need this because we staple the "href" to this range.
                let matchRange:NSRange = nsText.range(of: word as String)
                
                // drop the hashtag
                let stringifiedWord = word.dropFirst()
            
                if let firstChar = stringifiedWord.unicodeScalars.first, NSCharacterSet.decimalDigits.contains(firstChar) {
                    // hashtag contains a number, like "#1"
                    // so don't make it clickable
                } else {
                    // set a link for when the user clicks on this word.
                    // it's not enough to use the word "hash", but you need the url scheme syntax "hash://"
                    // note:  since it's a URL now, the color is set to the project's tint color
                 //   let attributedString = NSMutableAttributedString(string: longString!, attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-Regular", size: 12.0)!])
                 //   attrString.addAttribute(NSAttributedString.Key.font, value: [NSAttributedString.Key.font : UIFont(name: "Poppins-Semibold", size: 12.0)!], range: matchRange)
                    attrString.addAttribute(NSAttributedString.Key.link, value: "hash:\(stringifiedWord)", range: matchRange)
                }

            }else{
                
            }
        }

        // we're used to textView.text
        // but here we use textView.attributedText
        // again, this will also wipe out any fonts and colors from the storyboard,
        // so remember to re-add them in the attrs dictionary above
        self.attributedText = attrString
    }
}
