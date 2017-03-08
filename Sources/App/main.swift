import Vapor
import VaporPostgreSQL

let drop = Droplet(
    providers: [VaporPostgreSQL.Provider.self]
)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("posts", PostController())

drop.run()
