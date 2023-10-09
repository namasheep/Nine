//
//  NineBoard.swift
//  Nine
//
//  Created by Namashi Sivaram on 2023-10-08.
//
import ComposableArchitecture

struct NineBoard : Reducer {
    struct State : Equatable{
        var board: [[Card?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    }
    
    enum Action{
        case placeCard(Int, Int, Card)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .placeCard(let x, let y, let card):
            state.board[x][y] = card
            return .none
        }
        
        func deal(deck: inout Deck){
            
            
            
        }
    }
}
