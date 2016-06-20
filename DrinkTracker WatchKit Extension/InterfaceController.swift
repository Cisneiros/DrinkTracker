//
//  InterfaceController.swift
//  DrinkTracker WatchKit Extension
//
//  Created by Alexandre Cisneiros on 20/01/2016.
//  Copyright © 2016 Alexandre Cisneiros. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    // MARK: Outlets
    
    @IBOutlet var counterLabel: WKInterfaceLabel!
    @IBOutlet var drinkNamePicker: WKInterfacePicker!
    @IBOutlet var addOneButton: WKInterfaceButton!
    
    // MARK: Properties
    var session : WCSession!
    
    var drink: Drink? = nil {
        didSet {
            updateInterface()
        }
    }
    
    var drinks: [Drink] = [] {
        didSet {
            drinkNamePicker.setItems(drinks.map {drink in
                let item = WKPickerItem()
                item.title = drink.name
                item.caption = drink.name
                return item
            })
            drinkNamePicker.setSelectedItemIndex(0)
        }
    }
    
    // MARK: Initializers
    
    override init() {
        super.init()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let loadedDrinks = Drink.loadAll()
        
        if (loadedDrinks == nil) {
            let deafaultDrinkNames = ["Beer", "Senses", "Spirit"]
            drinks = deafaultDrinkNames.map {name in Drink(name: name, count: 0)}
            Drink.saveAll(drinks)
        } else {
            drinks = loadedDrinks!
        }
        
        drink = drinks[0]
    }
    
    // MARK: Methods
    
    func updateInterface() {
        counterLabel.setText(String(drink!.count))
    }
    
    func addToCurrentDrinkCount(count: Int = 1) {
        drink?.count += count
        Drink.saveAll(drinks)
        updateInterface()
    }
    
    // MARK: Session
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let appDrinkNames = applicationContext["drinkNames"] as? [String]
        if (appDrinkNames != nil) {
            let appDrinkNamesSet = Set(appDrinkNames!)
            let localDrinkNamesSet = Set(drinks.map {drink in drink.name})
            
            let newDrinks = appDrinkNamesSet.subtract(localDrinkNamesSet).map {name in Drink(name: name, count: 0) }
            drinks = (drinks.filter {drink in appDrinkNamesSet.contains(drink.name)} + newDrinks).sort {$0.name.caseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending}
            
            Drink.saveAll(drinks)
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func drinkNamePickerSelectedItemChanged(value: Int) {
        drink = drinks[value]
    }
    
    @IBAction func addOneButtonClicked(sender: WKInterfaceButton) {
        addToCurrentDrinkCount()
    }
    
    @IBAction func removeOneMenuItemClicked() {
        addToCurrentDrinkCount(-1)
    }
    
    @IBAction func resetAllMenuItemClicked() {
        drinks.forEach {drink in
            drink.count = 0
        }
        Drink.saveAll(drinks)
        updateInterface()
    }
    
    // MARK: Destroyers

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
