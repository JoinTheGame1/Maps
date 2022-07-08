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
    
    private let realmService = RealmService.shared
    private var locationManager: CLLocationManager?
    private var manualMarker: GMSMarker?
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var lastRoute: [CLLocationCoordinate2D] = []
    private var isTracking: Bool = false
    private var isShowingLastRoute: Bool = false
    
    private let mapView: GMSMapView = {
        let map = GMSMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    private let trackButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.setTitle("Start tracking", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let showLastRouteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .link
        button.setTitle("Show last route", for: .normal)
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
        configureLocationManager()
        setupMap()
    }
    
    @objc func trackButtonAction() {
        if isTracking {
            saveRoute()
        } else {
            showLastRouteButtonAction()
            locationManager?.startUpdatingLocation()
        }
        isTracking.toggle()
        UIView.animate(withDuration: 0.5) {
            self.trackButton.setTitle(self.isTracking ? "Stop tracking" : "Start tracking",
                                      for: .normal)
            self.trackButton.backgroundColor = self.isTracking ? .systemRed : .systemGreen
        }
    }
    
    private func saveRoute() {
        route?.map = nil
        locationManager?.stopUpdatingLocation()
        
        guard let path = route?.path else { return }

        var coordinates: [Location] = []
        for i in 0..<path.count() {
            let coordinate = path.coordinate(at: i)
            let location = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
            coordinates.append(location)
        }
        realmService.saveRoute(route: coordinates)
    }
    
    private func loadRoute() {
        guard let route = realmService.loadRoute() else { return }
        
        let lastRouteLocation = Array(route)
        self.lastRoute = lastRouteLocation
            .compactMap({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        
        guard !self.lastRoute.isEmpty,
              let firstPoint = self.lastRoute.first,
              let lastPoint = self.lastRoute.last
        else {
            showError(message: "Previous route not found ;(")
            return
        }
        
        setupRoutePath()
        self.lastRoute.forEach { point in
            self.routePath?.add(point)
            self.route?.path = self.routePath
        }
        
        let bounds = GMSCoordinateBounds(coordinate: firstPoint, coordinate: lastPoint)
        let cameraUpdate = GMSCameraUpdate.fit(bounds)
        mapView.moveCamera(cameraUpdate)
    }
    
    @objc private func showLastRouteButtonAction() {
        if isShowingLastRoute {
            setupRoutePath()
            currentLocation()
        } else {
            if isTracking {
                showTrackAlert()
            } else {
                loadRoute()
            }
        }
        
        isShowingLastRoute.toggle()
        UIView.animate(withDuration: 0.5) {
            self.showLastRouteButton.setTitle(self.isShowingLastRoute ? "Close last route" : "Show last route",
                                      for: .normal)
        }
    }
    
    @objc func currentLocation() {
        locationManager?.requestLocation()
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(trackButton)
        view.addSubview(showLastRouteButton)
        view.addSubview(currentLocationButton)
        
        trackButton.addTarget(self, action: #selector(trackButtonAction), for: .touchUpInside)
        showLastRouteButton.addTarget(self, action: #selector(showLastRouteButtonAction), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(currentLocation), for: .touchUpInside)
        
        mapView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        trackButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.equalTo(view.snp.width).multipliedBy(0.45)
        }
        showLastRouteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.equalTo(view.snp.width).multipliedBy(0.45)
        }
        currentLocationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(80)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
    }
    
    private func setupRoutePath() {
        route?.map = nil
        routePath = nil
        routePath = GMSMutablePath()
        route = GMSPolyline(path: routePath)
        route?.map = mapView
        route?.strokeWidth = 5
    }
    
    private func setupMap() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        currentLocation()
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
    
    private func showTrackAlert() {
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.trackButtonAction()
            self.loadRoute()
        }
        let alert = UIAlertController(title: "",
                                      message: """
                                      If you want to display the last route,
                                      need to stop track the current one
                                      """,
                                      preferredStyle: .alert)
        alert.addAction(okAction)
        present(alert, animated: true)
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
        
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        mapView.animate(to: position)
        if isTracking {
            self.routePath?.add(location.coordinate)
            self.route?.path = routePath
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: error.localizedDescription)
    }
}
