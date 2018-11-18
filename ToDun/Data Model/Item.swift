//
//  Item.swift
//  ToDun
//
//  Created by El Benitez on 11/12/18.
//  Copyright © 2018 Eleuterio Benitez. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title = ""
    @objc dynamic var done = false
    @objc dynamic var dateCreated: Date?
    let parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
