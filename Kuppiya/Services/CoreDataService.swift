//
//  CoreDataService.swift
//  Kuppiya
//
//  Created by M H T U De Silva on 2026-05-04.
//

import CoreData

class CoreDataService {
    static let shared = CoreDataService()

    let container: NSPersistentContainer

    init() {
        let model = NSManagedObjectModel()

        // CDSummary
        let summaryEntity = NSEntityDescription()
        summaryEntity.name = "CDSummary"
        summaryEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let sResourceId = NSAttributeDescription()
        sResourceId.name = "resourceId"
        sResourceId.attributeType = .stringAttributeType
        sResourceId.isOptional = true

        let sTitle = NSAttributeDescription()
        sTitle.name = "title"
        sTitle.attributeType = .stringAttributeType
        sTitle.isOptional = true

        let sSummaryText = NSAttributeDescription()
        sSummaryText.name = "summaryText"
        sSummaryText.attributeType = .stringAttributeType
        sSummaryText.isOptional   = true

        let sGeneratedAt = NSAttributeDescription()
        sGeneratedAt.name = "generatedAt"
        sGeneratedAt.attributeType = .dateAttributeType
        sGeneratedAt.isOptional = true

        summaryEntity.properties  = [sResourceId, sTitle, sSummaryText, sGeneratedAt]

        // CDDownload
        let downloadEntity = NSEntityDescription()
        downloadEntity.name = "CDDownload"
        downloadEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let dResourceId = NSAttributeDescription()
        dResourceId.name = "resourceId"
        dResourceId.attributeType = .stringAttributeType
        dResourceId.isOptional = true

        let dTitle                = NSAttributeDescription()
        dTitle.name               = "title"
        dTitle.attributeType      = .stringAttributeType
        dTitle.isOptional         = true

        let dFilename             = NSAttributeDescription()
        dFilename.name            = "filename"
        dFilename.attributeType   = .stringAttributeType
        dFilename.isOptional      = true

        let dFilePath             = NSAttributeDescription()
        dFilePath.name            = "filePath"
        dFilePath.attributeType   = .stringAttributeType
        dFilePath.isOptional      = true

        let dFileSize             = NSAttributeDescription()
        dFileSize.name            = "fileSize"
        dFileSize.attributeType   = .integer64AttributeType
        dFileSize.isOptional      = true

        let dDownloadedAt         = NSAttributeDescription()
        dDownloadedAt.name        = "downloadedAt"
        dDownloadedAt.attributeType = .dateAttributeType
        dDownloadedAt.isOptional  = true

        downloadEntity.properties = [dResourceId, dTitle, dFilename, dFilePath, dFileSize, dDownloadedAt]

        model.entities = [summaryEntity, downloadEntity]

        container = NSPersistentContainer(name: "KuppiyaStore", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error { print("Core Data error: \(error)") }
        }
    }

    var context: NSManagedObjectContext { container.viewContext }

    func save() {
        if context.hasChanges { try? context.save() }
    }

    // MARK: - Summaries

    func saveSummary(resourceId: String, title: String, summaryText: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDSummary")
        request.predicate = NSPredicate(format: "resourceId == %@", resourceId)
        if let existing = (try? context.fetch(request))?.first {
            existing.setValue(summaryText, forKey: "summaryText")
            existing.setValue(Date(),      forKey: "generatedAt")
        } else {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "CDSummary", into: context)
            obj.setValue(resourceId,  forKey: "resourceId")
            obj.setValue(title,       forKey: "title")
            obj.setValue(summaryText, forKey: "summaryText")
            obj.setValue(Date(),      forKey: "generatedAt")
        }
        save()
        print("Summary saved: \(title)")
    }

    func fetchSummaries() -> [(resourceId: String, title: String, summaryText: String, generatedAt: Date)] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDSummary")
        request.sortDescriptors = [NSSortDescriptor(key: "generatedAt", ascending: false)]
        return ((try? context.fetch(request)) ?? []).map {(
            resourceId:  $0.value(forKey: "resourceId")  as? String ?? "",
            title:       $0.value(forKey: "title")       as? String ?? "",
            summaryText: $0.value(forKey: "summaryText") as? String ?? "",
            generatedAt: $0.value(forKey: "generatedAt") as? Date   ?? Date()
        )}
    }

    func deleteSummary(resourceId: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDSummary")
        request.predicate = NSPredicate(format: "resourceId == %@", resourceId)
        (try? context.fetch(request))?.forEach { context.delete($0) }
        save()
    }

    // MARK: - Downloads

    func saveDownload(resourceId: String, title: String, filename: String, filePath: String, fileSize: Int64) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDDownload")
        request.predicate = NSPredicate(format: "resourceId == %@", resourceId)
        if let existing = (try? context.fetch(request))?.first {
            existing.setValue(filePath, forKey: "filePath")
            existing.setValue(Date(),   forKey: "downloadedAt")
        } else {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "CDDownload", into: context)
            obj.setValue(resourceId, forKey: "resourceId")
            obj.setValue(title,      forKey: "title")
            obj.setValue(filename,   forKey: "filename")
            obj.setValue(filePath,   forKey: "filePath")
            obj.setValue(fileSize,   forKey: "fileSize")
            obj.setValue(Date(),     forKey: "downloadedAt")
        }
        save()
        print("Download saved: \(filename)")
    }

    func fetchDownloads() -> [(resourceId: String, title: String, filename: String, filePath: String, fileSize: Int64, downloadedAt: Date)] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDDownload")
        request.sortDescriptors = [NSSortDescriptor(key: "downloadedAt", ascending: false)]
        return ((try? context.fetch(request)) ?? []).map {(
            resourceId:   $0.value(forKey: "resourceId")   as? String ?? "",
            title:        $0.value(forKey: "title")        as? String ?? "",
            filename:     $0.value(forKey: "filename")     as? String ?? "",
            filePath:     $0.value(forKey: "filePath")     as? String ?? "",
            fileSize:     $0.value(forKey: "fileSize")     as? Int64  ?? 0,
            downloadedAt: $0.value(forKey: "downloadedAt") as? Date   ?? Date()
        )}
    }

    func deleteDownload(resourceId: String) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDDownload")
        request.predicate = NSPredicate(format: "resourceId == %@", resourceId)
        (try? context.fetch(request))?.forEach { context.delete($0) }
        save()
    }
}
