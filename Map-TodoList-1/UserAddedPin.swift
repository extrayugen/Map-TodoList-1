//
//  UserAddedPin.swift
//  Map-TodoList-1
//
//  Created by t2023-m0031 on 1/7/24.
//

import UIKit
import MapKit

class UserAddedPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
    }

}
