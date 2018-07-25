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
    var settingsVC: SettingsViewController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editBarButton: UIBarButtonItem!
    @IBOutlet var addBarButton: UIBarButtonItem!
    @IBOutlet weak var noExpensesView: UIView!
    @IBOutlet weak var removeExpenseButton: UIButton!
    @IBOutlet weak var removeExpenseConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomColorView: UIView!
    
    var expenseArray = [Expense]()
    var editModeExpenseArray = [Expense]()
    var selectedExpense: Int?
    var periodSelectionHidden = true
    var periodType = Expense.PeriodType.day
    var doneBarButton = UIBarButtonItem()
    var theme = Theme.init(rawValue: 0)
    var dimBackgroundView = UIView()
    var dimNavigationView = UIView()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        theme = Theme.init(rawValue: defaults.integer(forKey: "SelectedTheme")) ?? Theme.init(rawValue: 0)
        //Remove Navigation Bar Border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.layer.backgroundColor = theme?.applicationBackgroundColor
        
        let fontStyle = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        editBarButton.setTitleTextAttributes([NSAttributedStringKey.font: fontStyle], for: .normal)
        let tempButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarButtonPressed))
        doneBarButton = tempButton
        doneBarButton.setTitleTextAttributes([NSAttributedStringKey.font: fontStyle, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5294117647, alpha: 1)], for: .normal)
        doneBarButton.tintColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5294117647, alpha: 1)
        
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
        
        //Setup dimming view
        dimBackgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        dimBackgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimBackgroundView.alpha = 1
        dimNavigationView.frame = CGRect(x: 0, y: 0, width: (navigationController?.view.frame.width)!, height: (navigationController?.view.frame.height)!)
        dimNavigationView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        dimNavigationView.alpha = 1
        
        loadExpenses()
        addTotalCostView()
        //addSettingsView()
        checkExpenseArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkExpenseArray()
        setTotalCost()
        updateTheme()
        
        if let index = tableView.indexPathForSelectedRow,
            let cell = tableView.cellForRow(at: index) {
            tableView.deselectRow(at: index, animated: true)
            cell.backgroundColor = .clear
            cell.textLabel?.textColor = theme?.expensesFontColor
            cell.detailTextLabel?.textColor = theme?.expensesFontColor
            tableView.reloadData()
        }
    }
    
    func updateThemeFromUser() {
        theme = Theme.init(rawValue: defaults.integer(forKey: "theme"))
        updateTheme()
    }
    
    func updateTheme(){
        view.layer.backgroundColor = theme?.applicationBackgroundColor
        bottomColorView.layer.backgroundColor = theme?.totalCostViewColor
        addBarButton.image = theme?.addBarButtonImage
        removeExpenseButton.backgroundColor = theme?.deleteButtonColor
        removeExpenseButton.setTitleColor(theme?.deleteButtonTextColor, for: .normal)
        tableView.layer.backgroundColor = theme?.applicationBackgroundColor
        tableView.reloadData()
//        self.view.willRemoveSubview(dimBackgroundView)
//        dimBackgroundView.removeFromSuperview()
        
        switch theme?.rawValue {
            case 0: return (navigationController?.navigationBar.barStyle = .default)!
            case 1: return (navigationController?.navigationBar.barStyle = .black)!
            default: return (navigationController?.navigationBar.barStyle = .default)!
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
    
    //MARK: - Add Settings View to bottom of screen
    func addSettingsView(){
        settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        if let settingsVC = settingsVC {
            
            self.addChildViewController(settingsVC)
            self.view.addSubview(settingsVC.view)
            settingsVC.didMove(toParentViewController: self)
            
            let height = view.frame.height
            let width = view.frame.width
            settingsVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
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
            expenseArray.remove(at: expenseArray.index(of: $0)!)
        }
        tableView.deleteRows(at: indexPathsForSelectedRows, with: .fade)
        if tableView.isEditing == true, tableView.indexPathsForSelectedRows == nil {
            removeExpenseConstraint.constant = -82
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - Set Table View to Edit Mode
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if (self.tableView.isEditing == true) {
//            self.tableView.setEditing(false, animated: true)
            self.editBarButton.title = "Edit"
            self.navigationItem.rightBarButtonItem = self.addBarButton
            removeExpenseConstraint.constant = -82
            context.rollback()
            expenseArray = editModeExpenseArray
            if let totalCostVC = totalCostVC {
                totalCostVC.expenseArray = expenseArray
                totalCostVC.moveUp()
                totalCostVC.updateLabels()
            }
            let indexSet = IndexSet.init(integer: 0)
            tableView.reloadSections(indexSet, with: .right)
            //tableView.reloadData()      //Causing issues with the setEditing animation
            self.tableView.setEditing(false, animated: false)
            bottomColorView.isHidden = false
        } else if (self.tableView.isEditing == false) {
            self.tableView.setEditing(true, animated: true)
            self.editBarButton.title = "Cancel"
            editModeExpenseArray = expenseArray
            self.navigationItem.rightBarButtonItem = doneBarButton
            if let totalCostVC = totalCostVC {
                totalCostVC.moveDown()
            }
            bottomColorView.isHidden = true
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

    }
    
    @objc func doneBarButtonPressed(){
        saveExpenses()
        self.tableView.setEditing(false, animated: true)
        self.editBarButton.title = "Edit"
        self.navigationItem.rightBarButtonItem = self.addBarButton
        removeExpenseConstraint.constant = -82
        checkExpenseArray()
        if let totalCostVC = totalCostVC {
            totalCostVC.moveUp()
            totalCostVC.updateLabels()
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
                destinationVC.theme = theme
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
                destinationVC.theme = theme
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
    
    //MARK: - Bring Up Settings View
    func showSettingsView() {
        if let settingsVC = settingsVC {
            settingsVC.moveUp()
        }
    }
    
    //Set Theme from Settings View
    func updateUserTheme() {
        let rawValue = defaults.integer(forKey: "SelectedTheme")
        theme = Theme.init(rawValue: rawValue)
        updateTheme()
        if let totalCostVC = totalCostVC {
            totalCostVC.theme = theme
            totalCostVC.updateTheme()
        }
    }
    
    func darkenView(){
        //view.insertSubview(dimBackgroundView, at: 2)
        //self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
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
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        cell.tintColor = #colorLiteral(red: 0.46, green: 0.29, blue: 0.96, alpha: 1)
        cell.textLabel?.textColor = theme?.expensesFontColor
        cell.detailTextLabel?.textColor = theme?.expensesFontColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing != true,
            let cell = tableView.cellForRow(at: indexPath) {
            let backgroundView = UIView(), holderView = UIView()
            backgroundView.backgroundColor = theme?.selectedExpenseColor
            backgroundView.frame = CGRect(x: 8, y: 0, width: cell.frame.width - 16, height: cell.frame.height)
            backgroundView.layer.cornerRadius = 10
            holderView.addSubview(backgroundView)
            cell.selectedBackgroundView = holderView
            cell.backgroundView = holderView
            cell.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.textLabel?.textColor = theme?.selectedExpenseFontColor
            cell.detailTextLabel?.textColor = theme?.selectedExpenseFontColor
            DispatchQueue.main.async() { () -> Void in
                self.performSegue(withIdentifier: "goToEditExpense", sender: self)
            }
        } else {
            removeExpenseConstraint.constant = 9
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true, tableView.indexPathsForSelectedRows == nil {
            removeExpenseConstraint.constant = -82
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
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
        //saveExpenses()
    }
}

