//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//


import Foundation

extension FileManager {
    
    /// Creates a new directory if needed, sets the file protection 
    /// to `completeUntilFirstUserAuthentication` and excludes the URL from backups
    public func createAndProtectDirectory(at url: URL) {
        
        if !fileExists(atPath: url.path) {
            do {
                let permission = 0o700
                let attributes = [FileAttributeKey.posixPermissions.rawValue: permission] as [String: Any]
                try createDirectory(at: url, withIntermediateDirectories: true, attributes: attributes)
            }
            catch let error {
                fatal("Failed to create directory: \(url), error: \(error)")
            }
        }
        
        // Make sure it's not accessible until first unlock
        self.setProtectionUntilFirstUserAuthentication(url)
        
        // Make sure this is not backed up:
        url.excludeFromBackup()
    }

    /// Sets the protection to FileProtectionType.completeUntilFirstUserAuthentication
    public func setProtectionUntilFirstUserAuthentication(_ url: URL) {
        do {
            let attributes = [FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
            try self.setAttributes(attributes, ofItemAtPath: url.path)
        }
        catch let error {
            fatal("Failed to set protection until first user authentication: \(url), error: \(error)")
        }
    }

}

public extension URL {
    
    /// Sets the resource value to exclude this entry from backups
    public func excludeFromBackup() {
        var mutableCopy = self
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try mutableCopy.setResourceValues(resourceValues)
        }
        catch let error {
            fatal("Error excluding: \(mutableCopy), from backup: \(error)")
        }
    }
    
    /// Returns whether the item is excluded from backups
    public var isExcludedFromBackup : Bool {
        guard let values = try? resourceValues(forKeys: Set(arrayLiteral: .isExcludedFromBackupKey)) else { return false }
        return values.isExcludedFromBackup ?? false
    }
}
