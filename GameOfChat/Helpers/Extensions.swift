//
//  Extensions.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 04/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func setProfileImageDownloaded(urlString: NSString) {
        
        self.image = nil
        
        if let imageCached = imageCache.object(forKey: urlString) {
            self.image = imageCached
            return
        }
        
        
        guard let url = URL(string: urlString as String) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else { return }
            DispatchQueue.main.async {
                guard let downloadedImage = UIImage(data: data) else { return }
                imageCache.setObject(downloadedImage, forKey: urlString)
                self.image = downloadedImage
                
            }
        }
        task.resume()
        
    }
}
