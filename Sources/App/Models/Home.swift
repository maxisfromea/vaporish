import Vapor
import FluentProvider
import HTTP

final class Home: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var area: String
    var floor: String
    var rooms: String
    var price: String
    var currency: String
    
    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let area = "area"
        static let floor = "floor"
        static let rooms = "rooms"
        static let price = "price"
        static let currency = "currency"
    }
    
    /// Creates a new Post
    init(area: String, floor: String, rooms: String, price: String, currency: String) {
        self.area = area
        self.floor = floor
        self.rooms = rooms
        self.price = price
        self.currency = currency
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        area = try row.get(Home.Keys.area)
        floor = try row.get(Home.Keys.floor)
        rooms = try row.get(Home.Keys.rooms)
        price = try row.get(Home.Keys.price)
        currency = try row.get(Home.Keys.currency)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Home.Keys.area, area)
        try row.set(Home.Keys.floor, floor)
        try row.set(Home.Keys.rooms, rooms)
        try row.set(Home.Keys.price, price)
        try row.set(Home.Keys.currency, currency)
        return row
    }
}

// MARK: Fluent Preparation

extension Home: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Home.Keys.area)
            builder.string(Home.Keys.floor)
            builder.string(Home.Keys.rooms)
            builder.string(Home.Keys.price)
            builder.string(Home.Keys.currency)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Home: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            area: try json.get(Home.Keys.area),
            floor: try json.get(Home.Keys.floor),
            rooms: try json.get(Home.Keys.rooms),
            price: try json.get(Home.Keys.price),
            currency: try json.get(Home.Keys.currency)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Home.Keys.id, id)
        try json.set(Home.Keys.area, area)
        try json.set(Home.Keys.floor, floor)
        try json.set(Home.Keys.rooms, rooms)
        try json.set(Home.Keys.price, price)
        try json.set(Home.Keys.currency, currency)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Home: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Home: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Home>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Home.Keys.area, String.self) { home, area in
                home.area = area
            },
            UpdateableKey(Home.Keys.floor, String.self) { home, floor in
                home.floor = floor
            },
            UpdateableKey(Home.Keys.rooms, String.self) { home, rooms in
                home.rooms = rooms
            },
            UpdateableKey(Home.Keys.price, String.self) { home, price in
                home.price = price
            },
            UpdateableKey(Home.Keys.currency, String.self) { home, currency in
                home.currency = currency
            }
        ]
    }
}

