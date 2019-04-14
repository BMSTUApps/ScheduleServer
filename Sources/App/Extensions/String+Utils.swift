//
//  String+Utils.swift
//  App
//
//  Created by Artem Belkov on 14/04/2019.
//

import Foundation

extension String {

    func removingSubstring(_ substring: String) -> String {
        return self.replacingOccurrences(of: substring, with: "")
    }
    
    func removingSubstrings(_ substrings: [String]) -> String {
        var result = self
    
        substrings.forEach { substring in
            result = result.removingSubstring(substring)
        }
        
        return result
    }
    
    mutating func removeSubstring(in range: Range<String.Index>) {
        self.removeSubrange(range)
    }
    
    func trimmingBoundSpaces() -> String {
        var result = self
        
        while result.hasPrefix(" ") {
            result = String(result.dropFirst())
        }
        
        while result.hasSuffix(" ") {
            result = String(result.dropLast())
        }
        
        return result
    }
}
