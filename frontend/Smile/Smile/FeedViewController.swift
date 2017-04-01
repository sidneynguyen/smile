//
//  GlobalFeedViewController.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import UIKit

class FeedViewConroller : UITableViewController {
    
    var posts = [Post]()
    
    lazy var postList : PostList = self.generatePostList()
    
    func generatePostList() -> PostList {
        fatalError()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        postList.getPosts {posts in
            DispatchQueue.main.async {
                if let posts = posts {
                    self.posts = posts
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    let urlSession = URLSession(configuration: .default)
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = generateImageCell()
        
        posts[indexPath.row].getImage(urlSession: urlSession) {img in
            cell.value = img
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * (16/9)
    }
}
