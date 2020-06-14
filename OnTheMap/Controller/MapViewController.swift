//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Garima Bothra on 25/05/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    func handleGetStudentsResponse(students: [StudentInformation], error: Error?) {
    
         if error != nil {
            AppUtil.showError(viewController: self, title: "Get Students Error", message: error?.localizedDescription ?? "")
        } else {
            StudentModel.students = students
            loadAnnotations()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getStudentsList()
    }
    
    private func getStudentsList() {
        ClientAPI.getStudents(completion: handleGetStudentsResponse(students:error:))
    }
    
    func loadAnnotations() {
        var annotations = [MKPointAnnotation]()
        
        for student in StudentModel.students {
            
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        if !self.mapView.annotations.isEmpty {
            self.mapView.removeAnnotations(mapView.annotations)
        }
        self.mapView.addAnnotations(annotations)
        self.mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    private func navigateToAddLocationViewController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") {
            self.navigationController?.show(vc, sender: nil)
        }
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        getStudentsList()
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

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            AppUtil.openUrl(viewController: self, url: view.annotation?.subtitle)
        }
    }
}
