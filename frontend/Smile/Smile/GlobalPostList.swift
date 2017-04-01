//
//  GlobalPostList.swift
//  Smile
//
//  Created by Luke Brody on 4/1/17.
//  Copyright © 2017 Luke Brody. All rights reserved.
//

import Foundation

extension Dictionary {
    func get<Result>(casters: [(keys: [Key], transformation: (Any?) -> Any?)], block: ([Key : Any]) -> Result) -> Result? {
        var result = [Key : Any]()
        for caster in casters {
            for key in caster.keys {
                guard let transformed = caster.transformation(self[key]) else {
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
    d.dateStyle = .medium
    d.timeStyle = .long
    return d
}()

class GlobalPostList : PostList {
    
    private let urlSession = URLSession(configuration: .default)
    
    func getPosts(callback: @escaping ([Post]?) -> Void) {
        let request = URLRequest(url: URL(string: "/posts?scope=global", relativeTo: site)!)
        
        urlSession.dataTask(with: request) {data, _, _ in
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
                        (["uuid", "uid", "imageID"], {$0 as? String}),
                        (["date"], {
                            guard let string = $0 as? String else {return nil}
                            return dateFormatter.date(from: string)
                        }),
                        (["numFaces"], {$0 as? Int})
                    ]) {dict in
                        return Post(uuid: dict["uuid"] as! String, uid: dict["uid"] as! String, date: dict["date"] as! Date, imageID: dict["imageID"] as! String, numFaces: dict["numFaces"] as! Int)
                    }
                }
                callback(posts)
                return
            } catch {
                callback(nil)
                return
            }
            
        }
    }
}
