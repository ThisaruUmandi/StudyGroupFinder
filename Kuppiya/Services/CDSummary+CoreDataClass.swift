//
//  CDSummary+CoreDataClass.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import Foundation
import CoreData

@objc(CDSummary)
public class CDSummary: NSManagedObject {
    @NSManaged public var resourceId: String?
    @NSManaged public var title: String?
    @NSManaged public var summaryText: String?
    @NSManaged public var generatedAt: Date?
}

extension CDSummary {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSummary> {
        return NSFetchRequest<CDSummary>(entityName: "CDSummary")
    }
}
