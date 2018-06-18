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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    
    @IBOutlet weak var deleteExpenseButton: UIButton!
    
    @IBOutlet weak var customPickerTextField: UITextField! // Invisible text field to cause picker view to present modally
    let customPeriodPickerView = UIPickerView()
    @IBOutlet weak var customPeriodLabel: UILabel!
    
    var selectedPeriod: Int?
    var numberOfPeriods = Int()
    var periodLength = String()
    var buttonString = String()
    var periodTypeEnum = Expense.PeriodType(rawValue: 0)
    
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
        
        //Run Setup
        nameTextField.layer.cornerRadius = 10
        costTextField.layer.cornerRadius = 10
        nameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        costTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
        customPeriodLabel.clipsToBounds = true
        customPeriodLabel.layer.cornerRadius = 10
        customPeriodPickerView.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        addDoneButtonOnKeyboard()
        deleteExpenseButton.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        if identifyingSegue == "goToEditExpense",
            let selectedExpense = selectedExpense
        {
            nameTextField.text = selectedExpense.name
            costTextField.text = String(selectedExpense.price)
            
            periodTypeEnum = Expense.PeriodType(rawValue: Int(selectedExpense.periodType))
            
            if(selectedExpense.periodLength == 1 && periodTypeEnum?.rawValue != 4) {
                guard let selectedPeriod = periodTypeEnum?.rawValue else {return}
                periodSelected(periodButtons[selectedPeriod])
            } else {
                customPeriodLabel.backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
                customPeriodLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1)
                selectedPeriod = 4
                numberOfPeriods = numberArray[Int(selectedExpense.periodLength - 1)]
                
                guard let periodLengthPosition = periodLengthArray.index(of: (periodTypeEnum?.description)!) else {return}
                periodLength = periodLengthArray[periodLengthPosition]
                buttonString = "Every \(numberOfPeriods) \(periodLength)"
                customPeriodLabel.text = buttonString
                customPeriodPickerView.selectRow(numberOfPeriods-1, inComponent: 1, animated: true)
                customPeriodPickerView.selectRow(periodLengthPosition, inComponent: 2, animated: true)
            }
            deleteExpenseButton.isHidden = false
        }
        
        let locale = Locale.current
        let currencySymbol = locale.currencySymbol!
        let currencyCode = locale.currencyCode!
        
        costTextField.placeholder = "Cost in \(currencySymbol)\(currencyCode)"
        
    }
    
    //MARK: - Dismiss Keyboard
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //MARK: - Selected Buttons
    @IBAction func periodSelected(_ sender: UIButton) {
        selectedPeriod = periodButtons.index(of: sender)!
            for index in periodButtons.indices {
                if index == selectedPeriod {
                    periodButtons[index].backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
                    periodButtons[index].setTitleColor(#colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1), for: .normal)
                } else {
                    periodButtons[index].backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
                    periodButtons[index].setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                }
            }
        
        if selectedPeriod != nil {
            periodTypeEnum = Expense.PeriodType(rawValue: selectedPeriod!)
        } else {
            print("no period selected")
        }
        
        numberOfPeriods = 1
        
        customPeriodLabel.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
        customPeriodLabel.textColor = .black
        customPeriodLabel.text = "Custom Period"
        self.view.endEditing(true)
    }
    
    //MARK: - Toolbar Methods
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0, width:320, height:44))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.barTintColor = #colorLiteral(red: 0.7764705882, green: 0.7960784314, blue: 0.831372549, alpha: 1)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.keyboardDoneButtonAction))
        done.tintColor = #colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.costTextField.inputAccessoryView = doneToolbar
        doneToolbar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.customPickerTextField.inputView = customPeriodPickerView
        self.customPickerTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func keyboardDoneButtonAction()
    {
        if costTextField.isFirstResponder == true {
            self.costTextField.resignFirstResponder()
        } else if customPickerTextField.isFirstResponder == true {
            selectedPeriod = 4
            self.customPickerTextField.resignFirstResponder()
        }
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

        guard let periodLengthPosition = periodLengthArray.index(of: (periodTypeEnum?.description)!) else {return}
        selectedExpense?.periodType = Int16(periodLengthPosition)
    }
    
    //MARK: - Done Button Method
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        if selectedPeriod == nil || nameTextField.text?.isEmpty == true || costTextField.text?.isEmpty == true {
            let alert = UIAlertController(title: "Expense Incomplete", message: "Please provide details for all fields.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        } else {
            //2 If we have a delegate set, call the delegate protocol method
            if identifyingSegue == "goToAddExpense"{
                delegate?.addNewExpense(name: nameTextField.text!, cost: Double(costTextField.text!)!, numberOfPeriods: Double(numberOfPeriods), periodLength: (periodTypeEnum?.rawValue)!)
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(component) {
        case 0:
            return "Every";
        case 1:
            return String(numberArray[row]);
        case 2:
            return periodLengthArray[row];
        default:
            return ""
        }
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
        periodTypeEnum = Expense.PeriodType(typeString: periodLengthTransform)
        customPeriodLabel.text = buttonString
    }
}

//MARK: - Text Field Delegate Methods
extension AddExpenseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField == customPickerTextField {
            for index in periodButtons.indices {
                periodButtons[index].backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 0.9647058824, alpha: 1)
                periodButtons[index].setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            }
            customPeriodLabel.backgroundColor = UIColor(red: 0.61, green: 0.32, blue: 0.88, alpha: 0.2)
            customPeriodLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.3176470588, blue: 0.8784313725, alpha: 1)
            
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
        return true
    }
}
