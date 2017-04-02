//
//  UserFeedViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

class UserFeedViewController: FeedViewConroller {
    
    override func generatePostList() -> PostList {
        return UserPostList()
    }
    
}
