//
//  Post.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import Foundation
import UIKit

let site : URL = URL(string: "http://172.20.10.7:3000/")!

class Post {
    let uuid : String
    let uid : String
    let imageID : Int
    let numFaces : Int
    
    private var image : UIImage?
    
    func getImage(urlSession: URLSession, callback: @escaping (UIImage?)->Void) {
        if let result = image {
            callback(result)
        } else {
            //make a request to get the image
            let request = URLRequest(url: URL(string: "/api/image?image_id=\(imageID)", relativeTo: site)!)
            
            let task = urlSession.dataTask(with: request) {data, resp, err in
                DispatchQueue.main.async {
                    if let data = data {
                        self.image = UIImage(data: data)
                        callback(self.image)
                    } else {
                        callback(nil)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    init(uuid: String, uid: String, imageID: Int, numFaces: Int) {
        self.uuid = uuid
        self.uid = uid
        self.imageID = imageID
        self.numFaces = numFaces
    }
}
