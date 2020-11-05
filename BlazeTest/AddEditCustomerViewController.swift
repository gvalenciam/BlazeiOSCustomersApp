//
//  AddEditCustomerViewController.swift
//  BlazeTest
//
//  Created by Gerardo Valencia on 11/4/20.
//

import UIKit
import Alamofire

class AddEditCustomerViewController: UIViewController {
    
    @IBOutlet weak var firstNameInput  : UITextField!
    @IBOutlet weak var lastNameInput  : UITextField!
    @IBOutlet weak var emailInput  : UITextField!
    @IBOutlet weak var phoneInput  : UITextField!
    @IBOutlet weak var createUpdateButton  : UIButton!
    
    var isCustomerEditing = false
    var customer = NSDictionary()
    
    typealias addUpdateCompletion = () -> Void
    var addUpdateCompletion : addUpdateCompletion!
    
    @IBAction func addEditAction(_ sender: UIButton) {
        
        if (self.isCustomerEditing) {
            updateCustomer()
        } else {
            addCustomer()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissKeyboardGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardOnTap))
        self.view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeVisualComponents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func addCustomer() {
        let payload : Parameters = [
            "firstName": self.firstNameInput.text!,
            "lastName": self.lastNameInput.text!,
            "email": self.emailInput.text!,
            "phoneNumber": self.phoneInput.text!
        ]
        
        AF.request("http://192.168.0.6:3800/api/customers/", method: HTTPMethod.post, parameters: payload).responseJSON { response in
            self.addUpdateCompletion()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateCustomer() {
        let payload : Parameters = [
            "firstName": self.firstNameInput.text!,
            "lastName": self.lastNameInput.text!,
            "email": self.emailInput.text!,
            "phoneNumber": self.phoneInput.text!
        ]
        
        let customerID = self.customer["_id"] as! String
        
        AF.request("http://192.168.0.6:3800/api/customers/" + customerID, method: HTTPMethod.put, parameters: payload).responseJSON { response in
            self.addUpdateCompletion()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboardOnTap() {
        self.view.endEditing(true)
    }
    
    func initializeVisualComponents() {
        self.title = self.isCustomerEditing ? "UpdateCustomer" : "Add Customer"
        let inputBorderColor = UIColor.init(red: 227/255, green: 176/255, blue: 60/255, alpha: 1)
        let inputBorderWidth = CGFloat.init(1.5)
        let inputCornerRadius = CGFloat.init(7.5)
        self.firstNameInput.layer.borderColor = inputBorderColor.cgColor
        self.firstNameInput.layer.borderWidth = inputBorderWidth
        self.firstNameInput.layer.cornerRadius = inputCornerRadius
        self.firstNameInput.layer.masksToBounds = true
        self.lastNameInput.layer.borderColor = inputBorderColor.cgColor
        self.lastNameInput.layer.borderWidth = inputBorderWidth
        self.lastNameInput.layer.cornerRadius = inputCornerRadius
        self.lastNameInput.layer.masksToBounds = true
        self.emailInput.layer.borderColor = inputBorderColor.cgColor
        self.emailInput.layer.borderWidth = inputBorderWidth
        self.emailInput.layer.cornerRadius = inputCornerRadius
        self.emailInput.layer.masksToBounds = true
        self.phoneInput.layer.borderColor = inputBorderColor.cgColor
        self.phoneInput.layer.borderWidth = inputBorderWidth
        self.phoneInput.layer.cornerRadius = inputCornerRadius
        self.phoneInput.layer.masksToBounds = true
        self.createUpdateButton.setTitle(self.isCustomerEditing ? "Update" : "Create", for: UIControl.State.normal)
        self.createUpdateButton.layer.cornerRadius = inputCornerRadius
        
        if (self.isCustomerEditing) {
            self.firstNameInput.text = self.customer["firstName"] as? String
            self.lastNameInput.text = self.customer["lastName"] as? String
            self.emailInput.text = self.customer["email"] as? String
            self.phoneInput.text = self.customer["phoneNumber"] as? String
        } else {
            self.firstNameInput.text = ""
            self.lastNameInput.text = ""
            self.emailInput.text = ""
            self.phoneInput.text = ""
        }
    }

}
