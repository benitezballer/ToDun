//
//  Category.swift
//  ToDun
//
//  Created by El Benitez on 11/12/18.
//  Copyright © 2018 Eleuterio Benitez. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    @objc dynamic var color = ""
    let items = List<Item>()
}
