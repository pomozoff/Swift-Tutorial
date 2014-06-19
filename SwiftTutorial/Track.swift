//
//  Track.swift
//  SwiftTutorial
//
//  Created by Anton Pomozov on 19.06.14.
//  Copyright (c) 2014 JQ Software LLC. All rights reserved.
//

import Foundation

class Track {
    let title: String?
    let price: String?
    let previewUrl: String?
    
    init(dict: NSDictionary!) {
        self.title = dict["trackName"] as? String
        self.price = dict["trackPrice"] as? String
        self.previewUrl = dict["previewUrl"] as? String
    }
}
