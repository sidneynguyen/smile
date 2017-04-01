//
//  Post.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import Foundation
import UIKit

let site : URL = URL(string: "http://172.20.10.7:3000/api/")!

class Post {
    let uuid : String
    let uid : String
    let date : Date
    let imageID : String
    let numFaces : Int
    
    private var image : UIImage?
    
    let urlSession = URLSession(configuration: .default)
    
    func getImage(callback: @escaping (UIImage?)->Void) {
        if let result = image {
            callback(result)
        } else {
            //make a request to get the image
            let request = URLRequest(url: URL(string: "/image&id=\(imageID)", relativeTo: site)!)
            
            urlSession.dataTask(with: request) {data, _, _ in
                if let data = data {
                    callback(UIImage(data: data))
                } else {
                    callback(nil)
                }
            }
        }
    }
    
    init(uuid: String, uid: String, date: Date, imageID: String, numFaces: Int) {
        self.uuid = uuid
        self.uid = uid
        self.date = date
        self.imageID = imageID
        self.numFaces = numFaces
    }
}
