//
//  ExpensesViewController.swift
//  Subscriptions
//
//  Created by Chris Lang on 31/5/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit
import CoreData

class ExpensesViewController: UIViewController, NewExpenseDelegate, EditExpenseDelegate {
    
    
    @IBOutlet weak var totalExpensesPriceLabel: UILabel!
    @IBOutlet weak var expensePeriodLabel: UILabel!
    @IBOutlet weak var expensesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editBarButton: UIBarButtonItem!
    @IBOutlet var addBarButton: UIBarButtonItem!
    
    @IBOutlet weak var expensePeriodView: UIView!
    @IBOutlet weak var expensePeriodViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noExpensesView: UIView!
    @IBOutlet weak var removeExpenseButton: UIButton!
    
    @IBOutlet weak var expenseViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var removeExpenseConstraint: NSLayoutConstraint!
    
    @IBOutlet var expensePeirodButtons: [UIButton]!
    
    var expenseArray = [Expense]()
    var selectedExpense: Int?
    var expenseViewY = CGFloat()
    var periodSelectionHidden = true
    
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
        
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelectionDuringEditing = true
        
        //Register .xib cell
        tableView.register(UINib(nibName: "SubscriptionCell", bundle: nil), forCellReuseIdentifier: "subscriptionCell")
        
        loadExpenses()
        expensesViewSetup()
        expensesLabelSetup()
        
        expenseViewY = UIScreen.main.bounds.height - 69
        
        //Set Expense Period Button
        expensePeriodSetup()
        
        if expenseArray.count == 0 {
            noExpensesView.isHidden = false
            tableView.isHidden = true
        } else {
            noExpensesView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if expenseArray.count == 0 {
            noExpensesView.isHidden = false
            tableView.isHidden = true
            navigationItem.leftBarButtonItem = nil
        } else {
            noExpensesView.isHidden = true
            tableView.isHidden = false
            navigationItem.leftBarButtonItem = self.editBarButton
        }
        
        if let index = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: index) {
            tableView.deselectRow(at: index, animated: true)
            cell.backgroundColor = .white
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
        }
    }
    
    
    @IBAction func touchUpRemoveButton(_ sender: Any) {
        guard let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows else { return }
        indexPathsForSelectedRows.map { expenseArray[$0.row] }.forEach {
            // Delete the row from the data source
            context.delete($0)
            saveExpenses()
            expenseArray.remove(at: expenseArray.index(of: $0)!)
            expensesLabelSetup()
        }
        tableView.deleteRows(at: indexPathsForSelectedRows, with: .fade)
    }
    
    //MARK: - Set Table View to Edit Mode
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if (self.tableView.isEditing == true) {
            self.tableView.setEditing(false, animated: true)
            self.editBarButton.title = "Edit"
            self.navigationItem.rightBarButtonItem = self.addBarButton
            expenseViewBottonConstraint.constant = 9
            removeExpenseConstraint.constant = -82
        } else if (self.tableView.isEditing == false) {
            self.tableView.setEditing(true, animated: true)
            self.tableView.isEditing = true
            self.editBarButton.title = "Done"
            expenseViewBottonConstraint.constant = -93
            removeExpenseConstraint.constant = 9
            self.navigationItem.rightBarButtonItem = nil
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Expense Period Setup
    func expensePeriodSetup(){
        expensePeirodButtons[2].backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
        expensePeirodButtons[2].setTitleColor(#colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1), for: .normal)
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
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(expenseLabelSwipe))
        swipeUp.direction = .up
        self.expensesView.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(expenseLabelSwipe))
        swipeDown.direction = .down
        self.expensesView.addGestureRecognizer(swipeDown)
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
    
    @objc func expenseLabelSwipe(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.up {
            self.expensePeriodViewTopConstraint.constant = -120
            expenseViewBottonConstraint.constant = 120
        } else if gesture.direction == UISwipeGestureRecognizerDirection.down {
            self.expensePeriodViewTopConstraint.constant = 34
            expenseViewBottonConstraint.constant = 9
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
        indexExpenseArray()
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
        return cost * (periodTypePerYear!/Double(numberOfPeriods)) /// [Andy] never use force unwrapping
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
        expenseArray.remove(at: selectedExpense!)
        indexExpenseArray()
        saveExpenses()
        tableView.reloadData()
        expensesLabelSetup()
    }
    
    func indexExpenseArray(){
        for index in expenseArray.indices {
            expenseArray[index].arrayIndex = Int16(index)
        }
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
        let sort = NSSortDescriptor(key: "arrayIndex", ascending: true)
        request.sortDescriptors = [sort]
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

//MARK: - TableView Delegate and Data Source Methods
extension ExpensesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "subscription", for: indexPath)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        let subscription = expenseArray[indexPath.row]
        cell.textLabel?.text = subscription.name
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        let price = subscription.price
        cell.detailTextLabel?.text = currencyFormatter.string(from: NSNumber(value: price))
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing != true,
            let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
            cell.textLabel?.textColor = #colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1)
            DispatchQueue.main.async() { () -> Void in
                self.performSegue(withIdentifier: "goToEditExpense", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: 3)!
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let rowToMove = expenseArray[fromIndexPath.row]
        expenseArray.remove(at: fromIndexPath.row)
        expenseArray.insert(rowToMove, at: toIndexPath.row)
        indexExpenseArray()
        saveExpenses()
    }
}

