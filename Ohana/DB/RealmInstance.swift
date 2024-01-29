//
//  RealmInstance.swift
//  Ludi Sports
//
//  Created by Charles Romeo on 4/24/23.
//

import Foundation
import RealmSwift

class RealmInstance {
    static let instance: Realm = {
        return try! Realm()
    }()
}

func realm() -> Realm {
    return RealmInstance.instance
}

func newRealm() -> Realm {
    return RealmInstance.instance
}

func isRealmObjectValid(_ object: Object) -> Bool {
    return !object.isInvalidated
}


func safeAccess<T>(to object: T, action: (T) -> Void) where T: Object {
    guard !object.isInvalidated else {
        print("Object is invalidated.")
        return
    }
    action(object)
}

extension Realm {
    
    // Queries
    func findByField<T: Object>(_ type: T.Type, field: String = "id", value: String?) -> T? {
        guard let value = value else { return nil }
        return objects(type).filter("\(field) == %@", value).first
    }
    
    func findAllByField<T: Object>(_ type: T.Type, field: String, value: Any) -> Results<T>? {
        return self.objects(type).filter("%K == %@", field, value)
    }
    
    func findAllNotByField<T: Object>(_ type: T.Type, field: String, value: Any) -> Results<T>? {
        return self.objects(type).filter("%K != %@", field, value)
    }

    
    //
    func executeWithRetry(maxRetries: Int = 3, operation: @escaping () -> Void) {
        func attempt(_ currentRetry: Int) {
            if isInWriteTransaction {
                if currentRetry < maxRetries {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        attempt(currentRetry + 1)
                    }
                } else {
                    print("Failed to execute operation after \(maxRetries) retries.")
                }
            } else {
                operation()
            }
        }

        attempt(0)
    }
    
    // Improved safeWrite method with error handling
    func safeWrite(_ block: @escaping (Realm) -> Void, completion: ((Bool) -> Void)? = nil) {
        // Ensure that the function is called on the correct thread
        guard let currentThreadRealm = try? Realm() else {
            print("Error while trying to safeWrite to Realm.")
            completion?(false)
            return
        }
        
        self.executeWithRetry {
            if currentThreadRealm.isInWriteTransaction {
                do {
                    try newRealm().write {
                        block(currentThreadRealm)
                    }
                    completion?(true)
                } catch {
                    print("Error while trying to safeWrite to Realm.")
                    completion?(false)
                }
            } else {
                do {
                    try currentThreadRealm.write {
                        block(currentThreadRealm)
                    }
                    completion?(true)
                } catch {
                    print("Error while trying to safeWrite to Realm.")
                    completion?(false)
                }
            }
        }

        
    }
    
    func safeWriteAsync(_ writeBlock: @escaping () -> Void) {
        // Dispatch to a background thread
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                do {
                    if self.isInWriteTransaction {
                        let realm = try Realm()
                        try realm.write {
                            writeBlock()
                        }
                    } else {
                        try self.write {
                            writeBlock()
                        }
                    }
                } catch {
                    print("Realm write error: \(error)")
                }
            }
        }
    }

}

extension Results {
    func toArray() -> [Element] {
        return Array(self)
    }
}

enum RealmError: Error {
    case invalidThread
}
extension Object {
    
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        let properties = self.objectSchema.properties.map { $0.name }
        
        for property in properties {
            if let value = dictionary[property] {
                self.setValue(value, forKey: property)
            }
        }
    }
    
    func toDict() -> [String: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var dictionary: [String: Any] = [:]
        for property in properties {
            dictionary[property] = self.value(forKey: property)
        }
        return dictionary
    }
    
    
    func isValid() -> Bool {
        return !self.isInvalidated
    }
    
    func update(block: @escaping (Realm) -> Void) {
        newRealm().safeWrite { r in
            block(r)
            r.invalidate()
        }
    }
    
}


// Realm listener
class RealmObserver<T:Object>: ObservableObject {
    @Published var realmInstance: Realm = newRealm()
    @Published var notificationToken: NotificationToken?
    @Published var isObserving: Bool = false
    @Published var isDeleted: Bool = false

    func observe(objects: Results<T>, onInitial: @escaping (Array<T>) -> Void={_ in}, onChange: @escaping (Array<T>) -> Void={_ in}) {
        var retryCount = 0

        func attemptObservation() {
            guard let realm = objects.realm, !realm.isInWriteTransaction else {
                // Realm is in a write transaction, retry after a delay
                retryCount += 1
                if retryCount <= 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("Realm is in write transaction, attempting to retry observations")
                        attemptObservation()
                    }
                } else {
                    print("Failed to observe Realm objects after 3 retries.")
                }
                return
            }

            // Observe Results Notifications
            self.notificationToken = objects.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch changes {
                        case .initial(let results):
                            onInitial(Array(results))
                        case .update(let results, _, _, _):
                            onChange(Array(results))
                        case .error(let error):
                            print("\(error)")  // Handle errors appropriately in production code
                            self.stop()
                    }
                }
            }
            isObserving = true
        }

        attemptObservation()
    }

    
    func observe(object: T, onChange: @escaping (T) -> Void={_ in}, onDelete: @escaping () -> Void={}) {
        var retryCount = 0
        
        func attemptObservation() {
            guard let realm = object.realm, !realm.isInWriteTransaction else {
                // Realm is in a write transaction, retry after a delay
                retryCount += 1
                if retryCount <= 3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("Realm is in write transaction, attempting to retry observations")
                        attemptObservation()
                    }
                } else {
                    print("Failed to observe Realm objects after 3 retries.")
                }
                return
            }
            
            
            self.notificationToken = object.observe { [weak self] change in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch change {
                        case .change(let obj, _):
                            if let temp = obj as? T {
                                onChange(temp)
                            }
                        case .deleted:
                            print("Object has been deleted.")
                            self.isDeleted = true
                            onDelete()
                            self.stop()
                        case .error(let error):
                            print("Error: \(error)")
                            self.stop()
                        
                    }
                }
            }
            isObserving = true
        }
        attemptObservation()
    }
    
    func stop() {
        self.notificationToken?.invalidate()
        self.notificationToken = nil
        self.isObserving = true
    }

    deinit {
        notificationToken?.invalidate()
    }
}
