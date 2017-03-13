

import UIKit
import Parse

class FriendSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var users: [PFUser]?
    
    /*
     This is a local cache. It stores all the users this user is following.
     It is used to update the UI immediately upon user interaction, instead of
     having to wait for a server response.
     */
    var followingUsers: [PFUser]? {
        didSet {
            /**
             the list of following users may be fetched after the tableView has displayed
             cells. In this case, we reload the data to reflect "following" status
             */
            tableView.reloadData()
        }
    }
    
    // the current parse query
    var query: PFQuery<PFObject>? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            // you can use oldValue to access the previous value of the property
            oldValue?.cancel()
        }
    }
    
    // thhis view can be in two different states 
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    // whenever the state changes, perform one of the two queries and update the list
    var state: State = .DefaultMode {
        didSet {
            switch(state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(completionBlock: updateList )
                
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText: searchText, completionBlock: updateList )
            }
        }
    }
    
    // MARK: Update userlist
    
    /**
     Is called as the completion block of all queries.
     As soon as a query completes, this method updates the Table View.
     */
    func updateList(results: [PFObject]?, error: Error?) {
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .DefaultMode
        
        // fill the cache of s user's followers
        ParseHelper.getFollowingUsersForUser(user: PFUser.current()!) { (results, error) in
            let relations = results ?? []
            // use map to extract the user from a Follow object
            self.followingUsers = relations.map {
                $0.object(forKey: ParseFollowToUser) as! PFUser
            }
        }
    }
}


extension FriendSearchViewController: UITableViewDataSource { 

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! FriendSearchTableViewcell
        
        let user = users![indexPath.row]
        cell.user = user
        
        if let followingUsers = followingUsers {
            // check if current user is already following displayed user
            // change button appereance based on result
            cell.canFollow = !followingUsers.contains(user)
        }
        
        cell.delegate = self
        
        return cell
    }

}

// MARK: Searchbar Delegate

extension FriendSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchUsers(searchText: searchText, completionBlock:updateList )
        
    }
    
}

// MARK: FriendSearchTableViewCell Delegate

extension FriendSearchViewController: FriendSearchTableViewCellDelegate {
    
    func cell(cell: FriendSearchTableViewcell, didSelectFollowUser user: PFUser) {
        ParseHelper.addFollowRelationshipFromUser(user: PFUser.current()!, toUser: user)
    }
    
    
    
    func cell(cell: FriendSearchTableViewcell, didSelectUnfollowUser user: PFUser) {
        ParseHelper.removeFollowRelationshipFromuser(user: PFUser.current()!, toUser: user)
        // update local cache
        self.followingUsers = followingUsers?.filter({$0 != user})
    }
    
}
