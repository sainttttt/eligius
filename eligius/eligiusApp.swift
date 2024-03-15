//
//  eligiusApp.swift
//  eligius
//
//  Created by Saint on 3/14/24.
//

import SwiftUI


let appSize = CGFloat(200)

@main
struct eligiusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: appSize, maxWidth: appSize,
                    minHeight: appSize, maxHeight: appSize)
        }.windowResizability(.contentSize)

        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        chromeless()
    }
}
