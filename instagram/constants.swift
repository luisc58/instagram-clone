//
//  constants.swift
//  instagram
//
//  Created by luis castillo on 3/8/17.
//  Copyright © 2017 luis castill0. All rights reserved.
//

import Foundation

let APP_ID = "ventigram"
let SERVER_URL = "https://ventigram.herokuapp.com/parse"

// Following Relation
let ParseFollowClass       = "Follow"
let ParseFollowFromUser    = "fromUser"
let ParseFollowToUser      = "toUser"

// Like Relation
let ParseLikeClass         = "Like"
let ParseLikeToPost        = "toPost"
let ParseLikeFromUser      = "fromUser"

// Post Relation
let ParsePostUser          = "user"
let ParsePostCreatedAt     = "createdAt"

// Flagged Content Relation
let ParseFlaggedContentClass    = "FlaggedContent"
let ParseFlaggedContentFromUser = "fromUser"
let ParseFlaggedContentToPost   = "toPost"

// User Relation
let ParseUserUsername      = "username"
