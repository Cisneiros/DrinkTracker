//
//  Drink.swift
//  DrinkTracker
//
//  Created by Alexandre Cisneiros on 20/01/2016.
//  Copyright © 2016 Alexandre Cisneiros. All rights reserved.
//

import Foundation

class Drink: NSObject, NSCoding {
    
    // MARK: Properties
    
    var name: String
    var count: Int {
        didSet {
            if count < 0 {
                count = 0
            }
        }
    }
    
    // MARK: Designated Initializer
    
    init(name: String, count: Int = 0) {
        self.name = name
        self.count = count
        
        super.init()
    }
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let countKey = "count"
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("drinks")
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeInteger(count, forKey: PropertyKey.countKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let count = aDecoder.decodeIntegerForKey(PropertyKey.countKey)
        self.init(name: name, count: count)
    }
    
    static func saveAll(list: [Drink]) -> Bool {
        return NSKeyedArchiver.archiveRootObject(list, toFile: ArchiveURL.path!)
    }
    
    static func loadAll() -> [Drink]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(ArchiveURL.path!) as? [Drink]
    }
}