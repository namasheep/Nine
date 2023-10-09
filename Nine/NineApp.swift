//
//  NineApp.swift
//  Nine
//
//  Created by Namashi Sivaram on 2023-10-07.
//

import SwiftUI
import ComposableArchitecture
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct NineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NinePlayView(store: Store(initialState: NinePlayDomain.State()){
                    NinePlayDomain()
                }
            )
            /*
            LandingPageView(store: Store(initialState: LandingPageDomain.State()){
                    LandingPageDomain()
                }
            )
             */
            /*
            LoginView(
              store: Store(initialState: LoginDomain.State()) {
                LoginDomain()
              }
            )*/
        }
    }
}
