//
//  Date+Utils.swift
//  App
//
//  Created by Artem Belkov on 07/10/2018.
//

import Foundation

fileprivate let defaultFormat = "dd.MM.yyyy"

extension Date {
    
    init?(_ string: String, format: String = defaultFormat) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let date = dateFormatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }
    
    func string(_ format: String = defaultFormat) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
}
