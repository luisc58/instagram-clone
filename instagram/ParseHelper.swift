

import Foundation
import Parse 


class ParseHelper {

    static func mainPagerequestForCurrentUser( completionBlock: @escaping ([PFObject]?, Error?) -> Void) {
    
        //  Following Query
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo: PFUser.current()!)
        
        //  query that fetches posts created by users that current user follows
        let postsFromFollowedUsers = POST.query()
        postsFromFollowedUsers?.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, in: followingQuery)  
        //  query that retrieves posts current user has posted
        let postsFromThisUser = POST.query()
        postsFromThisUser?.whereKey(ParsePostUser, equalTo: PFUser.current()!)
        // Combine two queries
        let query = PFQuery.orQuery(withSubqueries: [postsFromFollowedUsers!, postsFromThisUser!])
        
        query.includeKey(ParsePostUser)
        query.order(byAscending: ParsePostCreatedAt)
        
        
        query.findObjectsInBackground(block: completionBlock)
        
       
    }
    
    //  MARK: Likes 
    
    static func likePost(user: PFUser, post: POST) {
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackground(block: nil)
    
    }
    
    static func unlikePost(user: PFUser, post: POST) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackground { (results, error) -> Void in
            if let results = results as [PFObject]? {
                for likes in results {
                    likes.deleteInBackground(block: nil)
                }
            }
        }
    }
    
    static func likesForPost(post: POST, completionBlock: @escaping ([PFObject]?, Error?) -> Void) {
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        query.includeKey(ParseLikeFromUser)
        
        query.findObjectsInBackground(block: completionBlock)
    }
    
    //  MARK: Following 
    static func getFollowingUsersForUser(user: PFUser, completionBlock: @escaping ([PFObject]?, Error?) -> Void) {
        let query = PFQuery(className: ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.findObjectsInBackground(block: completionBlock)
    }
    
    /**
     Establishes a follow relationship between two users.
     
     :param: user    The user that is following
     :param: toUser  The user that is being followed
     */
    
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser) {
        let followObject = PFObject(className: ParseFollowClass)
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        
        followObject.saveInBackground(block: nil)
    }
    
    /**
     Deletes a follow relationship between two users.
     
     :param: user    The user that is following
     :param: toUser  The user that is being followed
     */
    
    static func removeFollowRelationshipFromuser(user: PFUser, toUser: PFUser) {
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackground { (results: [PFObject]?, error) in
            let results = results ?? []
            
            for follow in results {
                follow.deleteInBackground(block: nil)
            }
        }
    }
    
    // MARK: Users
    /**
     Fetch all users, except the one that's currently signed in.
     Limits the amount of users returned to 20.
     
     :param: completionBlock The completion block that is called when the query completes
     
     :returns: The generated PFQuery
     */
    
    static func allUsers(completionBlock: @escaping ([PFObject]?, Error?) -> Void) -> PFQuery<PFObject>  {
        let query = PFUser.query()!
        // exclude the current user
        query.whereKey(ParseUserUsername,
                       notEqualTo: PFUser.current()!.username!)
        query.order(byAscending: ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackground(block: completionBlock)
        
        return query
        
        
    }
    
    /**
     Fetch users whose usernames match the provided search term.
     
     :param: searchText The text that should be used to search for users
     :param: completionBlock The completion block that is called when the query completes
     
     :returns: The generated PFQuery
     */
    static func searchUsers(searchText: String, completionBlock: @escaping ([PFObject]?, Error?) -> Void) -> PFQuery<PFObject> {
        /*
         NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
         Regex can be slow on large datasets. For large amount of data it's better to store
         lowercased username in a separate column and perform a regular string compare.
         */
        let query = PFUser.query()!.whereKey(ParseUserUsername,
                                             matchesRegex: searchText, modifiers: "i")
        
        query.whereKey(ParseUserUsername,
                       notEqualTo: PFUser.current()!.username!)
        
        query.order(byAscending: ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackground(block: completionBlock)
        
        return query
    }
}


extension PFObject {
    
    open override func isEqual(_ object: Any?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }

    }
    
}
