

import UIKit
import Parse

class MainPageViewController: UIViewController {
    var phototakingHelper : PhotoTakingHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self //When user opens app this page is displayed
    }
    
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        phototakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
                let post = POST()
                post.image = image
                post.uploadPost()
            }
     }
}

/* Tab bar view controller only allows a user to switch between controllers, instead we want to show an
    action when the camera button is tapped 
 */

// MARK: Tab Bar Delegate

extension MainPageViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if (viewController is PhotoViewController) { 
           takePhoto()
           return false 
        } else {
            return true             // If true, tab bar will present view controller
                                    // If false, prints "Take photo" --> or any action
        }
    }
}
