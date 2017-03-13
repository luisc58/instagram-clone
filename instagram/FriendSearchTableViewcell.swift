
import UIKit
import Parse

protocol  FriendSearchTableViewCellDelegate: class {
    func cell(cell: FriendSearchTableViewcell, didSelectFollowUser user: PFUser)
    func cell(cell: FriendSearchTableViewcell, didSelectUnfollowUser user: PFUser)
}

class FriendSearchTableViewcell: UITableViewCell {
    
    @IBOutlet weak var addFriendIcon: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    weak var delegate: FriendSearchTableViewCellDelegate?
    
    
    var user: PFUser? {
        didSet {
            nameLabel.text = user?.username
        }
    }
    
    var canFollow: Bool? = true {
        didSet {
            /*
             Change the state of the follow button based on whether or not
             it is possible to follow a user.
             */
            
            if let canFollow = canFollow {
                addFriendIcon.isSelected = !canFollow
            }
        }
    }

    @IBAction func followbuttonTapped(_ sender: Any) {
        if let canFollow = canFollow, canFollow == true {
            delegate?.cell(cell: self, didSelectFollowUser: user!)
            self.canFollow = false
        } else {
            delegate?.cell(cell: self, didSelectFollowUser: user!)
            self.canFollow = true
        }
    }

}
