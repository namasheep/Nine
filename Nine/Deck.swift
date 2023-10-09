import Foundation

// Define a struct to represent a Card
struct Card : Equatable, CustomStringConvertible {
    let rank: Int
    let suit: Int
    static var cardBackImg = "image_back-0"
    init(rank: Int, suit: Int) {
        self.rank = rank
        self.suit = suit
    }
    
    var description: String {
       let rankString = String(rank)
       let suitString = String(suit)
       return suitString + "-" + rankString
    }
    
    func imageString() -> String{
        let rankString = String(rank-1)
        let suitString = String(suit)
        return "image_" + suitString + "-" + rankString
    }
    static func == (lhs: Card, rhs: Card) -> Bool {
            return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
}

// Define a struct to represent a Deck of cards
struct Deck : Equatable {
    private var cards: [Card]
    private var count = 52
    
    init() {
        cards = []
        let ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
        let suits = [0, 1, 2, 3]

        for suit in suits {
            for rank in ranks {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        cards.shuffle()
    }

    // Shuffle the deck
    mutating func shuffle() {
        cards.shuffle()
    }

    // Draw a card from the deck
    mutating func draw() -> Card? {
        let card = cards.popLast()
        if(card != nil){
            count -= 1
        }
        return card
    }
    
    static func == (lhs: Deck, rhs: Deck) -> Bool {
            return lhs.count == rhs.count
    }
}

// Usage example:

