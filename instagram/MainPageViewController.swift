

import UIKit
import Parse 
import Bond
import ConvenienceKit

class MainPageViewController: UIViewController {
    var phototakingHelper : PhotoTakingHelper?
    //var timelineComponent: TimelineComponent<POST, MainPageViewController>!
    var posts: [POST] = []
    
    let defaultRange = 0..<5
    let additionalRangeSize = 5
    var timelineComponent: MainPageViewController!
    
    @IBOutlet weak var tableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self //When user opens app this page is displayed
    }
    
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
     // MARK: Network request
    ParseHelper.mainPagerequestForCurrentUser { (result : [PFObject]?, error) in
        self.posts = result as? [POST] ?? []
        self.tableView.reloadData()
    }
}
    
        
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        phototakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
                let post = POST()
                post.image.value = image
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

// Allows us to see if request is working prperly

extension MainPageViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count   
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 2
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        let post = posts[indexPath.row]
        
        post.downloadImage()
        
        cell.post = post
        
        post.fetchlikes()
        
        return cell
    }
    
    private func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "PostHeader") as! PostHeaderTableViewCell
        
        let post = posts[section]
        headerCell.post = post
        
        return headerCell
    }
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

}




