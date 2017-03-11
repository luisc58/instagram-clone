
//  Presents popover to allow the user to choose between taking a new photo or selecting one
//  Presents either camera or photo library 
//  Returns the image that the user has taken or selected 

import UIKit

typealias PhototakingHelperCallback = (UIImage?) -> Void //Function of type... has parameter UIImage and returns Void 

class PhotoTakingHelper: NSObject {
    
    //  View Controller on which AlertViewController and UIImagePickerController are presented 
weak var viewController : UIViewController!
    var callback : PhototakingHelperCallback
    var imagePickerController : UIImagePickerController?
    
    init(viewController: UIViewController, callback: @escaping PhototakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        showPhotoSourceSelection()
    }
    
    func showPhotoSourceSelection() {
        //  Allow user to chose between camera and photo library 
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)  
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo from library", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        
        alertController.addAction(photoLibraryAction)
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
               self.showImagePickerController(sourceType: .camera)
            }
            
            alertController.addAction(cameraAction)
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController?.sourceType = sourceType
        imagePickerController!.delegate = self
        self.viewController.present(imagePickerController!, animated: true, completion: nil)
    }
}

//  MARK: Extention for imagpicker delagate

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : Any]) {
        viewController.dismiss(animated: false, completion: nil)
        callback(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}








