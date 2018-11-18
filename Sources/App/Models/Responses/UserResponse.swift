
/// Public representation of user data.
struct UserResponse: Response {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
    
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
}
