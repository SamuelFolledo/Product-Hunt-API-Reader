//
//  Post.swift
//  ProductHunt
//
//  Created by Macbook Pro 15 on 4/18/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

// Have a matching decodable array in our struct for the array of posts we get back from the API
struct PostList: Decodable {
    var posts: [Post]
}

/// A product retrieved from the Product Hunt API.
struct Post {
    // Various properties of a post that we either need or want to display
    let id: Int
    let name: String
    let tagline: String
    let votesCount: Int
    let commentsCount: Int
    let previewImageURL: URL
    
    func fetchImage(completion: @escaping (_ image: UIImage?, _ error: String?) -> Void) {
        let request = URLRequest(url: previewImageURL)
        let defaultSession = URLSession(configuration: .default)
        let dataTask = defaultSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                completion(nil, error?.localizedDescription)
                return
            }
            guard let data = data else {
                completion(nil, "No data")
                return
            }
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image, nil)
                }
            } else {
                print("No Data fetched")
            }
        })
        dataTask.resume()
    }
}


// MARK: Decodable
extension Post: Decodable {
    // properties within a Post returned from the Product Hunt API that we want to extract the info from.
    
    init(from decoder: Decoder) throws {
        // Decode the Post from the API call
        let postsContainer = try decoder.container(keyedBy: PostKeys.self)
        // Decode each of the properties from the API into the appropriate type (string, etc.) for their associated struct variable
        id = try postsContainer.decode(Int.self, forKey: .id)
        name = try postsContainer.decode(String.self, forKey: .name)
        tagline = try postsContainer.decode(String.self, forKey: .tagline)
        votesCount = try postsContainer.decode(Int.self, forKey: .votesCount)
        commentsCount = try postsContainer.decode(Int.self, forKey: .commentsCount)
        // First we need to get a container (screenshot_url/previewImageURL) nested within our postsContainer.
        // If it only had a single value like the other properties, we wouldn't need to use nestedContainer
        let screenshotURLContainer = try postsContainer.nestedContainer(keyedBy: PreviewImageURLKeys.self, forKey: .previewImageURL) //new
        // Decode the image and assign it to the variable
        previewImageURL = try screenshotURLContainer.decode(URL.self, forKey: .imageURL) //new
    }
    
    enum PostKeys: String, CodingKey {
        // first three match our variable names for our Post struct
        case id
        case name
        case tagline
        // these three need to be mapped since they're named differently on the API compared to our struct
        case votesCount = "votes_count"
        case commentsCount = "comments_count"
        case previewImageURL = "screenshot_url"
    }
    
    enum PreviewImageURLKeys: String, CodingKey {
        // for all posts, we only want the 850px image
        // Check out the screenshot_url property in our Postman call to see where this livesx
        case imageURL = "850px"
    }
}
