//
//  RegisterUser.swift
//  TomaTalk
//
//  Created by Uk Dong Kim on 7/10/16.
//  Copyright © 2016 skywalk. All rights reserved.
//

import Foundation

func updateBackendlessUser(_ facebookId: String, avatarUrl: String) {
    
    let whereClause = "facebookId = '\(facebookId)'"
    let dataQuery = BackendlessDataQuery()
    dataQuery.whereClause = whereClause
    
    let dataStore = backendless?.persistenceService.of(BackendlessUser.ofClass())
    dataStore?.find(dataQuery, response: { (users:BackendlessCollection?) in
        let user = users?.data.first as! BackendlessUser
        let properties = ["Avatar" : avatarUrl]
        user.updateProperties(properties)
        backendless?.userService.update(user)
    }) { (error: Fault?) in
        print("Server error : \(error)")
    }
    
//    dataStore.find(dataQuery, response: { (users: BackendlessCollection!) in
//        
//        let user = users.data.first as! BackendlessUser
//        let properties = ["Avatar" : avatarUrl]
//        user.updateProperties(properties)
//        backendless.userService.update(user)
//        
//    }) { (fault: Fault!) in
//        print("Server error : \(fault)")
//    }
}
