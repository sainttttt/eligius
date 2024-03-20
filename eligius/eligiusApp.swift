//
//  eligiusApp.swift
//  eligius
//
//  Created by Saint on 3/14/24.
//

import MenuBarExtraAccess
import SwiftUI
import Combine

let appSize = CGFloat(200)

class Settings: ObservableObject {
    @Published var isMenuPresented: Bool = false
    @Published var timerLeft = ""
    @Published var timerDate: Date?
}

@main
struct eligiusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var settings = Settings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 350, maxWidth: 350,
                    minHeight: 200, maxHeight: 200
                )
                .environmentObject(settings)
        }
        .windowResizability(.contentSize)

        MenuBarExtra("MyApp Menu", systemImage: "folder") {
            MyMenu()
                .introspectMenuBarExtraWindow { window in // <-- the magic ✨
                    window.animationBehavior = .alertPanel

                }
                .environmentObject(settings)
        }

        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $settings.isMenuPresented) { _ in // <-- the magic ✨
            // access status item or store it in a @State var
        }
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

struct MyMenu: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack {
            Text("Timer:")
                .font(Font.custom("EPSON-FUTO-MINCHO", size: 50))
            TextField("hint", text: $settings.timerLeft)
                .font(Font.custom("EPSON-FUTO-MINCHO", size: 50))
                .onReceive(Just(settings.timerLeft)) { newValue in
                    let value = newValue.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
                    if value != newValue {
                        self.settings.timerLeft = value
                    }
                    print(newValue)
                }
                .onSubmit() {
                    settings.isMenuPresented.toggle()
                    let calendar = Calendar.current
                    // Define the date components
                    var dateComponents = DateComponents()
                    // Set the minute component to 54
                    dateComponents.minute = Int(self.settings.timerLeft)
                    self.settings.timerDate =  calendar.date(byAdding: dateComponents, to: Date())
                    print(self.settings.timerLeft)
                    print("\(self.settings.timerDate)")
                }
        }
        .frame(
            minWidth: 350, maxWidth: 350,
            minHeight: 200, maxHeight: 200
        )

            .onAppear() {
                chromeless()
            }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        chromeless()
    }
}
