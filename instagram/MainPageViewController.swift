

import UIKit
import Parse

class MainPageViewController: UIViewController {
    var phototakingHelper : PhotoTakingHelper?
    var posts: [POST] = []
    @IBOutlet weak var tableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self //When user opens app this page is displayed
    }
    
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //  Following Query
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo: PFUser.current()!)
        
        //  query that fetches posts created by users that current user follows
        let postsFromFollowedUsers = POST.query()
        postsFromFollowedUsers?.whereKey("user", matchesKey: "toUser", in: followingQuery)  
        //  query that retrieves posts current user has posted
        let postsFromThisUser = POST.query()
        postsFromThisUser?.whereKey("user", equalTo: PFUser.current()!)
        // Combine two queries
        let query = PFQuery.orQuery(withSubqueries: [postsFromFollowedUsers!, postsFromThisUser!])
        
        query.includeKey("user")
        query.order(byDescending: "createAt")
    
      // MARK: Network request
    query.findObjectsInBackground { ( result: [PFObject]?, error) in
            self.posts = result as? [POST] ?? []
            self.tableView.reloadData()
        
        }
        
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

// Allows us to see if request is working prperly

extension MainPageViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 2
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel!.text = "Post"
        
        return cell
    }

}


