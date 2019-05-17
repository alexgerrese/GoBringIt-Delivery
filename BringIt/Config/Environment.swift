//
//  Environment.swift
//  BringIt
//
//  Created by Joshua Young on 5/16/19.
//  Copyright © 2019 Campus Enterprises. All rights reserved.

// based on https://thoughtbot.com/blog/let-s-setup-your-ios-environments

import Foundation

public enum Environment {
    // MARK: - Keys
    enum Keys {
        enum Plist {
            static let backendURL = "BACKEND_URL"
            static let apiKey = "API_KEY"
        }
    }
    
    // MARK: - Plist
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // MARK: - Plist values
    static let backendURL: URL = {
        guard let backendURLstring = Environment.infoDictionary[Keys.Plist.backendURL] as? String else {
            fatalError("Root URL not set in plist for this environment")
        }
        guard let url = URL(string: backendURLstring) else {
            fatalError("Root URL is invalid")
        }
        return url
    }()
    
    static let apiKey: String = {
        guard let apiKey = Environment.infoDictionary[Keys.Plist.apiKey] as? String else {
            fatalError("API Key not set in plist for this environment")
        }
        return apiKey
    }()
}
