//
//  StatisticManager.swift
//  Awear
//
//  Created by James Carlson on 11/1/18.
//  Copyright © 2018 James Carlson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/* Manages the Entity Statistic */
class StatisticManager: NSObject {

    /* Saves a new entity into the DB */
    static func save(date: Date, threshold: Float, voiceLevel: Float, heartRate: Double) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Statistic", in: context)
        let newStat = NSManagedObject(entity: entity!, insertInto: context)

        newStat.setValue(date, forKey: "date")
        newStat.setValue(threshold, forKey: "threshold")
        newStat.setValue(voiceLevel, forKey: "voiceLevel")
        newStat.setValue(heartRate, forKey: "heartRate")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    /* Returns all the entities */
    static func fetchAll() -> [NSManagedObject] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Statistic")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
//            for data in result as! [NSManagedObject] {
//                print(data.value(forKey: "date") as! Date)
//            }
            return result as! [NSManagedObject]
        } catch {
            print("Failed")
            return []
        }
    }
    
    /* Deletes all the entities in the DB */
    static func deleteAll() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Statistic")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try context.execute(request)
            return true
        } catch let error as NSError {
            // TODO: handle the error
            print("FAILED TO DELETE ALL: \(error)")
            return false
        }
    }
}
