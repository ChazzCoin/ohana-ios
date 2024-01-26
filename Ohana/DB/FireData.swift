//
//  FireData.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/14/23.
//

import Foundation
import FirebaseDatabase
import RealmSwift



func safeRef(block: (DatabaseReference) -> Void) {
    block(Database.database().reference())
}

extension DatabaseReference {
        
    func get(onSnapshot: @escaping (DataSnapshot) -> Void) {
        
        self.observeSingleEvent(of: .value) { snapshot, _ in
            onSnapshot(snapshot)
        }
    }
    
    func delete(id: String) {
        
        self.child(id).removeValue()
    }
    
    func save(obj: Object) {
        
        self.setValue(obj.toDict())
    }
    
    func save(id: String, obj: Object) {
        
        self.child(id).setValue(obj.toDict())
    }
    
    func save(collection: String, id: String, obj: Object) {
        self.child(collection).child(id).setValue(obj.toDict())
    }
    
}

func firebaseDatabase(block: @escaping (DatabaseReference) -> Void) {
    let reference = Database.database().reference()
    block(reference)
}

