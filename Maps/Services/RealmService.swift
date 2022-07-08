//
//  RealmService.swift
//  Maps
//
//  Created by Никитка on 07.07.2022.
//

import RealmSwift

class RealmService {
    static let shared = RealmService()
    var realm = try? Realm(configuration: Realm.Configuration(deleteRealmIfMigrationNeeded: true))
    
    private init() {}
    
    func clearRoute() {
        guard let realm = self.realm else { return }
        
        let result = realm.objects(Location.self)
        do {
            try realm.write {
                realm.delete(result)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveRoute(route: [Location]) {
        guard let realm = self.realm else { return }
        clearRoute()
        do {
            try realm.write {
                realm.add(route)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadRoute() -> Results<Location>? {
        return realm?.objects(Location.self) ?? nil
    }
}
