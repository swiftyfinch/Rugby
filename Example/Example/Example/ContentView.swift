//
//  ContentView.swift
//  Example
//
//  Created by Vyacheslav Khorkov on 16.08.2023.
//

import Alamofire
import Moya
import SnapKit
import Kingfisher
import KeyboardLayoutGuide
import SwiftUI
import LocalPod

struct ContentView: View {
    private let dummy = DummySource()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            // Just for testing
            dummy.load()
        }
    }
}
