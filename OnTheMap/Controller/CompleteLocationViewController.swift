//
//  CompleteLocationViewController.swift
//  OnTheMap
//
//  Created by Garima Bothra on 25/05/20.
//  Copyright © 2020 Garima Bothra. All rights reserved.
//

import UIKit
import MapKit
class CompleteLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var placemark: CLPlacemark?
    var mediaUrl: String?
    var locationText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let placemark = placemark else {
            return
        }
        
        setAnnotation(placemark: placemark)

        self.mapView.delegate = self
    }
    
    func setAnnotation(placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else {
            return
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(placemark.name ?? ""), \(placemark.country ?? "")"
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    // MARK: Following will set the region, to focus on the map where the annotation placed.
    func setRegion(with placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else {
            return
        }
        let userLocation: CLLocationCoordinate2D = coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: userLocation, span: span)
        
        DispatchQueue.main.async {
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func finishClicked(_ sender: Any) {
        guard let coordinate = placemark?.location?.coordinate else {
            return
        }
        
        let userLocationRequest = AddLocationRequest(uniqueKey: ClientAPI.Auth.userId, firstName: ClientAPI.Auth.userFirstName, lastName: ClientAPI.Auth.userLastName, mapString: locationText ?? "", mediaURL: mediaUrl ?? "", latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        if StudentModel.userObjectId == nil {
            ClientAPI.addLocation(userLocationRequest: userLocationRequest, completion: handleUserLocationResponse(success:error:))
        } else {
            ClientAPI.updateLocation(userLocationRequest: userLocationRequest, completion: handleUserLocationResponse(success:error:))
        }

    }
    
    func handleUserLocationResponse(success: Bool, error: Error?) {
        
        if success {
            navigateToTabBarViewController()
        } else {
            AppUtil.showError(viewController: self, title: "Add Location Error", message: error?.localizedDescription ?? "")
        }
    }
    
    @IBAction func backNavigationClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func navigateToTabBarViewController() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension CompleteLocationViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .roundedRect)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
