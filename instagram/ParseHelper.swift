

import Foundation
import Parse 


class ParseHelper {

    static func mainPagerequestForCurrentUser(completionBlock: @escaping ([PFObject]?, Error?) -> Void) {
    
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
        query.order(byAscending: "createAt")
        
        query.findObjectsInBackground(block: completionBlock)
        
       
    }
    
}
