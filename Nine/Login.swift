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


struct LoginDomain: Reducer {
    struct State : Equatable {
        var ninePlay : NinePlayDomain.State
        var path = StackState<Path.State>()
        var count = 0
        var username = ""
        var password = ""
        var usError = false
        var pwdError = false
        var fact: String?
        var isLoading = false
        var authRes: String?
        var loggedIn = Auth.auth().currentUser != nil
        
        
    
        
      }

    enum Action : Equatable{
        case path(StackAction<Path.State, Path.Action>)
        case passwordChanged(String)
        case loginButtonTapped
        case usernameChanged(String)
        case authResponse(User)
        case authError(NSError)
        case playAction(NinePlayDomain.Action)
        
        
        
      }

    var body: some ReducerOf<Self> {
        Scope(state: \.ninePlay, action: /LoginDomain.Action.playAction) {
              NinePlayDomain()
            }
        Reduce { state, action in
              switch action{
              case .path:
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
                  return .run { [username = state.username, password = state.password] send in
                      Task.init {
                          do {
                              let authResult = try await Auth.auth().signIn(withEmail: username, password: password)
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
                  return .none
                  
              case let .authResponse(user):
                    //state.user = user
                  state.loggedIn = true
                    state.isLoading = false
                    return .none
              case .playAction(let action):
                  if(action == NinePlayDomain.Action.logoutSuccess){
                      //state.user = Auth.auth().currentUser
                      
                      state.loggedIn = false
                  }
                  return .none
              }
        }
        
      .forEach(\.path, action: /Action.path) {
          Path()
      }
    }
    struct Path: Reducer {
        enum State : Equatable{

          case signup(SignUpDomain.State)
            case loggedIn(NinePlayDomain.State)
            
          
        }
        enum Action :Equatable {
          
          case signup(SignUpDomain.Action)
            case loggedIn(NinePlayDomain.Action)
            
          
        }
        var body: some ReducerOf<Self> {
          Scope(state: /State.signup, action: /Action.signup) {
            SignUpDomain()
          }
            Scope(state: /State.loggedIn, action: /Action.loggedIn) {
              NinePlayDomain()
            }

        }
      }
}




struct LoginView: View {
    let store: StoreOf<LoginDomain>
    
    var body: some View {
        
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                if(viewStore.loggedIn){
                    NinePlayView.init(store: self.store.scope(state: \.ninePlay, action: LoginDomain.Action.playAction))
                }
                else{
                
                    
                    
                
                
                    ZStack {
                        
                        Image("bgLogin") // Set the background image for the entire ZStack
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                        
                        
                        ZStack{
                            
                            VStack {
                                Spacer()
                                Text("Welcome Back")
                                    .font(.custom("Silkscreen-Bold", size: 20))
                                    .bold()
                                    .padding()
                                
                                TextField("Username", text: viewStore.binding<String>(get: \.username, send: { .usernameChanged($0) }))
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
                                .font(.custom("Silkscreen-Regular", size: 16))
                                .foregroundColor(.white)
                                .frame(width: 300, height: 50)
                                .background(Color.green)
                                .cornerRadius(10)
                                HStack{
                                    VStack{
                                        Divider()
                                    }// Horizontal line
                                    
                                    Text("or")
                                        .foregroundColor(.secondary)
                                    VStack{
                                        Divider()
                                    }
                                }
                                .frame(width: 300,height: 10)
                                NavigationLink(state: LoginDomain.Path.State.signup(SignUpDomain.State())){
                                    Text("Sign Up")
                                        .font(.custom("Silkscreen-Regular", size: 16))
                                        .foregroundColor(.black)
                                        .frame(width: 300, height: 50)
                                        .background(Color.black.opacity(0.02))
                                        .border(.black)
                                        .cornerRadius(3)
                                }
                                
                                
                                
                                
                                
                                
                            }
                            .padding(.bottom, 50)
                            
                            
                        }
                    }
                }
            }
        }
            
            
        destination: { state in
            switch state {
            case .signup:
                CaseLet(
                    /LoginDomain.Path.State.signup,
                     action: LoginDomain.Path.Action.signup,
                     then: SignUpView.init(store:)
                )
            case .loggedIn:
                CaseLet(
                    /LoginDomain.Path.State.loggedIn,
                     action: LoginDomain.Path.Action.loggedIn,
                     then: NinePlayView.init(store:)
                )
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

struct LoginPreview: PreviewProvider {
  static var previews: some View {
    LoginView(
        store: Store(initialState: LoginDomain.State(ninePlay: NinePlayDomain.State())) {
        LoginDomain()
      }
    )
  }
}
