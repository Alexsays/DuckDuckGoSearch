//
//  WSClient.swift
//  DuckDuckGoScraper
//
//  Created by Alejandro Silva Fernandez on 06/09/2017.
//  Copyright © 2017 Alex Silva. All rights reserved.
//

import Foundation
import SwiftyJSON

class WSClient: NSObject {
    static let sharedInstance = WSClient()

    private override init() { }

    func searchByTerm(_ term: String, completion: @escaping (_ results: [Result]?, _ error: Error?) -> Void) {
        let url = URL(string: "https://duckduckgo.com/?q=\(term)&format=json")

        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)

        URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil || data == nil {
                completion(nil, error)
            } else {
                let jsonResponse = JSON(data!)

                var results = [Result]()
                if let jsonResults = jsonResponse["RelatedTopics"].array {
                    var i = 1
                    for result in jsonResults {
                        if let topics = result["Topics"].array {
                            for topic in topics {
                                results.append(Result(url: topic["FirstURL"].url ?? nil, description: topic["Text"].string ?? nil, icon: topic["Icon"]["URL"].url ?? nil))
                                i += 1
                            }
                        } else {
                            results.append(Result(url: result["FirstURL"].url ?? nil, description: result["Text"].string ?? nil, icon: result["Icon"]["URL"].url ?? nil))
                            i += 1
                        }
                    }
                }
                
                completion(results, nil)
            }
        }.resume()
    }
}
