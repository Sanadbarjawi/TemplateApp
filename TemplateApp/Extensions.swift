//
//  Extensions.swift
//  TemplateApp
//
//  Created by Sanad Barjawi on 8/9/18.
//  Copyright © 2018 Sanad Barjawi. All rights reserved.
//

import Foundation
import UIKit
extension UIColor {
    /**
     Creates an UIColor from HEX String in "#363636" format
     - parameter hexString: HEX String in "#363636" format
     - returns: UIColor from HexString
     */
    convenience init(hexString: String) {
        
        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner          = Scanner(string: hexString as String)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    struct Palette {
        static let black = UIColor.black
        static let white = UIColor.white
        static let gray = UIColor(hexString: "757575")
    }
    
    // MARK: - Background
    
    /// Returns the light palette color used for the background for standard content.
    ///
    /// - Parameters:
    ///   - theme: The theme for which to determine the color of the background for standard content.
    /// - Returns: The light palette color used for the background for standard content.
    class func contentBackground(for theme: Theme) -> UIColor {
        switch theme {
        case .light:
            return Palette.white
        case .dark:
            return Palette.black
        }
    }
    class func txtfieldBackground(for theme: Theme) -> UIColor{
        switch theme {
        case .light:
            return Palette.white
        case .dark:
            return Palette.gray
        }
    }
    class func buttonTextColor(for theme: Theme) -> UIColor{
        switch theme {
        case .light:
            return Palette.black
        case .dark:
            return Palette.white
        }
    }
}

enum Theme {
    case light
    case dark
}

/// A protocol which denotes types which can update their colors.
protocol ColorUpdatable {
    
    /// The theme for which to update colors.
    var theme: Theme { get set }
    
    /// A function that is called when colors should be updated.
    ///
    /// - Parameter theme: The theme for which to update colors.
    func updateColors(for theme: Theme)
}

/// A protocol for observing `didChangeColorTheme` custom notifications. Call `addDidChangeColorThemeObserver` upon instantiation and `removeDidChangeColorThemeObserver` upon deinit to adapt to the app's color theme setting.
protocol ColorThemeObserving {
    
    /// Call this method upon instantiation to observe `didChangeColorTheme` notifications.
    ///
    /// - Parameter notificationCenter: The mechanism for broadcasting color theme change information throughout the program.
    func addDidChangeColorThemeObserver(notificationCenter: NotificationCenter)
    
    /// Call this method upon deinit to remove notification observation.
    ///
    /// - Parameter notificationCenter: The mechanism for broadcasting color theme change information throughout the program.
    func removeDidChangeColorThemeObserver(notificationCenter: NotificationCenter)
    
    /// Called whenever a `didChangeColorTheme` notification is received. Adapts the color theme to the app's current color theme preference.
    ///
    /// - Parameter notification: The `didChangeColorTheme` custom notification.
    func didChangeColorTheme(_ notification: Notification)
}

// MARK: - ColorThemeObserving

private extension ColorThemeObserving {
    
    func theme(from notification: Notification) -> Theme? {
        guard let userInfo = notification.userInfo,
            let theme = userInfo[CustomNotification.didChangeColorTheme.rawValue] as? Theme else {
                assertionFailure("Unexpected user info value type.")
                return nil
        }
        return theme
    }
    
    /// Updates the colors of `ColorUpdatable`-conforming objects.
    func updateColors(from notification: Notification) {
        guard let theme = theme(from: notification) else { return }
        
        if var colorUpdatableThing = self as? ColorUpdatable, theme != colorUpdatableThing.theme {
            colorUpdatableThing.theme = theme
            colorUpdatableThing.updateColors(for: theme)
        }
    }
}

/// Custom notifications for which to broadcast important messages throughout the app.
///
/// - didChangeColorTheme: A notification indicating that the app's color theme has changed.
enum CustomNotification: String {
    
    case didChangeColorTheme
    
    /// Broadcasts a global notification.
    ///
    /// - Parameters:
    ///   - notificationCenter: The mechanism for broadcasting information throughout the app.
    ///   - object: The object posting the notification.
    ///   - userInfo: Information about the the notification.
    func post(notificationCenter: NotificationCenter = NotificationCenter.default, object: AnyObject? = nil, userInfo: Any) {
        let userInfo = [self.rawValue: userInfo]
        DispatchQueue.main.async {
            notificationCenter.post(name: Notification.Name(rawValue: self.rawValue), object: object, userInfo: userInfo)
        }
    }
    
    /// Observes a global notification using a provided method.
    ///
    /// - Parameters:
    ///   - notificationCenter: The mechanism for broadcasting information throughout the app.
    ///   - target: The object on which to call the `selector` method.
    ///   - selector: The method to call when the notification is broadcast.
    func observe(notificationCenter: NotificationCenter = NotificationCenter.default, target: AnyObject, selector: Selector) {
        notificationCenter.addObserver(target, selector: selector, name: Notification.Name(rawValue: self.rawValue), object: nil)
    }
}


// MARK: - UIViewController

extension UIViewController: ColorThemeObserving  {
    
    func addDidChangeColorThemeObserver(notificationCenter: NotificationCenter = NotificationCenter.default) {
        notificationCenter.addObserver(self,
                                       selector: #selector(didChangeColorTheme),
                                       name: Notification.Name(rawValue:
                                        CustomNotification.didChangeColorTheme.rawValue),
                                       object: nil)
    }
    
    func removeDidChangeColorThemeObserver(notificationCenter: NotificationCenter = NotificationCenter.default) {
        notificationCenter.removeObserver(self,
                                          name: Notification.Name(rawValue:
                                            CustomNotification.didChangeColorTheme.rawValue),
                                          object: nil)
    }
    
    @objc func didChangeColorTheme(_ notification: Notification) {
        updateColors(from: notification)
    }
}

// MARK: - UITableViewController

extension UITableViewController {
    
    @objc override func didChangeColorTheme(_ notification: Notification) {
        updateColors(from: notification)
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewController

extension UICollectionViewController {
    
    @objc override func didChangeColorTheme(_ notification: Notification) {
        updateColors(from: notification)
        collectionView?.reloadData()
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

