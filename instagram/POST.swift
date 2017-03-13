//
//  POST.swift
//  instagram
//
//  Created by luis castillo on 3/9/17.
//  Copyright © 2017 luis castill0. All rights reserved.
//

import Foundation
import Parse
import Bond

class POST: PFObject, PFSubclassing {
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var photoUploadTask : UIBackgroundTaskIdentifier?
    
    var image: Observable<UIImage?> = Observable(nil)  // asynchronously image
    var likes: Observable<[PFUser]?> = Observable(nil)  //Observable optional Array
    
    //  MARK: PFSubclassing Protocol
    
    static func parseClassName() -> String {
        return "Post"
    }
    
    func uploadPost() {
        if let image = image.value {
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
    
    func downloadImage() {
        //  If image is not downloaded yet, get it 
        if (image.value == nil) {
            imageFile?.getDataInBackground(block: { (data, error) in //getting data in the background
                if let data = data {
                    let image = UIImage(data: data, scale: 1.0)
                    self.image.value = image
                }
            })
        }
        
    }
    
    func fetchlikes() {
        if (likes.value != nil) {
            return
        }
        
        ParseHelper.likesForPost(post: self) { (likes, error) in
            
            let validLikes = likes?.filter { like in like[ParseLikeFromUser] != nil }
            
            self.likes.value = validLikes?.map { like in 
                let fromUser = like[ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        }
    }
    
    func doesUserLikePost(user: PFUser) -> Bool {
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if(doesUserLikePost(user: user)) {
            // if post is liked, unlike it
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user: user, post: self)
            
        } else {
        
            // If post is not liked yet
            likes.value?.append(user)
            ParseHelper.likePost(user: user, post: self)
        }
    }       /* If the user doesn't like the post yet, we add them to the local cache and then sync the change with Parse */
    
    
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
