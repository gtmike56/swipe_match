//
//  ImageCacheService.swift
//  SwipeAndMatch
//
//  Created by Mikhail Udotov on 2021-10-20.
//

import UIKit

typealias urlString = NSString

class ImageCacheService {
    static var shared = ImageCacheService()
    
    let cache = NSCache<urlString, UIImage>()
        
    func loadAppImage(imageURL: String, completion: @escaping (UIImage?) -> ()) {

        guard let url = URL(string: imageURL) else {
            print("URL is not correct (loadAppImage)")
            return
        }
        
        if let cachedImage = cache.object(forKey: imageURL as urlString) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let error = error {
                print("Error downloading the images (loadAppImage)", error)
                return
            }
            
            DispatchQueue.main.async { [self] in
                if let data = data {
                    if let downloadedImage = UIImage(data: data) {
                        cache.setObject(downloadedImage, forKey: imageURL as urlString)
                        completion(downloadedImage)
                    }
                } else {
                    print("No data (loadAppImage)")
                }
            }
        }).resume()
    }
}
