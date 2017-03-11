
import UIKit
import Bond

class TableViewCell: UITableViewCell {
   
    @IBOutlet weak var postImageView: UIImageView!
    
    var post : POST? {
        didSet {
            if let post = post {
                
                post.image.bind(to: postImageView.reactive.image)
            } 
        }
    
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
