//
//  Answer.swift
//  Jeopordy
//
//  Created by Rave BizzDev on 6/1/20.
//  Copyright © 2020 Rave BizzDev. All rights reserved.
//

import Foundation

class Answer : Codable {
    var flipped: Bool?
    var favorite: Bool?
    
    let answer: String
    let question: String
    let category: Category
    let value: Int?
    let category_id: Int
    
    var category_title: String {
        get {
            return self.category.title
        }
    }
}

struct Category : Codable {
    let title: String
}
