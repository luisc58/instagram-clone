
import UIKit

class PostHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var posTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
   
    var post: POST? {
        didSet {
            if let post = post {
                nameLabel.text = post.user?.username
            }
        }
    }
    
    
}
