//
//  MapViewController.swift
//  Maps
//
//  Created by Никитка on 06.07.2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import SnapKit

class MapViewController: UIViewController {
    
    var locationManager: CLLocationManager?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    private let mapView: GMSMapView = {
        let map = GMSMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private let trackLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .link
        button.setTitle("Отслеживать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "cursor"), for: .normal)
        button.tintColor = .link
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureMap()
        configureLocationManager()
    }
    
    @objc func trackLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    @objc func currentLocation() {
        locationManager?.requestLocation()
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(trackLocationButton)
        view.addSubview(currentLocationButton)
        
        trackLocationButton.addTarget(self, action: #selector(trackLocation), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(currentLocation), for: .touchUpInside)
        
        mapView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        trackLocationButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
    }
    
    private func configureMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
//        locationManager.allowsBackgroundLocationUpdates = true
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.first)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
