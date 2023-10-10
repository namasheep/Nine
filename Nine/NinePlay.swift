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
import SpriteKit


struct NinePlayDomain: Reducer {
    
    struct State : Equatable {
        var board: [[CardCellDomain.State]] = Array(repeating: Array(repeating: CardCellDomain.State(), count: 3), count: 3)
        var deck : Deck = Deck.init()
        var count = 52
        var dealing = false
        var moveChoice = " "
        var loggedIn = Auth.auth().currentUser != nil
        var correct = true
        
        
    }
    
    enum Action : Equatable{
        case cardCell(CardCellDomain.Action, Int, Int)
        case placeCard(Int, Int)
        case tapCell(Int, Int)
        case holdCell(Int, Int)
        case logout
        case disableCard(Int, Int)
        case logoutError(NSError)
        case logoutSuccess
        
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .logout:
            return .run { send in
                Task.init {
                    do {
                        let authResult = try await Auth.auth().signOut()
                        await send(.logoutSuccess)
                        
                    } catch let error as NSError {
                        await send(.logoutError(error as NSError))
                    }
                }
                
            }
        case let .logoutError(err):
            print(err)
            return .none
            
        case .logoutSuccess:
            state.loggedIn = false
            return .none
        case .placeCard(let x, let y):
            //let card = state.deck.draw()
            //state.board[x][y] = card
            return .none
            
        case .tapCell(let x, let y):
                // Handle tapping a cell (e.g., perform some action)
            //let card = state.deck.draw()
            
            //state.board[x][y] = card
            return .none
                
        case .holdCell(let x, let y):
            // Handle holding a cell (e.g., perform a different action)
            state.board[x][y].menuVis = true
            return .none
        case .cardCell(.addCard, let x, let y):
            guard let card = state.deck.draw() else{
                return .none
            }
            
            
            state.board[x][y].cardlist.append(card)
            state.board[x][y].currentCard = card
            return .none
        case .cardCell(.addCardHigh, let x, let y):
            
            if(state.board[x][y].disabled == true){
                return .none
            }
            guard let card = state.deck.draw() else{
                return .none
            }
            state.moveChoice = "HIGHER"
            print(card.rank)
            state.board[x][y].cardlist.append(card)
            if(state.board[x][y].currentCard != nil && card.rank <= state.board[x][y].currentCard?.rank ?? -1){
                state.board[x][y].noInteract = true
                state.board[x][y].currentCard = card
                state.correct = false
                return .run {  send in
                    Task.init {
                        do{
                            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                            await send(.disableCard(x, y))
                        }
                        catch{
                            
                        }
                        
                    }
                    
                }
                
            }
            
            state.board[x][y].currentCard = card
            return .none
        case .cardCell(.addCardLow, let x, let y):
            
            if(state.board[x][y].disabled == true){
                return .none
            }
            guard let card = state.deck.draw() else{
                return .none
            }
            state.moveChoice = "LOWER"
            print(card.rank)
            state.board[x][y].cardlist.append(card)
            if(state.board[x][y].currentCard != nil && card.rank >= state.board[x][y].currentCard?.rank ?? -1){
                state.board[x][y].noInteract = true
                state.board[x][y].currentCard = card
                state.correct = false
                return .run {  send in
                    Task.init {
                        do{
                            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                            await send(.disableCard(x, y))
                        }
                        catch{
                            
                        }
                        
                    }
                    
                }
                
            }
            
            state.board[x][y].currentCard = card
            return .none
        case .cardCell(.addCardPush, let x, let y):
            print("PRESSED")
            state.moveChoice = "PUSH"
            if(state.board[x][y].disabled == true){
                return .none
            }
            guard let card = state.deck.draw() else{
                return .none
            }
            print(card.rank)
            state.board[x][y].cardlist.append(card)
            if(state.board[x][y].currentCard != nil && card.rank != state.board[x][y].currentCard?.rank ?? -1){
                state.board[x][y].noInteract = true
                state.board[x][y].currentCard = card
                state.correct = false
                return .run {  send in
                    Task.init {
                        do{
                            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                            await send(.disableCard(x, y))
                        }
                        catch{
                            
                        }
                        
                    }
                    
                }

            }
            print("ACTIVATE")
            state.board[x][y].currentCard = card
            return .none
        
            
        case .disableCard(let x, let y):
            state.correct = true
            state.moveChoice = " "
            state.board[x][y].disabled = true
            return .none
            
        }
        
        
    }
}




struct NinePlayView: View {
    let store: StoreOf<NinePlayDomain>
    init(store: StoreOf<NinePlayDomain>) {
        self.store = store
        
        
        
        // Set the navigation bar's tint color to a contrasting color
        UINavigationBar.appearance().tintColor = .red
    }
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView{
                Section{
                    ZStack {
                        Color.green.ignoresSafeArea()
                        
                        VStack {
                            ZStack{
                                
                                Text("NINE")
                                    .font(.custom("Silkscreen-Bold", size: 80))
                                    .foregroundColor(.black)
                                    .offset(x: 7, y: 10)
                                Text("NINE")
                                    .font(.custom("Silkscreen-Bold", size: 80)).foregroundColor(.white)
                            }
                            ZStack{
                                
                                Text("\(viewStore.deck.count)")
                                    .font(.custom("Silkscreen-Regular", size: 34))
                                    .foregroundColor(.black)
                                    .offset(x: 3, y: 5)
                                Text("\(viewStore.deck.count)")
                                    .font(.custom("Silkscreen-Regular", size: 34)).foregroundColor(.white)
                            }
                            
                            Spacer()
                            ZStack{
                                Text("\(viewStore.moveChoice)")
                                    .font(.custom("Silkscreen-Regular", size: 26)).foregroundColor(.black)
                                    .offset(x: 3, y: 2)
                                Text("\(viewStore.moveChoice)")
                                    .font(.custom("Silkscreen-Regular", size: 26)).foregroundColor(viewStore.correct ? .white : .red)
                                    
                            }
                            ForEach(0..<3, id: \.self) { row in
                                
                                HStack {
                                    ForEach(0..<3, id: \.self) { col in
                                        CardCellView(
                                            store: self.store.scope(
                                                state: \.board[row][col],
                                                action: { cardCellAction in
                                                    NinePlayDomain.Action.cardCell(cardCellAction, row, col)
                                                }
                                            )
                                        )
                                        .gesture(
                                            DragGesture()
                                                .onEnded { value in
                                                    if(!viewStore.board[row][col].noInteract){
                                                        let horizontalDistance = value.translation.width
                                                        let verticalDistance = value.translation.height
                                                        
                                                        if abs(horizontalDistance) > abs(verticalDistance) {
                                                            if horizontalDistance > 0 {
                                                                // Handle right swipe
                                                                // Perform your action here
                                                                viewStore.send(.cardCell(.addCardPush, row ,col))
                                                            } else {
                                                                // Handle left swipe
                                                                // Perform your action here
                                                                viewStore.send(.cardCell(.addCardPush, row ,col))
                                                            }
                                                        } else {
                                                            if verticalDistance > 0 {
                                                                // Handle down swipe
                                                                // Perform your action here
                                                                viewStore.send(.cardCell(.addCardLow, row ,col))
                                                            } else {
                                                                // Handle up swipe
                                                                // Perform your action here
                                                                viewStore.send(.cardCell(.addCardHigh, row ,col))
                                                            }
                                                        }
                                                    }
                                                }
                                        )
                                        .onTapGesture {
                                            
                                            viewStore.send(.cardCell(.addCardPush,row, col))
                                            
                                        }
                                        .onLongPressGesture {
                                            viewStore.send(.holdCell(row, col))
                                        }
                                        
                                    }
                                }
                            }
                            Spacer()
                        }
                        
                        
                        
                    }
                        
                }.tabItem(){
                    Text("9")
                        .font(.custom("Silkscreen-Bold", size: 100))
                }
            Text("SAOSIAOSA")
                .tabItem(){
                    Image("003-users")
                }
            
                Section{
                    Button("Logout"){
                        viewStore.send(.logout)
                    }
                }
                .tabItem(){
                    Image("002-settings")
                }
                
            }
            
        }
        .onAppear {
            for i in 0...2 {
                for y in 0...2 {
                    store.send(.cardCell(.addCard, i, y))
                }
            }
        }
        
    }
}
struct NinePlayPreview: PreviewProvider {
  static var previews: some View {
    NinePlayView(
      store: Store(initialState: NinePlayDomain.State()) {
        NinePlayDomain()
      }
    )
  }
}

struct CardCellDomain : Reducer {
    struct State : Equatable{
        var cardlist : [Card] = []
        var currentCard : Card?
        var disabled = false
        var menuVis = false
        var animatingCard = false
        var noInteract = false
    }
    
    enum Action : Equatable {
        case addCardHigh
        case addCardLow
        case addCardPush
        case addCard
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action{
        case .addCardHigh:
            return .none
        case .addCardLow:
            return .none
        case .addCardPush:
            return .none
        case .addCard:
            return .none
        }
    }
}
struct OptionsMenu: View {
    var onOptionSelected: (Int) -> Void
    
    var body: some View {
        Menu {
            Button("Option 1") {
                onOptionSelected(1)
            }
            Button("Option 2") {
                onOptionSelected(2)
            }
            Button("Option 3") {
                onOptionSelected(3)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 25))
        }
    }
}

struct CardCellView: View {
    let store: StoreOf<CardCellDomain>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Image(viewStore.disabled == true ? Card.cardBackImg : viewStore.currentCard?.imageString() ?? "xmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35*1.9, height: 47*1.9)
                .padding(5)
                
                .cornerRadius(10)

        }
    }
}


