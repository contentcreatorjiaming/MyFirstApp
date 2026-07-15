//
//  FontRegistration.swift
//  myFirstApp
//
//  Registers custom fonts at runtime so they don't need Info.plist entries.
//  Call registerCustomFonts() once at app launch.
//

import CoreText
import UIKit

enum FontRegistration {
    static func registerCustomFonts() {
        registerFont(named: "Fredoka", extension: "ttf")
    }

    private static func registerFont(named name: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("⚠️ Font file '\(name).\(ext)' not found in bundle")
            return
        }
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            let desc = error?.takeRetainedValue().localizedDescription ?? "unknown"
            print("⚠️ Failed to register font '\(name)': \(desc)")
        }
    }
}
