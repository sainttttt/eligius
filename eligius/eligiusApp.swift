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
    @State var currentNumber: String = "1"

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

        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            // 3
            Button("One") {
                currentNumber = "1"
            }
            Button("Two") {
                currentNumber = "2"
            }
            Button("Three") {
                currentNumber = "3"
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        chromeless()
    }
}
