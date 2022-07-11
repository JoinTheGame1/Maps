//
//  MapViewController.swift
//  Maps
//
//  Created by Никитка on 06.07.2022.
//

import UIKit
import GoogleMaps
import SnapKit

class MapViewController: UIViewController {
    
    private var viewModel: MapViewModel?
    private var locationManager: CLLocationManager?
    private var manualMarker: GMSMarker?
    private let mapView: GMSMapView = {
        let map = GMSMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    lazy var trackButton: UIButton = makeTrackButton()
    lazy var showLastRouteButton: UIButton = makeShowLastRouteButton()
    lazy var currentLocationButton: UIButton = makeCurrentLocationButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupViews()
        configureLocationManager()
    }
    
    @objc func trackButtonAction() {
        self.viewModel?.trackButtonTapped()
    }
    
    @objc func showLastRouteButtonAction() {
        self.viewModel?.showLastRouteButtonTapped()
    }
    
    @objc func showCurrentLocation() {
        self.viewModel?.showCurrentLocation?()
    }
    
    private func setupViewModel() {
        viewModel = MapViewModel()
        guard let viewModel = viewModel else { return }

        viewModel.startUpdatingLocation = { [weak self] in
            self?.locationManager?.startUpdatingLocation()
        }
        viewModel.stopUpdatingLocation = { [weak self] in
            self?.locationManager?.stopUpdatingLocation()
        }
        viewModel.showCurrentLocation = { [weak self] in
            self?.locationManager?.requestLocation()
        }
        viewModel.showError = { [weak self] message in
            self?.showError(message: message)
        }
        viewModel.addRouteToMap = { [weak self] route in
            route?.map = self?.mapView
        }
        viewModel.trackButtonAnimate = { [weak self] model in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.trackButton.setTitle(model.isTracking ? "Stop tracking" : "Start tracking", for: .normal)
                self.trackButton.backgroundColor = model.isTracking ? .systemRed : .systemGreen
            }
        }
        viewModel.showLastRouteButtonAnimate = { [weak self] model in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5) {
                self.showLastRouteButton.setTitle(model.isShowingLastRoute ? "Close last route" : "Show last route",
                                                  for: .normal)
            }
        }
        viewModel.showTrackAlert = { [weak self] in
            self?.showTrackAlert()
        }
        viewModel.moveCameraToRoute = { [weak self] firstPoint, lastPoint in
            let bounds = GMSCoordinateBounds(coordinate: firstPoint, coordinate: lastPoint)
            let cameraUpdate = GMSCameraUpdate.fit(bounds)
            self?.mapView.moveCamera(cameraUpdate)
        }
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(trackButton)
        view.addSubview(showLastRouteButton)
        view.addSubview(currentLocationButton)
        setupMap()
        
        trackButton.addTarget(self, action: #selector(trackButtonAction), for: .touchUpInside)
        showLastRouteButton.addTarget(self, action: #selector(showLastRouteButtonAction), for: .touchUpInside)
        currentLocationButton.addTarget(self, action: #selector(showCurrentLocation), for: .touchUpInside)
        
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
    
    private func setupMap() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        viewModel?.setupRoutePath()
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
            self.viewModel?.trackButtonTapped()
            self.viewModel?.loadRoute()
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
        guard let coordinate = locations.last?.coordinate else { return }
        let position = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
        mapView.animate(to: position)
        self.viewModel?.updateLocations(coordinate: coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: error.localizedDescription)
    }
}
