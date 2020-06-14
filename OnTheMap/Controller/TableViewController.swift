//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Garima Bothra on 25/05/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    private func getStudentList() {
        ClientAPI.getStudents(completion: handleGetStudentsResponse(students:error:))
    }
    
    func handleGetStudentsResponse(students: [StudentInformation], error: Error?) {
        if error != nil {
            AppUtil.showError(viewController: self, title: "Get Students Error", message: error?.localizedDescription ?? "")
        } else {
            StudentModel.students = students
            reloadTable()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudentList()
    }
    
    private func reloadTable() {
        self.tableView.reloadData()
    }

    private func navigateToAddLocationViewController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") {
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        getStudentList()
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        ClientAPI.logout(completion: handleLogoutResponse(success:error:))
    }
    
    func handleLogoutResponse(success: Bool, error: Error?) {
        if (success) {
            self.dismiss(animated: true, completion: nil)
        } else {
            AppUtil.showError(viewController: self, title: "Logout Error", message: error?.localizedDescription ?? "")
        }
    }
    
    @IBAction func AddLocationClicked(_ sender: Any) {
        if StudentModel.userObjectId != nil {
            AppUtil.showYesCancelWithCompletion(viewController: self, title: "Confirm update?", message: "Confirm update current location?") { (success) in
                if success {
                    self.navigateToAddLocationViewController()
                }
            }
        } else {
            navigateToAddLocationViewController()
        }
    }
}


extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell")!
        
        let student = StudentModel.students[indexPath.row]
        let first = student.firstName
        let last = student.lastName
        cell.textLabel?.text = "\(first) \(last)"
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    
    fileprivate func openSelectedMediaUrl() {
        let student = StudentModel.students[selectedIndex]
        AppUtil.openUrl(viewController: self, url: student.mediaURL)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        openSelectedMediaUrl()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
