
import UIKit
import Bond
import Parse
import ReactiveKit

class TableViewCell: UITableViewCell {
   
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var morebutton: UIButton!
    var postDisposable: Disposable?
    var likeDisposable: Disposable?
    
    var post : POST? {
        didSet {
            
            postDisposable?.dispose()
            likeDisposable?.dispose()
            if let post = post {
                postDisposable = post.image.bind(to: postImageView.reactive.image)
                likeDisposable = post.likes.observeNext(with: { (value: [PFUser]?) in
                    if let value = value {
                        self.likesLabel.text = self.stringFromUserlist(userList: value)
                        self.likeButton.isSelected = value.contains(PFUser.current()!)
                        self.likesIconImageView.isHidden = (value.count == 0)
                    } else {
                        self.likesLabel.text = ""
                        self.likeButton.isSelected = false
                        self.likesIconImageView.isHidden = true
                    
                    }
                })
                post.image.bind(to: postImageView.reactive.image)
            } 
        }
    
    }
    
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        post?.toggleLikePost(user: PFUser.current()!)
    }
    
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func stringFromUserlist(userList: [PFUser]) -> String {
        let usernameList = userList.map { user in user.username! }
        let commaSeperatedUserList = usernameList.joined(separator: ", ")
        
        return commaSeperatedUserList
    }
}
