//
//  Item.swift
//  Docket
//
//  Created by ASHMIT SHUKLA on 06/12/21.
//

import Foundation
import RealmSwift
class Item:Object{
    @objc dynamic var title:String=""
    @objc dynamic var done:Bool=false
    @objc dynamic var createdDate:Date?
    var ParentCategory=LinkingObjects(fromType:Category.self,property:"items")
}
