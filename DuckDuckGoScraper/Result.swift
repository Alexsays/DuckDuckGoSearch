//
//  Result.swift
//  DuckDuckGoScraper
//
//  Created by Alejandro Silva Fernandez on 05/09/2017.
//  Copyright © 2017 Alex Silva. All rights reserved.
//

import Foundation

class Result {
    // MARK: - Properties
    var url: URL?
    var description: String?
    var icon: URL?

    // MARK: - Initialization
    init(url: URL?, description: String?, icon: URL?) {
        self.url = url
        self.description = description
        self.icon = icon
    }
}
