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
    
    var viewModel: MapViewModel
    private var locationManager: CLLocationManager?
    private var manualMarker: GMSMarker?
    private let mapView: GMSMapView = {
        let map = GMSMapView()
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    lazy var bottomView: BottomView = makeBottomView()
    lazy var currentLocationButton: UIButton = makeCurrentLocationButton()
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupUI()
        configureLocationManager()
    }
    
    @objc private func trackButtonAction() {
        self.viewModel.trackButtonTapped()
    }
    
    @objc private func showLastRouteButtonAction() {
        self.viewModel.showLastRouteButtonTapped()
    }
    
    @objc private func showCurrentLocation() {
        self.viewModel.showCurrentLocation?()
    }
    
    private func setupViewModel() {
        bottomView.viewModel = self.viewModel
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
        viewModel.showTrackAlert = { [weak self] in
            self?.showTrackAlert()
        }
        viewModel.moveCameraToRoute = { [weak self] firstPoint, lastPoint in
            let bounds = GMSCoordinateBounds(coordinate: firstPoint, coordinate: lastPoint)
            let cameraUpdate = GMSCameraUpdate.fit(bounds)
            self?.mapView.moveCamera(cameraUpdate)
        }
    }
    
    private func setupUI() {
        view.addSubview(mapView)
        view.addSubview(bottomView)
        view.addSubview(currentLocationButton)
        setupMap()
        
        currentLocationButton.addTarget(self, action: #selector(showCurrentLocation), for: .touchUpInside)
        
        mapView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        bottomView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(-bottomView.cornerRadius)
            make.height.equalTo(self.view.frame.height / 8)
        }
        currentLocationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(80)
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
    }
    
    private func setupMap() {
        mapView.delegate = self
        viewModel.setupRoutePath()
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
            self.viewModel.trackButtonTapped()
            self.viewModel.loadRoute()
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
        self.viewModel.updateLocations(coordinate: coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: error.localizedDescription)
    }
}
