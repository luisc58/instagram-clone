//
//  POST.swift
//  instagram
//
//  Created by luis castillo on 3/9/17.
//  Copyright © 2017 luis castill0. All rights reserved.
//

import Foundation
import Parse

class POST: PFObject, PFSubclassing {
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var photoUploadTask : UIBackgroundTaskIdentifier?
    
    var image : UIImage?
    
    //  MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Post"
    }
    
    func uploadPost() {
        if let image = image {
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            user = PFUser.current()
            self.imageFile = imageFile
            
            //  MARK: Requesting a long running background task ---> request some extra time to finish up tasks that started before the app got suspended
            
            photoUploadTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { 
              UIApplication.shared.endBackgroundTask(self.photoUploadTask!)
            })
            
            saveInBackground(block: { (Bool, error) in
                UIApplication.shared.endBackgroundTask(self.photoUploadTask!)
            })
        }
    }
    
    override init() {
        super.init()
        
    }
   // Does not perform synchronous code  
   override class func initialize() {
        DispatchQueue.global().async(execute: {
            DispatchQueue.main.sync{
                print("main thread")
                 self.registerSubclass()
            }
        })
    }
}
