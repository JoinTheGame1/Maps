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
    var manualMarker: GMSMarker?
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    private let mapView: GMSMapView = {
        let map = GMSMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private let startNewTrackButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .link
        button.setTitle("Начать новый трек", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let stopTrackButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .link
        button.setTitle("Закончить трек", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let showLastTrackButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .link
        button.setTitle("Показать последний маршрут", for: .normal)
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
    
    @objc func startTrack() {
        route = GMSPolyline()
        routePath = GMSMutablePath()
        route?.map = mapView
        locationManager?.startUpdatingLocation()
        UIView.animate(withDuration: 0) {
            self.startNewTrackButton.isHidden = true
            self.stopTrackButton.isHidden = false
        }
    }
    
    @objc func stopTrack() {
        route?.map = nil
        routePath = nil
        UIView.animate(withDuration: 0) {
            self.startNewTrackButton.isHidden = false
            self.stopTrackButton.isHidden = true
        }
    }
    
    @objc func currentLocation() {
        locationManager?.requestLocation()
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(startNewTrackButton)
        view.addSubview(stopTrackButton)
        view.addSubview(showLastTrackButton)
        view.addSubview(currentLocationButton)
        
        startNewTrackButton.addTarget(self, action: #selector(startTrack), for: .touchUpInside)
        stopTrackButton.addTarget(self, action: #selector(stopTrack), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(currentLocation), for: .touchUpInside)
        
        stopTrackButton.isHidden = true
        
        mapView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        startNewTrackButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.equalTo(view.snp.width).multipliedBy(0.45)
        }
        stopTrackButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.equalTo(view.snp.width).multipliedBy(0.45)
        }
        showLastTrackButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(32)
        }
        currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(80)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
    }
    
    private func configureMap() {
        let coordinate = CLLocationCoordinate2D(latitude: 55.753215, longitude: 37.622504)
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestWhenInUseAuthorization()
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let marker = manualMarker {
            marker.position = coordinate
        } else {
            let marker = GMSMarker(position: coordinate)
            marker.map = mapView
            manualMarker = marker
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        routePath?.add(location.coordinate)
        route?.path = routePath
        
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
        print(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
