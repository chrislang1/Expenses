//
//  ExpensesViewController.swift
//  Subscriptions
//
//  Created by Chris Lang on 31/5/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit
import CoreData

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewExpenseDelegate {

    
    @IBOutlet weak var expensesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var expenseArray = [Expense]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Remove Navigation Bar Border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //Set Table View Delegate and DataSource + Row Height
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 74
        tableView.separatorStyle = .none
        
        //Register .xib cell
        tableView.register(UINib(nibName: "SubscriptionCell", bundle: nil), forCellReuseIdentifier: "subscriptionCell")
        
//        //Filler Subscription Items
//        let netflix = Expense(context: context)
//        netflix.name = "Netflix"
//        netflix.price = 14.00
//        netflix.periodLength = 1
//        netflix.periodType = "Month(s)"
//        expenseArray.append(netflix)
//
//        let appleMusic = Expense(context: context)
//        appleMusic.name = "Apple Music"
//        appleMusic.price = 18.00
//        appleMusic.periodLength = 1
//        appleMusic.periodType = "Month(s)"
//        expenseArray.append(appleMusic)
        
        loadExpenses()
        expensesViewSetup()
        
    }

    //MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subscriptionCell", for: indexPath) as! SubscriptionCell
        
        let subscription = expenseArray[indexPath.row]
        cell.nameLabel.text = subscription.name!
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        
        let price = subscription.price
        cell.priceLabel.text = currencyFormatter.string(from: NSNumber(value: price))
        
        return cell
    }
    
    //Setup Expenses View
    func expensesViewSetup(){
        expensesView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.94).cgColor
        expensesView.clipsToBounds = false
        expensesView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        expensesView.layer.shadowPath = UIBezierPath(roundedRect: expensesView.bounds, cornerRadius: 10).cgPath
        expensesView.layer.shadowOpacity = 1
        expensesView.layer.shadowRadius = 2
        expensesView.layer.shadowOffset = CGSize.zero
    }
    
    func expensesLabelSetup(){
        //Update Labels in Expense View
    }
    
    //MARK: - New Expense Delegete Methods
    func addNewExpense(name: String, cost: Double, numberOfPeriods: Int, periodLength: String) {
        let expense = Expense(context: context)
        expense.name = name
        expense.price = cost
        expense.periodLength = Int16(numberOfPeriods)
        expense.periodType = periodLength
        
        expenseArray.append(expense)
        saveExpenses()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddExpense" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationVC = destinationNavigationController.topViewController as! AddExpenseViewController
            
            destinationVC.delegate = self
        }
    }
    
    //MARK: - Load and Save Methods
    func loadExpenses(with request: NSFetchRequest<Expense> = Expense.fetchRequest()){
        do{
            expenseArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func saveExpenses(){
        do{
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
    }

}

