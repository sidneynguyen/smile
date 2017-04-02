//
//  GlobalPostList.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import Foundation
import AFNetworking

extension Dictionary {
    func get<Result>(casters: [(keys: [Key], transformation: (Any?) -> Any?)], block: ([Key : Any]) -> Result) -> Result? {
        var result = [Key : Any]()
        for caster in casters {
            for key in caster.keys {
                guard let transformed = caster.transformation(self[key]) else {
                    print(key)
                    return nil
                }
                result[key] = transformed
            }
        }
        return block(result)
    }
}

let dateFormatter = { () -> DateFormatter in 
    let d = DateFormatter()
    d.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return d
}()

class GlobalPostList : PostList {
    
    private let urlSession = URLSession(configuration: .default)
    
    func getPosts(callback: @escaping ([Post]?) -> Void) {
        let request = URLRequest(url: URL(string: "/api/posts?scope=global", relativeTo: site)!)
        
        let task = urlSession.dataTask(with: request) {data, resp, error in
            
            if let error = error {
                print(error)
                callback(nil)
                return
            }
            
            guard let data = data else {
                callback(nil)
                return
            }
            
            do {
                let foundOb = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictArray = foundOb as? [[String: Any]] else {
                    callback(nil)
                    return
                }
                
                let posts = dictArray.flatMap{dict in
                    dict.get(casters: [
                        (["uuid", "uid"], {$0 as? String}),
                        (["date"], {
                            guard let string = $0 as? String else {return nil}
                            return dateFormatter.date(from: string)
                        }),
                        (["num_faces", "image_id"], {$0 as? Int})
                    ]) {dict in
                        return Post(uuid: dict["uuid"] as! String, uid: dict["uid"] as! String, date: dict["date"] as! Date, imageID: dict["image_id"] as! Int, numFaces: dict["num_faces"] as! Int)
                    }
                }
                callback(posts)
                return
            } catch {
                callback(nil)
                return
            }
            
        }
        
        task.resume()
    }
}
