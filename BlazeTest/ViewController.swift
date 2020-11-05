//
//  ViewController.swift
//  BlazeTest
//
//  Created by Gerardo Valencia on 11/4/20.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var addEditCustomerVC : AddEditCustomerViewController!
    var addEditCustomerNC : UINavigationController!
    @IBOutlet weak var tableView  : UITableView!
    @IBAction func addCustomerAction(_ sender: UIBarButtonItem) {
        self.addEditCustomerVC.isCustomerEditing = false
        self.addEditCustomerVC.addUpdateCompletion = {() in
            self.totalCustomers += 1
            self.getAllCustomers()
        }
        self.navigationController?.present(self.addEditCustomerNC, animated: true, completion: nil)
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var customerList = NSMutableArray()
    var filteredCustomerList = NSArray()
    var isLoadingTableViewData = false
    var isTableViewFirstLoad = true
    var totalCustomers = 3
    var totalLoaded = 0
    var defaultOffset = 4
    var defaultLimit = 4
    var defaultPage = 1
    var totalOffset = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addEditCustomerVC = self.storyboard?.instantiateViewController(identifier: "addEditCustomerViewController")
        self.addEditCustomerNC = UINavigationController.init(rootViewController: self.addEditCustomerVC)
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search customers"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        getAllCustomers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getAllCustomers() {
        
        if (self.isTableViewFirstLoad) {
            
            let parameters : Parameters = [
                "offset": 0,
                "limit": self.defaultLimit
            ]
            
            AF.request("http://192.168.0.6:3800/api/customers", parameters: parameters).responseJSON{
                response in
                
                switch response.result {
                    case .failure(let error):
                        print(error)
                    case .success(let responseObject):
                        print(responseObject)
                        let responseList = (responseObject as! NSDictionary)["response"] as! NSDictionary
                        let customerResponseList = responseList["customers"]
                        self.totalCustomers = responseList["total"] as! Int
                        self.totalLoaded += (customerResponseList as! NSArray).count
                        self.totalOffset += self.defaultOffset
                        self.customerList.addObjects(from: customerResponseList as! [Any])
                        self.tableView.reloadData()
                }
                
                self.tableView.reloadData()
                self.isLoadingTableViewData = false
                self.isTableViewFirstLoad = false
                
            }
        } else {
            if (self.customerList.count <= self.totalCustomers) {
                
                let limitValue = (self.totalCustomers - self.totalLoaded) < self.defaultOffset ? (self.totalCustomers - self.totalLoaded) : self.defaultLimit
                
                let parameters : Parameters = [
                    "offset": self.totalOffset,
                    "limit": limitValue
                ]
                
                if (limitValue != 0) {
                    AF.request("http://192.168.0.6:3800/api/customers", parameters: parameters, encoding: URLEncoding.queryString).responseJSON{
                        response in
                        
                        switch response.result {
                            case .failure(let error):
                                print(error)
                            case .success(let responseObject):
                                print(responseObject)
                                let responseList = (responseObject as! NSDictionary)["response"] as! NSDictionary
                                let customerResponseList = responseList["customers"]
                                self.totalCustomers = responseList["total"] as! Int
                                self.totalLoaded += (customerResponseList as! NSArray).count
                                if (self.totalOffset <= self.totalCustomers) {self.totalOffset += limitValue}
                                self.customerList.addObjects(from: customerResponseList as! [Any])
                                self.tableView.reloadData()                    }
                        
                        self.tableView.reloadData()
                        self.isLoadingTableViewData = false
                        self.isTableViewFirstLoad = false
                    }
                }
                
            }
        }
        
    }
    
    func getCurrentLoadedCustomers() {
        
        self.customerList = []
        
        let parameters : Parameters = [
            "offset": 0,
            "limit": self.totalLoaded
        ]
        
        AF.request("http://192.168.0.6:3800/api/customers", parameters: parameters, encoding: URLEncoding.queryString).responseJSON {
            
            response in
            
            switch response.result {
                case .failure(let error):
                    print(error)
                case .success(let responseObject):
                    print(responseObject)
                    let responseList = (responseObject as! NSDictionary)["response"] as! NSDictionary
                    let customerResponseList = responseList["customers"]
                    self.customerList.addObjects(from: customerResponseList as! [Any])
                    self.tableView.reloadData()
                    
            }
            
            self.tableView.reloadData()
            self.isLoadingTableViewData = false
        }
         
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath) as! CustomerTableViewCell
        
        let dict: NSDictionary
        dict = customerList[indexPath.row] as! NSDictionary
        
        let firstName = dict["firstName"] as? String
        let lastName = dict["lastName"] as? String
        cell.nameLabel.text = firstName! + " " + lastName!
        cell.emailLabel.text = dict["email"] as? String
        cell.phoneLabel.text = dict["phoneNumber"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.addEditCustomerVC.isCustomerEditing = true
        let customerDict = customerList[indexPath.row] as? NSDictionary
        self.addEditCustomerVC.customer = customerDict!
        self.addEditCustomerVC.addUpdateCompletion = {() in
            self.getCurrentLoadedCustomers()
        }
        self.navigationController?.present(self.addEditCustomerNC, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if ((offsetY >= contentHeight - scrollView.frame.height) && !isLoadingTableViewData && !isTableViewFirstLoad) {
            print("Load more customers")
            isLoadingTableViewData = true
            getAllCustomers()
        }
        
        isTableViewFirstLoad = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        AF.request("http://192.168.0.6:3800/api/customers/" + searchBar.text!).responseJSON{
            response in
            
            switch response.result {
                case .failure(let error):
                    print(error)
                case .success(let responseObject):
                    let customerResponseList = (responseObject as! NSDictionary)["customers"] as! NSArray
                    self.customerList = customerResponseList.mutableCopy() as! NSMutableArray
                    self.totalOffset = 0
                    self.totalLoaded = 0
                    print("SEARCHED RESULTS")
                    print(self.customerList.count)
                    self.tableView.reloadData()
            }
        }
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.customerList = []
        getAllCustomers()
    }
    

}

