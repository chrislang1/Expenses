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
    
    var totalCostVC: TotalCostViewController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editBarButton: UIBarButtonItem!
    @IBOutlet var addBarButton: UIBarButtonItem!
    @IBOutlet weak var noExpensesView: UIView!
    @IBOutlet weak var removeExpenseButton: UIButton!
    @IBOutlet weak var removeExpenseConstraint: NSLayoutConstraint!
    
    var expenseArray = [Expense]()
    var selectedExpense: Int?
    var periodSelectionHidden = true
    var periodType = Expense.PeriodType.day
    
    let textColor = #colorLiteral(red: 0.5377323031, green: 0.4028604627, blue: 0.9699184299, alpha: 1)
    let backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.2862745098, blue: 0.9607843137, alpha: 0.2)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard
    
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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(noExpensesViewTapped))
        noExpensesView.addGestureRecognizer(gesture)
        
        loadExpenses()
        addTotalCostView()
        checkExpenseArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkExpenseArray()
        setTotalCost()
        
        if let index = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: index) {
            tableView.deselectRow(at: index, animated: true)
            cell.backgroundColor = .white
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.textColor = .black
            tableView.reloadData()
        }
    }
    
    //MARK: - Add Total Cost View to bottom of screen
    func addTotalCostView(){
        totalCostVC = storyboard?.instantiateViewController(withIdentifier: "TotalCostViewController") as? TotalCostViewController
        if let totalCostVC = totalCostVC {
        
            self.addChildViewController(totalCostVC)
            self.view.addSubview(totalCostVC.view)
            totalCostVC.didMove(toParentViewController: self)
            
            let height = view.frame.height
            let width = view.frame.width
            totalCostVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        
            totalCostVC.expenseArray = expenseArray
        }
    }
    
    func setTotalCost(){
        if let totalCostVC = totalCostVC {
            totalCostVC.expenseArray = expenseArray
        }
    }
    
    func checkExpenseArray(){
        if expenseArray.count == 0 {
            noExpensesView.isHidden = false
            tableView.isHidden = true
            navigationItem.leftBarButtonItem = nil
        } else {
            noExpensesView.isHidden = true
            tableView.isHidden = false
            navigationItem.leftBarButtonItem = self.editBarButton
        }
    }
    
    @objc func noExpensesViewTapped(){
        performSegue(withIdentifier: "goToAddExpense", sender: self)
    }
    
    @IBAction func touchUpRemoveButton(_ sender: Any) {
        guard let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows else { return }
        indexPathsForSelectedRows.map { expenseArray[$0.row] }.forEach {
            // Delete the row from the data source
            context.delete($0)
            saveExpenses()
            expenseArray.remove(at: expenseArray.index(of: $0)!)
            if let totalCostVC = totalCostVC {
                totalCostVC.expenseArray = expenseArray
                totalCostVC.updateLabels()
            }
        }
        tableView.deleteRows(at: indexPathsForSelectedRows, with: .fade)
    }
    
    //MARK: - Set Table View to Edit Mode
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if (self.tableView.isEditing == true) {
            self.tableView.setEditing(false, animated: true)
            self.editBarButton.title = "Edit"
            self.navigationItem.rightBarButtonItem = self.addBarButton
            removeExpenseConstraint.constant = -82
            checkExpenseArray()
            if let totalCostVC = totalCostVC {
                totalCostVC.moveUp()
                totalCostVC.updateLabels()
            }
        } else if (self.tableView.isEditing == false) {
            self.tableView.setEditing(true, animated: true)
            self.editBarButton.title = "Done"
            removeExpenseConstraint.constant = 9
            self.navigationItem.rightBarButtonItem = nil
            if let totalCostVC = totalCostVC {
                totalCostVC.moveDown()
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - New Expense Delegete Methods
    func addNewExpense(name: String, cost: Double, numberOfPeriods: Double, periodLength: Int) {
        let expense = Expense(context: context)
        expense.name = name
        expense.price = cost
        expense.periodLength = numberOfPeriods
        
        guard let periodType = Expense.PeriodType(rawValue: periodLength) else {return}
        expense.periodType = Int16(periodLength)
        expense.yearPrice = cost * (periodType.countPerYear/numberOfPeriods)
        
        expenseArray.append(expense)
        indexExpenseArray()
        saveExpenses()
        tableView.reloadData()
    }
    
    //MARK: - Update Expense Delegete Methods
    func updateExpense(expense: Expense) {
        if let periodType = Expense.PeriodType(rawValue: Int(expense.periodType)){
            expense.yearPrice = expense.price * (periodType.countPerYear/expense.periodLength)
        } else {
            periodType = .month
            expense.yearPrice = expense.price * (periodType.countPerYear/expense.periodLength)
        }
        saveExpenses()
    }
    
    func deleteExpense(expense: Expense){
        context.delete(expenseArray[selectedExpense!])
        expenseArray.remove(at: selectedExpense!)
        indexExpenseArray()
        saveExpenses()
        //tableView.reloadData()
    }
    
    func indexExpenseArray(){
        for index in expenseArray.indices {
            expenseArray[index].arrayIndex = Int16(index)
        }
    }
    
    //MARK: - Segue Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if tableView.isEditing == false {
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
                    destinationVC.periodSelected = true
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "goToEditExpense" {
            return !tableView.isEditing
        } else {
            return true
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
            cell.backgroundColor = backgroundColor
            cell.textLabel?.textColor = textColor
            cell.detailTextLabel?.textColor = textColor
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

