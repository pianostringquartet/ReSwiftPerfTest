//
//  PerfTestAppApp.swift
//  PerfTestApp
//
//  Created by Christian J Clampitt on 11/18/22.
//

import SwiftUI
import DisplayLink


/*
 Holding ReSwift store in SwiftUI View vs Scene/App:
 
 Store, onFrame in View: 16-17% CPU

 Store, onFrame in App: 32-33% CPU
 
 Store in App, onFrame + dispatch in View: 8-9% CPU
 */

@main
struct PerfTestAppApp: App {
    
    @StateObject var storeData = ReSwiftStore<ReSwiftState>(store: reswiftStore())
    
    var body: some Scene {
        WindowGroup {
//           ReSwiftPerfPlay()
            
//            PerfTestView()
            PerfTestView(dispatch: storeData.dispatch)
//                .onFrame { _ in
//                    storeData.dispatch(CounterIncremented())
//                }
        }
    }
}


struct PerfTestView: View {
    
//    @StateObject var storeData = ReSwiftStore<ReSwiftState>(store: reswiftStore())

    let dispatch: Dispatch
    
    var body: some View {
        Text("UI does not use state")
            .onFrame { _ in
//                storeData.dispatch(CounterIncremented())
                dispatch(CounterIncremented())
            }
    }
}
