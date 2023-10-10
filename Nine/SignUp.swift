//
//  Login.swift
//  Nine
//
//  Created by Namashi Sivaram on 2023-10-07.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import FirebaseAuth


struct SignUpDomain: Reducer {
    struct State: Equatable {
        var count = 0
        var username = ""
        var password = ""
        var usError = false
        var pwdError = false
        var fact: String?
        var isLoading = false
        var authRes: String?
        var user: User?
        var dispName = ""
      }

    enum Action : Equatable{
        case passwordChanged(String)
        case loginButtonTapped
        case usernameChanged(String)
        case dispNameChanged(String)
        case authResponse(User)
        case authError(NSError)
        
      }

      func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .dispNameChanged(let dispName):
            state.dispName = dispName
            return .none
        case .passwordChanged(let password):
          state.password = password
          return .none
            
        case let .usernameChanged(username):
            state.username = username
            return .none
            
        case .loginButtonTapped:
            state.fact = nil
            state.isLoading = true
            return .run { [username = state.username, password = state.password, dispName = state.dispName] send in
                Task.init {
                    do {
                        let authResult = try await Auth.auth().createUser(withEmail: username, password: password)
                        await send(.authResponse(authResult.user))
                    } catch {
                        // Handle authentication error here
                        await send(.authError(error as NSError))
                    }
                }
            }

                
        case let .authError(err):
            print("FAILED AUTH",err)
            if(err.code==AuthErrorCode.invalidEmail.rawValue){
                print("bad email")
                state.usError = true
                
            }
            if(err.code==AuthErrorCode.weakPassword.rawValue){
                print("weak pass")
                state.pwdError = true
                
            }
            state.isLoading = false
            return .none
            
        case let .authResponse(user):
              state.user = Auth.auth().currentUser
              state.isLoading = false
              return .none

        }
      }
}




struct SignUpView: View {
    let store: StoreOf<SignUpDomain>
    init(store: StoreOf<SignUpDomain>) {
            self.store = store
            // Set the navigation bar's tint color to a contrasting color
            UINavigationBar.appearance().tintColor = .red
        }
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            ZStack {
                Color.yellow
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white)
                
                VStack {
                    if(viewStore.isLoading){
                        ProgressView()
                    }
                    else{
                        Text("Sign Up")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        TextField("Email", text: viewStore.binding<String>(get: \.username, send: { .usernameChanged($0) }))
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .border(viewStore.usError ? .red:.black)
                        
                        
                        SecureField("Password", text: viewStore.binding<String>(get: \.password, send: {.passwordChanged($0)}))
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .border(viewStore.pwdError ? .red:.black)
                        
                        Button("Login") {
                            viewStore.send(.loginButtonTapped)
                        }
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                    }
                    
                    
                }
            }
        }
    
        
}
    
    /*

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
          VStack {
            Text("\(viewStore.count)")
              .font(.largeTitle)
              .padding()
              .background(Color.black.opacity(0.1))
              .cornerRadius(10)
            HStack {
              Button("-") {
                viewStore.send(.decrementButtonTapped)
              }
              .font(.largeTitle)
              .padding()
              .background(Color.black.opacity(0.1))
              .cornerRadius(10)

              Button("+") {
                viewStore.send(.incrementButtonTapped)
              }
              .font(.largeTitle)
              .padding()
              .background(Color.black.opacity(0.1))
              .cornerRadius(10)
            }
            Button("Fact") {
              viewStore.send(.factButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)

            if viewStore.isLoading {
              ProgressView()
            } else if let fact = viewStore.fact {
              Text(fact)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding()
            }
          }
        }
      }
     */
}
struct SignUpPreview: PreviewProvider {
  static var previews: some View {
    SignUpView(
      store: Store(initialState: SignUpDomain.State()) {
        SignUpDomain()
      }
    )
  }
}
