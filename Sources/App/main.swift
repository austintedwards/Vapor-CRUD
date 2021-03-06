import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider.self)
drop.preparations.append(Patient.self)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.get("version") { req in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "No db connection"
    }
}

drop.get("Austin") { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "name"]
        ])
}

drop.post("patients") { request in
    var patient = try Patient(node: request.json)
    try patient.save()
    return patient
}

drop.get("patients", Patient.self) { request, patient in
    return "You requested \(patient.firstName)"
}

drop.get("patients") { request in
    return try drop.view.make("form")
//    return try JSON(node: Patient.all().makeNode())

}

drop.put("patients", Patient.self) { request, patient in
    var patient = patient
    guard let firstName = request.data["first_name"]?.string,
        let lastName = request.data["last_name"]?.string else {
            throw Abort.badRequest
    }
    
    patient.firstName = firstName
    patient.lastName = lastName
    try patient.save()
    return patient
    
}

drop.get("patients", "fname", ":fname") { request in
    guard let fname = request.parameters["fname"]?.string else {
        throw Abort.badRequest
    }
    return try JSON(node: Patient.query().filter("first_name", fname).all().makeNode())
}

drop.delete("patients", Patient.self) { request, patient in
    try patient.delete()
    return try JSON(node: Patient.all().makeNode())
}


drop.resource("posts", PostController())


drop.run()
