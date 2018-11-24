import Vapor
import FluentMySQL
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register Authentication provider
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Register custom MySQL Config
    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: "root", password: "rootroot", database: "bmstu")
    services.register(mysqlConfig)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Group.self, database: .mysql)
    migrations.add(model: Schedule.self, database: .mysql)
    migrations.add(model: Event.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: UserToken.self, database: .mysql)
    migrations.add(model: Teacher.self, database: .mysql)
    services.register(migrations)
}
