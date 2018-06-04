//
//  ExpensesViewController.swift
//  Subscriptions
//
//  Created by Chris Lang on 31/5/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit
import CoreData

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewExpenseDelegate, EditExpenseDelegate {

    
    @IBOutlet weak var totalExpensesPriceLabel: UILabel!
    @IBOutlet weak var expensePeriodLabel: UILabel!
    @IBOutlet weak var expensesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var expensePeriodView: UIView!
    
    @IBOutlet var expensePeirodButtons: [UIButton]!
    
    var expenseArray = [Expense]()
    var selectedExpense: Int?
    var expenseViewY = CGFloat()
    
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
        
        loadExpenses()
        expensesViewSetup()
        expensesLabelSetup()
        
        expenseViewY = UIScreen.main.bounds.height - 69
        
        //Set Expense Period Button
        expensePeirodButtons[2].backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
        expensePeirodButtons[2].setTitleColor(#colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1), for: .normal)
        expensePeriodView.frame = CGRect(x: self.expensePeriodView.frame.origin.x, y: UIScreen.main.bounds.height, width: self.expensePeriodView.frame.width, height: self.expensePeriodView.frame.height)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEditExpense", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            context.delete(expenseArray[indexPath.row])
            saveExpenses()
            expenseArray.remove(at: indexPath.row)
            expensesLabelSetup()
            // Delete the row from the TableView
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
//    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
//        var rowToMove = expenseArray[fromIndexPath.row]
//        expenseArray.remove(at: fromIndexPath.row)
//        expenseArray.insert(rowToMove, at: toIndexPath.row)
//        saveExpenses()
//    }
    
    //MARK: - Set Table View to Edit Mode
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if (self.tableView.isEditing == true) {
            self.tableView.isEditing = false
            self.editBarButton.title = "Edit"
        } else if (self.tableView.isEditing == false) {
            self.tableView.isEditing = true
            self.editBarButton.title = "Done"
        }
    }
    
    //MARK: - Setup Expenses View
    func expensesViewSetup(){
        expensesView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.94).cgColor
        expensesView.clipsToBounds = false
        expensesView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        expensesView.layer.shadowPath = UIBezierPath(roundedRect: expensesView.bounds, cornerRadius: 10).cgPath
        expensesView.layer.shadowOpacity = 1
        expensesView.layer.shadowRadius = 2
        expensesView.layer.shadowOffset = CGSize.zero
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.expenseLabelTouched (_:)))
        self.expensesView.addGestureRecognizer(gesture)
    }
    
    func expensesLabelSetup(per timePeriod: Double = 12, with label: String = "per month"){
        //Update Labels in Expense View
        var totalPrice = Double()
        for index in expenseArray.indices {
            totalPrice += expenseArray[index].yearPrice
        }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        let price = totalPrice/timePeriod
        totalExpensesPriceLabel.text = currencyFormatter.string(from: NSNumber(value: price))
        expensePeriodLabel.text = label.lowercased()
    }
    
    @objc func expenseLabelTouched(_ sender: UITapGestureRecognizer){
        UIView.animate(withDuration: 0.3) {
            if self.expensePeriodView.isHidden == true{
                let desiredY = UIScreen.main.bounds.height - CGFloat(180)
                self.expensesView.frame = CGRect(x: self.expensesView.frame.origin.x, y: desiredY, width: self.expensesView.frame.width, height: self.expensesView.frame.height)
                self.expensePeriodView.isHidden = false
                self.expensePeriodView.frame = CGRect(x: self.expensePeriodView.frame.origin.x, y: UIScreen.main.bounds.height-120, width: self.expensePeriodView.frame.width, height: self.expensePeriodView.frame.height)
            } else {
                self.expensesView.frame = CGRect(x: self.expensesView.frame.origin.x, y: self.expenseViewY, width: self.expensesView.frame.width, height: self.expensesView.frame.height)
                self.expensePeriodView.frame = CGRect(x: self.expensePeriodView.frame.origin.x, y: UIScreen.main.bounds.height, width: self.expensePeriodView.frame.width, height: self.expensePeriodView.frame.height)
                self.expensePeriodView.isHidden = true
            }
        }
    }
    
    //MARK: - Expense Time Period Method
    
    @IBAction func expencePeriodSelected(_ sender: UIButton) {
        for index in expensePeirodButtons.indices {
            if sender == expensePeirodButtons[index]{
                expensePeirodButtons[index].backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
                expensePeirodButtons[index].setTitleColor(#colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1), for: .normal)
            } else {
                expensePeirodButtons[index].backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
                expensePeirodButtons[index].setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            }
        }
        let expensePeriod = Double(sender.tag)
        expensesLabelSetup(per: expensePeriod, with: sender.title(for: .normal)!)
        UIView.animate(withDuration: 0.3) {
            self.expensePeriodView.frame = CGRect(x: self.expensePeriodView.frame.origin.x, y: UIScreen.main.bounds.height, width: self.expensePeriodView.frame.width, height: self.expensePeriodView.frame.height)
            self.expensePeriodView.isHidden = true
            self.expensesView.frame = CGRect(x: self.expensesView.frame.origin.x, y: self.expenseViewY, width: self.expensesView.frame.width, height: self.expensesView.frame.height)
        }
    }
    
    
    //MARK: - New Expense Delegete Methods
    func addNewExpense(name: String, cost: Double, numberOfPeriods: Int, periodLength: String) {
        let expense = Expense(context: context)
        expense.name = name
        expense.price = cost
        expense.periodLength = Int16(numberOfPeriods)
        expense.periodType = periodLength
        expense.yearPrice = setPricePerYear(cost: cost, numberOfPeriods: numberOfPeriods, periodLength: periodLength)
        
        expenseArray.append(expense)
        saveExpenses()
        expensesLabelSetup()
        tableView.reloadData()
    }
    
    func setPricePerYear (cost: Double, numberOfPeriods: Int, periodLength: String) -> Double {
        var periodTypePerYear: Double?
        switch periodLength {
        case "Day(s)":
            periodTypePerYear = 365
        case "Week(s)":
            periodTypePerYear = 52
        case "Fortnight(s)":
            periodTypePerYear = 26
        case "Month(s)":
            periodTypePerYear = 12
        case "Year(s)":
            periodTypePerYear = 1
        default:
            periodTypePerYear = nil
        }
        return cost * (periodTypePerYear!/Double(numberOfPeriods))
    }
    
    //MARK: - Update Expense Delegete Methods
    func updateExpense(expense: Expense) {
        expense.yearPrice = setPricePerYear(cost: expense.price, numberOfPeriods: Int(expense.periodLength), periodLength: expense.periodType!)
        saveExpenses()
        tableView.reloadData()
        expensesLabelSetup()
    }
    
    func deleteExpense(expense: Expense){
        context.delete(expenseArray[selectedExpense!])
        saveExpenses()
        expenseArray.remove(at: selectedExpense!)
        tableView.reloadData()
        expensesLabelSetup()
    }
    
    //MARK: - Prepare for Segue Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToAddExpense" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationVC = destinationNavigationController.topViewController as! AddExpenseViewController
            
            destinationVC.delegate = self
            destinationVC.identifyingSegue = segue.identifier!
        }
        
        if segue.identifier == "goToEditExpense" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationVC = destinationNavigationController.topViewController as! AddExpenseViewController
            
            destinationVC.delegate2 = self
            destinationVC.identifyingSegue = segue.identifier!
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedExpense = expenseArray[indexPath.row]
                selectedExpense = indexPath.row
            }
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

