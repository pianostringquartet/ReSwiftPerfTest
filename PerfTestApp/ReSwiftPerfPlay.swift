//
//  ReSwiftPerfTest.swift
//
//  Created by Christian J Clampitt on 11/23/22.
//

import SwiftUI
import ReSwift
import DisplayLink

//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ReSwiftPerfPlay()
//        }
//    }
//}

class ObservableData: ObservableObject {
    var counter = 0
}

struct ReSwiftState: StateType, Equatable {
    var counter = 0
}

struct ReSwiftPerfPlay: View {

    @StateObject var observableData = ObservableData()
    @StateObject var storeData = ReSwiftStore<ReSwiftState>(store: reswiftStore())

    var body: some View {
        Text("UI does not use state")
            // DisplayLink: on-frame callback:
            // https://github.com/timdonnelly/DisplayLink
            .onFrame { _ in

                // When updating `observableData` alone,
                // CPU is 4-5%
//                observableData.counter += 1

                // When updating `storeData` alone:
                // ReSwift 6.1.0: CPU is 23-28%
                // ReSwift 6.0.0: CPU is 16-19%
                // ReSwift 5.0.0: CPU is 17-18%
                storeData.dispatch(CounterIncremented())
            }
    }
}

// -- MARK: reducer, store, action

func reswiftReducer(action: Action,
                    state: ReSwiftState?) -> ReSwiftState {
//    print("reswiftReducer")
    var totalState = state ?? ReSwiftState()

    if action is CounterIncremented {
        totalState.counter += 1
        return totalState
    } else {
        return totalState
    }
}

struct CounterIncremented: Action, Equatable { }

func reswiftStore() -> Store<ReSwiftState> {
    Store<ReSwiftState>(reducer: reswiftReducer,
                        state: ReSwiftState())
}

// -- MARK: adapting ReSwift to SwiftUI

typealias Dispatch = (Action) -> Void

class ReSwiftStore<T: StateType>: ObservableObject {
    private var store: Store<T>

    @Published var state: T

    let dispatch: Dispatch

    init(store: Store<T>) {
        self.store = store
        self.state = store.state

        let dispatch: Dispatch = store.dispatch
        self.dispatch = dispatch

        store.subscribe(self)
    }

    deinit {
        store.unsubscribe(self)
    }
}

extension ReSwiftStore: StoreSubscriber {
    public func newState(state: T) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}
