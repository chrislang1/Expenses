//
//  AddExpenseViewController.swift
//  Subscriptions
//
//  Created by Chris Lang on 1/6/18.
//  Copyright © 2018 Chris Lang. All rights reserved.
//

import UIKit

protocol NewExpenseDelegate {
    func addNewExpense(name: String, cost: Double, numberOfPeriods: Double, periodLength: Int)
}

protocol EditExpenseDelegate{
    func updateExpense(expense: Expense)
    func deleteExpense(expense: Expense)
}

class AddExpenseViewController: UIViewController {
    
    var delegate: NewExpenseDelegate?
    var delegate2: EditExpenseDelegate?
    var selectedExpense: Expense?
    
    var identifyingSegue = String()
    var theme = Theme.init(rawValue: 0) // set in userDefaults

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    
    @IBOutlet weak var deleteExpenseButton: UIButton!
    @IBOutlet weak var billingPeriodLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var customPickerTextField: UITextField! // Invisible text field to cause picker view to present modally
    let customPeriodPickerView = UIPickerView()
    @IBOutlet weak var customPeriodLabel: UILabel!
    
    var periodSelected = false
    var numberOfPeriods = Int()
    var periodLength = String()
    var buttonString = String()
    var periodType = Expense.PeriodType(rawValue: 0)
    
    let textColor = #colorLiteral(red: 0.5377323031, green: 0.4028604627, blue: 0.9699184299, alpha: 1)
    let backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.2862745098, blue: 0.9607843137, alpha: 0.2)
    
    @IBOutlet var periodButtons: [UIButton]!
    
    let periodLengthArray = ["Day(s)", "Week(s)", "Fortnight(s)", "Month(s)", "Year(s)"]
    let numberArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Delegates and DataSource to self
        self.customPeriodPickerView.delegate = self
        self.customPeriodPickerView.dataSource = self
        self.customPickerTextField.delegate = self
        self.nameTextField.delegate = self
        
        //Remove Navigation Bar Border
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //Update all items to selected theme
        updateTheme()
        
        //Set Button Font
        let fontStyle = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        cancelButton.setTitleTextAttributes([NSAttributedStringKey.font: fontStyle], for: .normal)
        doneButton.setTitleTextAttributes([NSAttributedStringKey.font: fontStyle, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.514, green: 0.5137254902, blue: 0.5294117647, alpha: 0.5)], for: .disabled)
        doneButton.tintColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5294117647, alpha: 0.5)
        
        //Run Setup
        nameTextField.layer.cornerRadius = 10
        costTextField.layer.cornerRadius = 10
        nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        costTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        customPeriodLabel.clipsToBounds = true
        customPeriodLabel.layer.cornerRadius = 10
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        costTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        deleteExpenseButton.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        if identifyingSegue == "goToEditExpense",
            let selectedExpense = selectedExpense
        {
            nameTextField.text = selectedExpense.name
            costTextField.text = String(selectedExpense.price)
            
            self.title = "Edit Expense"
            
            if let periodType = Expense.PeriodType(rawValue: Int(selectedExpense.periodType)){
                self.periodType = periodType
                if(Int(selectedExpense.periodLength) == 1 && periodType != .year) {
                    periodSelected(periodButtons[periodType.rawValue])
                } else {
                    customPeriodLabel.backgroundColor = theme?.selectedButtonColor
                    customPeriodLabel.textColor = theme?.selectedButtonTextColor
                    //selectedPeriod = 4
                    numberOfPeriods = numberArray[Int(selectedExpense.periodLength - 1)]
                    
                    periodLength = periodType.description
                    buttonString = "Every \(numberOfPeriods) \(periodLength)"
                    customPeriodLabel.text = buttonString
                    customPeriodPickerView.selectRow(numberOfPeriods-1, inComponent: 1, animated: true)
                    customPeriodPickerView.selectRow(periodType.rawValue, inComponent: 2, animated: true)
                }
            }
            deleteExpenseButton.isHidden = false
        }
        
        let locale = Locale.current
        let currencySymbol = locale.currencySymbol!
        let currencyCode = locale.currencyCode!
        
        costTextField.attributedPlaceholder = NSAttributedString(string: "Cost in \(currencySymbol)\(currencyCode)", attributes: [NSAttributedStringKey.foregroundColor: theme?.choosePeriodLabelColor ?? UIColor.lightGray])
        checkDoneButton()
    }
    
    func updateTheme(){
        view.layer.backgroundColor = theme?.applicationBackgroundColor
        //Color Buttons for Theme
        for index in periodButtons.indices {
            periodButtons[index].backgroundColor = theme?.buttonColor
            periodButtons[index].setTitleColor(theme?.expensesFontColor, for: .normal)
        }
        customPeriodLabel.backgroundColor = theme?.buttonColor
        customPeriodLabel.textColor = theme?.expensesFontColor
        customPeriodPickerView.layer.backgroundColor = theme?.totalCostViewColor
        nameTextField.layer.backgroundColor = theme?.textFieldColor
        costTextField.layer.backgroundColor = theme?.textFieldColor
        nameTextField.textColor = theme?.expensesFontColor
        costTextField.textColor = theme?.expensesFontColor
        billingPeriodLabel.textColor = theme?.choosePeriodLabelColor
        deleteExpenseButton.backgroundColor = theme?.deleteButtonColor
        deleteExpenseButton.setTitleColor(theme?.deleteButtonTextColor, for: .normal)
        addDoneButtonOnKeyboard()
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Expense Name", attributes: [NSAttributedStringKey.foregroundColor: theme?.choosePeriodLabelColor ?? UIColor.lightGray])
        
        switch theme?.rawValue {
        case 0:
            (navigationController?.navigationBar.barStyle = .default)!
            nameTextField.keyboardAppearance = .default
            costTextField.keyboardAppearance = .default
            return
        case 1:
            (navigationController?.navigationBar.barStyle = .black)!
            nameTextField.keyboardAppearance = .dark
            costTextField.keyboardAppearance = .dark
            return
        default:
            (navigationController?.navigationBar.barStyle = .default)!
            nameTextField.keyboardAppearance = .default
            costTextField.keyboardAppearance = .default
            return
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        checkDoneButton()
    }
    
    func checkDoneButton(){
        let fontStyle = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        if periodSelected == true && nameTextField.text?.isEmpty == false && costTextField.text?.isEmpty == false {
            doneButton.setTitleTextAttributes([NSAttributedStringKey.font: fontStyle, NSAttributedStringKey.foregroundColor: theme?.doneKeyboardButtonColor ?? #colorLiteral(red: 0.5377323031, green: 0.4028604627, blue: 0.9699184299, alpha: 1)], for: .normal)
            doneButton.tintColor = theme?.doneKeyboardButtonColor ?? #colorLiteral(red: 0.5377323031, green: 0.4028604627, blue: 0.9699184299, alpha: 1)
            doneButton.isEnabled = true
        } else {
            doneButton.setTitleTextAttributes([NSAttributedStringKey.font: fontStyle, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.514, green: 0.5137254902, blue: 0.5294117647, alpha: 0.5)], for: .disabled)
            doneButton.tintColor = #colorLiteral(red: 0.5137254902, green: 0.5137254902, blue: 0.5294117647, alpha: 0.5)
            doneButton.isEnabled = false
        }
    }
    
    //MARK: - Dismiss Keyboard
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //MARK: - Selected Buttons
    @IBAction func periodSelected(_ sender: UIButton) {
        let selectedPeriod = periodButtons.index(of: sender)!
            for index in periodButtons.indices {
                if index == selectedPeriod {
                    periodButtons[index].backgroundColor = theme?.selectedButtonColor
                    periodButtons[index].setTitleColor(theme?.selectedButtonTextColor, for: .normal)
                } else {
                    periodButtons[index].backgroundColor = theme?.buttonColor
                    periodButtons[index].setTitleColor(theme?.expensesFontColor, for: .normal)
                }
            }
        periodType = Expense.PeriodType(rawValue: selectedPeriod)
        
//        if selectedPeriod != nil {
//            periodType = Expense.PeriodType(rawValue: selectedPeriod!)
//        } else {
//            print("no period selected")
//        }
        
        numberOfPeriods = 1
        periodSelected = true
        
        customPeriodLabel.backgroundColor = theme?.buttonColor
        customPeriodLabel.textColor = theme?.expensesFontColor
        customPeriodLabel.text = "Custom Period"
        self.view.endEditing(true)
        checkDoneButton()
    }
    
    //MARK: - Toolbar Methods
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:44))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.keyboardDoneButtonAction))
        done.tintColor = theme?.doneKeyboardButtonColor
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        doneToolbar.barTintColor = theme?.doneToolBarColor
        self.costTextField.inputAccessoryView = doneToolbar
        self.customPickerTextField.inputView = customPeriodPickerView
        self.customPickerTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func keyboardDoneButtonAction() {
        if costTextField.isFirstResponder == true {
            self.costTextField.resignFirstResponder()
        } else if customPickerTextField.isFirstResponder == true {
            self.customPickerTextField.resignFirstResponder()
        }
        checkDoneButton()
    }
    
    //MARK: - Navigation Buttons
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Update Expense Method
    func updateExpense(){
        selectedExpense?.name = nameTextField.text
        selectedExpense?.price = Double(costTextField.text!)!
        selectedExpense?.periodLength = Double(numberOfPeriods)

        guard let periodLengthPosition = periodLengthArray.index(of: (periodType?.description)!) else {return}
        selectedExpense?.periodType = Int16(periodLengthPosition)
    }
    
    //MARK: - Done Button Method
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        if periodSelected == false || nameTextField.text?.isEmpty == true || costTextField.text?.isEmpty == true {
            let alert = UIAlertController(title: "Expense Incomplete", message: "Please provide details for all fields.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            //2 If we have a delegate set, call the delegate protocol method
            if identifyingSegue == "goToAddExpense"{
                delegate?.addNewExpense(name: nameTextField.text!, cost: Double(costTextField.text!)!, numberOfPeriods: Double(numberOfPeriods), periodLength: (periodType?.rawValue)!)
            } else if identifyingSegue == "goToEditExpense" {
                updateExpense()
                delegate2?.updateExpense(expense: selectedExpense!)
            }
            
            //3 dismiss the New Container View Controller to go back to the ContainerList
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate2?.deleteExpense(expense: selectedExpense!)
        dismiss(animated: true, completion: nil)
    }

}

//MARK: - PickerView Delegate and Data Source Methods
extension AddExpenseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(component) {
        case 0:
            return 1;
        case 1:
            return numberArray.count;
        case 2:
            return periodLengthArray.count;
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString!
        
        switch(component){
        case 0:
            attributedString = NSAttributedString(string: "Every", attributes: [NSAttributedStringKey.foregroundColor: theme?.expensesFontColor ?? .black])
        case 1:
            attributedString = NSAttributedString(string: String(numberArray[row]), attributes: [NSAttributedStringKey.foregroundColor: theme?.expensesFontColor ?? .black])
        case 2:
            attributedString = NSAttributedString(string: periodLengthArray[row], attributes: [NSAttributedStringKey.foregroundColor: theme?.expensesFontColor ?? .black])
        default:
            attributedString = nil
        }
        return attributedString
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            numberOfPeriods = numberArray[row]
        } else if component == 2 {
            periodLength = periodLengthArray[row]
        }
        buttonString = "Every \(numberOfPeriods) \(periodLength)"
        var periodLengthTransform = periodLength.lowercased()
        let endIndex = periodLengthTransform.index(periodLengthTransform.endIndex, offsetBy: -3)
        periodLengthTransform = periodLengthTransform.substring(to: endIndex)
        periodType = Expense.PeriodType(typeString: periodLengthTransform)
        customPeriodLabel.text = buttonString
        periodSelected = true
        checkDoneButton()
    }
}

//MARK: - Text Field Delegate Methods
extension AddExpenseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField == customPickerTextField {
            for index in periodButtons.indices {
                periodButtons[index].backgroundColor = theme?.buttonColor
                periodButtons[index].setTitleColor(theme?.expensesFontColor, for: .normal)
            }
            customPeriodLabel.backgroundColor = theme?.selectedButtonColor
            customPeriodLabel.textColor = theme?.selectedButtonTextColor
            
            if customPeriodLabel.text == "Custom Period"{
                numberOfPeriods = numberArray[0]
                periodLength = periodLengthArray[0]
            }
            buttonString = "Every \(numberOfPeriods) \(periodLength)"
            customPeriodLabel.text = buttonString
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkDoneButton()
        return true
    }
}
