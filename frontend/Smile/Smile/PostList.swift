//
//  PostList.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import Foundation

protocol PostList {
    func getPosts(callback: @escaping ([Post]?)->Void)
}
