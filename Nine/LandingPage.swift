//
//  LandingPage.swift
//  Nine
//
//  Created by Namashi Sivaram on 2023-10-07.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct LandingPageDomain : Reducer{
    struct State {
        var path = StackState<Path.State>()
        // ...
      }
      enum Action {
        case path(StackAction<Path.State, Path.Action>)
        // ...
      }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action{
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
    struct Path: Reducer {
        enum State {
          case login(LoginDomain.State)
          case signup(SignUpDomain.State)
          
        }
        enum Action {
          case login(LoginDomain.Action)
          case signup(SignUpDomain.Action)
          
        }
        var body: some ReducerOf<Self> {
          Scope(state: /State.login, action: /Action.login) {
            LoginDomain()
          }
          Scope(state: /State.signup, action: /Action.signup) {
            SignUpDomain()
          }
        }
      }
    
}

struct LandingPageView: View {
    let store: StoreOf<LandingPageDomain>
    
    var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            ZStack {
                Color.green
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white)
                
                
                VStack{
                    NavigationLink(state: LandingPageDomain.Path.State.login(LoginDomain.State())){
                        Button("Login") {
                         
                        }
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    NavigationLink(state: LandingPageDomain.Path.State.signup(SignUpDomain.State())){
                        Button("Sign Up") {
                            
                        }
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.yellow)
                        .cornerRadius(10)
                    }
                }
            }
            
        } destination: { state in
            switch state {
            case .login:
                CaseLet(
                    /LandingPageDomain.Path.State.login,
                     action: LandingPageDomain.Path.Action.login,
                     then: LoginView.init(store:)
                )
            case .signup:
                CaseLet(
                    /LandingPageDomain.Path.State.signup,
                     action: LandingPageDomain.Path.Action.signup,
                     then: SignUpView.init(store:)
                )
            }
        }
    }
}
