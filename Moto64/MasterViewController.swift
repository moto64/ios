//
//  MasterViewController.swift
//  Moto64
//
//  Created by AseR on 15.03.15.
//
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var data = DataFeed()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl?.attributedTitle = NSAttributedString(string: "Идет обновление...")
        
        loadData()

    }
    
    func refresh(sender:AnyObject)
    {
        loadData()
    }
    
    func loadData()
    {
        refreshControl?.beginRefreshing()
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            self.data.loadData()
            self.storeData()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    func storeData()
    {
        for item in data.getFeed() {
            if !isItemExists(item.pubDate) {
                insertNewItem(item)
            } else if item.latitude != "" && item.longitude != "" {
                // Add coordinates to database
                addCoordsToDatabaseIfNotExists(item)
            }
        }
    }
    
    func addCoordsToDatabaseIfNotExists(item: DataFeed.Item)
    {
        let pubDate: NSDate = item.pubDate
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "pubDate == %@", argumentArray: [pubDate])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        var error: NSError? = nil
        if let records = context.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject] {
            if let record = records.first {
                let latitude = record.valueForKey("latitude") as? String
                let longitude = record.valueForKey("longitude") as? String
                if latitude == nil || longitude == nil {
                    record.setValue(item.latitude, forKey: "latitude")
                    record.setValue(item.longitude, forKey: "longitude")
                    var error: NSError? = nil
                    if context.hasChanges && !context.save(&error) {
                        println(error)
                    }
                }
            }
        }
    }
    
    func isItemExists(pubDate: NSDate) -> Bool
    {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        let predicate = NSPredicate(format: "pubDate == %@", argumentArray: [pubDate])
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        var error: NSError? = nil
        let count = context.countForFetchRequest(fetchRequest, error: &error)
    
        return count > 0
    }

    func insertNewItem(data: DataFeed.Item) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as NSManagedObject
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(data.pubDate, forKey: "pubDate")
        newManagedObject.setValue(data.title, forKey: "title")
        newManagedObject.setValue(data.descr, forKey: "descr")
        newManagedObject.setValue(data.link, forKey: "link")
        newManagedObject.setValue(data.isNew, forKey: "isNew")
        newManagedObject.setValue(data.latitude, forKey: "latitude")
        newManagedObject.setValue(data.longitude, forKey: "longitude")
             
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            println("Unresolved error \(error)")
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController

                var item = DataFeed.Item()
                
                item.title = object.valueForKey("title") as String
                item.link = object.valueForKey("link") as String
                item.descr = object.valueForKey("descr") as String
                item.pubDate = object.valueForKey("pubDate") as NSDate
                let latitude = object.valueForKey("latitude") as? String
                let longitude = object.valueForKey("longitude") as? String
                if latitude != nil {
                    item.latitude = latitude!
                }
                if longitude != nil {
                    item.longitude = longitude!
                }
                controller.detailItem = item
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                println("Unresolved error \(error)")
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            let context = self.fetchedResultsController.managedObjectContext
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
            object.setValue(false, forKey: "isNew")
            
            var error: NSError? = nil
            if !context.save(&error) {
                println("Unresolved error \(error)")
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        cell.textLabel!.text = object.valueForKey("title") as? String
        
        if let date = object.valueForKey("pubDate") as? NSDate {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            cell.detailTextLabel!.text = dateFormatter.stringFromDate(date)
        }
        
        let isNew = object.valueForKey("isNew") as Bool
        if isNew {
            cell.textLabel!.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
        } else {
            cell.textLabel!.font = UIFont(name:"HelveticaNeue-Thin", size: 12.0)
        }
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "pubDate", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
             println("Unresolved error \(error)")
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

