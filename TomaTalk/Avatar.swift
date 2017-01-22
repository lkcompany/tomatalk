//
//  File.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 7/9/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import Foundation

func uploadAvatar(_ image: UIImage, result: @escaping (_ imageLink: String?) -> Void) {
    
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    let dateString = dateFormatter().string(from: Date())
    let fileName = "Img/" + dateString + ".jpeg"
    
    backendless?.fileService.upload(fileName, content: imageData, response: { (file) -> Void in
     
        result(file!.fileURL)
        
    }) { (fault: Fault?) -> Void in
        print("error uploading avatar image: \(fault)")
    }
}

func getImageFromURL(_ url: String, result: @escaping (_ image: UIImage?) -> Void) {
    if(url.isEmpty){
        return
    }
    
    let URL = Foundation.URL(string: url)
    
    let downloadQueue = DispatchQueue(label: "imageDownloadQueue", attributes: [])
    
    downloadQueue.async { () -> Void in
        
        let data = try? Data(contentsOf: URL!)
        let image: UIImage!
        
        if data != nil {
            image = UIImage(data: data!)
            DispatchQueue.main.async(execute: { 
                result(image)
            })
        }
    }
}
