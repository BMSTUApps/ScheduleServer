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
        do {
            try self.removeSubrange(range)
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func trimmingBoundCharacter(_ character: String) -> String {
        var result = self
        
        while result.hasPrefix(character) {
            result = String(result.dropFirst())
        }
        
        while result.hasSuffix(character) {
            result = String(result.dropLast())
        }
        
        return result
    }
    
    func trimmingBoundSpaces() -> String {
        return trimmingBoundCharacter(" ")
    }
}
