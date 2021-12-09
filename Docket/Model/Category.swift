//
//  Category.swift
//  Docket
//
//  Created by ASHMIT SHUKLA on 06/12/21.
//

import Foundation
import RealmSwift

class Category:Object
{
    @objc dynamic var name : String = ""
    @objc dynamic var background: String = ""
    let items = List<Item>()
}
