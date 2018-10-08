//
//  Abort+Utils.swift
//  App
//
//  Created by Artem Belkov on 08/10/2018.
//

import Foundation
import Vapor

extension Abort {

    static func missingParameters(_ parameters: [String],
                                    file: String = #file,
                                    function: String = #function,
                                    line: UInt = #line,
                                    column: UInt = #column) -> Abort {
        
        var reason = "Missing "
        
        if parameters.count > 1 {
            reason += "parameters: "
            
            for parameter in parameters {
                reason += "'\(parameter)'"
                
                if parameter != parameters.last {
                    reason += ","
                }
            }
            
        } else if parameters.count == 1 {
            reason += "parameter '\(parameters[0])'"
        } else {
            reason += "parameters"
        }
        
        reason += " in request."
        
        return Abort(.badRequest, reason: reason, file: file, function: function, line: line, column: column)
    }
}
