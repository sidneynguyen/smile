//
//  GlobalFeedViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

class GlobalFeedViewController : FeedViewConroller {
    override func generatePostList() -> PostList {
        return GlobalPostList()
    }
}
