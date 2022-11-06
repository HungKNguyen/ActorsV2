//
//  ActorsV2App.swift
//  ActorsV2
//
//  Created by Hung K Nguyen on 02/11/2022.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

@main
struct ActorsV2App: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
