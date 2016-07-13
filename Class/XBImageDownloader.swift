//
//  XBImageDownloader.swift
//  XBCycleView
//
//  Created by xiabob on 16/6/13.
//  Copyright © 2016年 xiabob. All rights reserved.
//

import UIKit


public typealias finishClosure = (image: UIImage?) -> ()

public class XBImageDownloader: NSObject {
    lazy var imageCache: NSCache = {
        let cache: NSCache = NSCache()
        cache.countLimit = 10
        return cache
    }()
    
    override init() {
        super.init()
        commonInit()
    }
    
    private func commonInit() {
        let isCacheDirExist = NSFileManager.defaultManager().fileExistsAtPath(imageCacheDir())
        if !isCacheDirExist {
            do {
                try  NSFileManager.defaultManager().createDirectoryAtPath(imageCacheDir(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("XBImageDownloaderCache dir create error")
            }
        }
    }
    
    private func imageCacheDir() -> String {
        var dirString = ""
        if let dir = NSSearchPathForDirectoriesInDomains(.CachesDirectory,
                                                         .UserDomainMask,
                                                         true).last {
            dirString = dir.stringByAppendingString("/XBImageDownloaderCache")
        }
        
        return dirString
    }
    
    private func getImageFromLocal(url: String) -> UIImage? {
        let path = imageCacheDir() + "/" + url.xb_MD5
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    
    public func getImageWithUrl(urlString url: String, closure: finishClosure) {
        //first get image from memory
        if let image = imageCache.objectForKey(url) as? UIImage {
            closure(image: image)
            return
        }
        
        //second get image from local
        if let image = getImageFromLocal(url) {
            //save to memory
            imageCache.setObject(image, forKey: url)
            
            closure(image: image)
            return
        }
        
        //last get image from network
        let queue = dispatch_queue_create("com.xiabob.XBCycleView", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(queue) { [unowned self] in
            if let imageUrl = NSURL(string: url) {
                if let imageData = NSData(contentsOfURL: imageUrl) {
                    //save to disk
                    imageData.writeToFile(self.imageCacheDir() + "/" + url.xb_MD5, atomically: true)
                    
                    let image = UIImage(data: imageData)
                    
                    if image != nil {
                        //save to memory
                        self.imageCache.setObject(image!, forKey: url)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        closure(image: image)
                    })
                    
                    return
                }
            }
        }
    }
    
    public func clearCachedImages() {
        do {
            let paths = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(imageCacheDir())
            for path in paths {
                try NSFileManager.defaultManager().removeItemAtPath(imageCacheDir() + "/" + path)
            }
        } catch {
            print("XBImageDownloaderCache dir remove error")
        }
    }
}


