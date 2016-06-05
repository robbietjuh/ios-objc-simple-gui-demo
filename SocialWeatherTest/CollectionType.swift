//
//  CollectionType.swift
//  SocialWeatherTest
//
//  Created by R. de Vries on 05-06-16.
//  Copyright © 2016 R. de Vries. All rights reserved.
//

import Foundation

extension CollectionType {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}