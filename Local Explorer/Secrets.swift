//
//  Secrets.swift
//  Local Explorer
//
//  Created by Tony Liu on 10/12/25.
//

import Foundation

struct Secrets {
    private static let sharedPlist: [String: Any]? = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return nil
        }
        return plist
    }()

    static var GooglePlacesKey: String {
        sharedPlist?["GooglePlacesKey"] as? String ?? ""
    }
}
