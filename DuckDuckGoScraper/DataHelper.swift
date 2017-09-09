//
//  DataHelper.swift
//  DuckDuckGoScraper
//
//  Created by Alejandro Silva Fernandez on 09/09/2017.
//  Copyright © 2017 Alex Silva. All rights reserved.
//

import Foundation

final class DataHelper: NSObject {
    static let sharedInstance = DataHelper()

    private override init() { }

    // MARK: - Recent searches
    
    var recentSearches: [String]? {
        get { return getValue(forKey: .recentSearches) as? [String] }
        set { setValue(newValue, forKey: .recentSearches) }
    }

    // MARK: - Auxiliar

    private enum DataKey: String {
        case recentSearches
    }

    private func getValue(forKey key: DataKey) -> Any? {
        return UserDefaults.standard.value(forKey: key.rawValue)
    }

    private func setValue(_ value: Any?, forKey key: DataKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}
