//
//  DatabaseManager.swift
//  EJ1PT3DISPOSITIVOS
//

import Foundation
import SQLite
import CryptoKit
import Security

final class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    // Tabla y columnas de usuarios
    private let users = Table("users")
    private let id = Expression<Int64>("id")
    private let username = Expression<String>("username")
    private let passwordHash = Expression<String>("password_hash")
    private let salt = Expression<String>("salt")
    private let avatar = Expression<String?>("avatar") // Nueva columna opcional

    // Amigos y agregar amigos
    let friendsTable = Table("friends")
    let userCol = Expression<String>("user")
    let friendCol = Expression<String>("friendUser")
    let recipeSaves = Table("recipe_saves")
    let saveId = Expression<Int64>("id")
    let savedByUser = Expression<String>("user")
    let savedRecipeId = Expression<Int64>("recipeId")

    
    
    // Tabla de recetas
    private let recipes = Table("recipes")
    private let recipeId = Expression<Int64>("id")
    private let recipeUser = Expression<String>("user")
    private let recipeTitle = Expression<String>("title")
    private let recipeImage = Expression<String>("image")
    private let recipeDescription = Expression<String>("description")
    private let recipeCategory = Expression<String>("category")
    private let recipeIsPublic = Expression<Bool>("isPublic")
    private let recipeIsLiked = Expression<Bool>("isLiked")
    private let recipeIsSaved = Expression<Bool>("isSaved")
    
    
    

    // MARK: - Inicialización
    private init() {
        do {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbURL = documents.appendingPathComponent("app.sqlite3")
            db = try Connection(dbURL.path)

            try createTables()
            try updateTables()

        } catch {
            print("DB init error:", error)
        }
    }

    // MARK: - Creación de tablas
    private func createTables() throws {
        try db?.run(users.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(username, unique: true)
            t.column(passwordHash)
            t.column(salt)
            t.column(avatar)
        })
        // Tabla recipe_saves
        try? db?.run(recipeSaves.create(ifNotExists: true) { t in
               t.column(saveId, primaryKey: .autoincrement)
               t.column(savedByUser)
               t.column(savedRecipeId)
           })
        try db?.run(recipes.create(ifNotExists: true) { t in
            t.column(recipeId, primaryKey: .autoincrement)
            t.column(recipeUser)
            t.column(recipeTitle)
            t.column(recipeImage)
            t.column(recipeDescription)
            t.column(recipeCategory, defaultValue: "General")
            t.column(recipeIsPublic, defaultValue: false)
            t.column(recipeIsLiked, defaultValue: false)
            t.column(recipeIsSaved, defaultValue: false)
        })
        do {
               try db?.run(friendsTable.create(ifNotExists: true) { t in
                   t.column(id, primaryKey: .autoincrement)
                   t.column(userCol)
                   t.column(friendCol)
               })
           } catch {
               print("Error creando tabla friends: \(error)")
           }
    }

    // MARK: - Actualización de tablas existentes
    private func updateTables() throws {
        do { try db?.run("ALTER TABLE recipes ADD COLUMN category TEXT DEFAULT 'General'") } catch {}
        do { try db?.run("ALTER TABLE recipes ADD COLUMN isPublic INTEGER DEFAULT 0") } catch {}
        do { try db?.run("ALTER TABLE users ADD COLUMN avatar TEXT") } catch {}
    }

    // MARK: - Seguridad
    private func generateSalt(length: Int = 16) -> Data {
        var salt = Data(count: length)
        _ = salt.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!) }
        return salt
    }

    private func hashPassword(password: String, salt: Data) -> String {
        let pwdData = Data(password.utf8) + salt
        let digest = SHA256.hash(data: pwdData)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Registro
    @discardableResult
    func registerUser(username: String, password: String, avatar: String? = nil) -> Bool {
        let saltData = generateSalt()
        let hash = hashPassword(password: password, salt: saltData)
        do {
            let insert = users.insert(
                self.username <- username,
                self.passwordHash <- hash,
                self.salt <- saltData.base64EncodedString(),
                self.avatar <- avatar
            )
            try db?.run(insert)
            return true
        } catch {
            print("Register error:", error)
            return false
        }
    }

    // MARK: - Login
    func loginUser(username: String, password: String) -> Bool {
        do {
            if let row = try db?.pluck(users.filter(self.username == username)) {
                let storedSaltB64 = row[self.salt]
                let storedHash = row[self.passwordHash]
                guard let saltData = Data(base64Encoded: storedSaltB64) else { return false }
                let hash = hashPassword(password: password, salt: saltData)
                return hash == storedHash
            }
        } catch {
            print("Login error:", error)
        }
        return false
    }

                   
    // MARK: - Guardar receta para un usuario
       func saveRecipe(recipeId: Int64, byUser username: String) {
           let recipeSaves = Table("recipe_saves")
           let userCol = Expression<String>("user")
           let recipeIdCol = Expression<Int64>("recipeId")
           
           do {
               // Evitar duplicados
               let exists = try db?.pluck(recipeSaves.filter(userCol == username && recipeIdCol == recipeId)) != nil
               if exists == false {
                   let insert = recipeSaves.insert(userCol <- username, recipeIdCol <- recipeId)
                   try db?.run(insert)
               }
           } catch {
               print("Error saving recipe: \(error)")
           }
       }

       // MARK: - Quitar receta guardada
       func unsaveRecipe(recipeId: Int64, byUser username: String) {
           let recipeSaves = Table("recipe_saves")
           let userCol = Expression<String>("user")
           let recipeIdCol = Expression<Int64>("recipeId")
           
           do {
               let query = recipeSaves.filter(userCol == username && recipeIdCol == recipeId)
               try db?.run(query.delete())
           } catch {
               print("Error unsaving recipe: \(error)")
           }
       }

       // MARK: - Traer recetas guardadas
    // Trae las recetas guardadas de un conjunto de usuarios
    func fetchSavedRecipes(forUsers users: [String]) -> [Recipe] {
        var result: [Recipe] = []
        guard !users.isEmpty else { return result }

        let savedTable = Table("recipe_saves")
        let recipesTable = Table("recipes")

        let recipeIdCol = Expression<Int64>("recipeId")
        let userColInRecipes = Expression<String>("user") // columna "user" en la tabla recipes
        let idCol = Expression<Int64>("id")
        let titleCol = Expression<String>("title")
        let imageCol = Expression<String>("image")
        let descriptionCol = Expression<String>("description")
        let categoryCol = Expression<String>("category")
        let isPublicCol = Expression<Bool>("isPublic")
        let isLikedCol = Expression<Bool>("isLiked")
        let isSavedCol = Expression<Bool>("isSaved")

        do {
            // Usamos IN para varios usuarios
            let query = savedTable
                .join(recipesTable, on: recipesTable[idCol] == savedTable[recipeIdCol])
                .filter(users.contains(savedTable[userCol])) // <- aquí
                .order(recipesTable[idCol].desc)

            for row in try db!.prepare(query) {
                result.append(Recipe(
                    id: Int(row[recipesTable[idCol]]),
                    user: row[recipesTable[userColInRecipes]], // <- aquí usamos Expression
                    title: row[titleCol],
                    image: row[imageCol],
                   description: row[descriptionCol],
                                      category: row[categoryCol],
                                      isPublic: row[isPublicCol],
                                      isLiked: row[isLikedCol],
                                      isSaved: true
                ))
            }
        } catch {
            print("Error fetch saved recipes: \(error)")
        }

        return result
    }

      

    // MARK: - AMIGOS

    // Agregar amigo
       func addFriend(user: String, friendUser: String) {
           let friendsTable = Table("friends")
           let userCol = Expression<String>("user")
           let friendCol = Expression<String>("friendUser")
           
           let insert = friendsTable.insert(userCol <- user, friendCol <- friendUser)
           do {
               try db?.run(insert)
           } catch {
               print("Error agregando amigo: \(error)")
           }
       }
       
       // Obtener lista de amigos de un usuario
       func fetchFriends(of user: String) -> [String] {
           let friendsTable = Table("friends")
           let userCol = Expression<String>("user")
           let friendCol = Expression<String>("friendUser")
           
           do {
               let query = friendsTable.filter(userCol == user)
               return try db?.prepare(query).map { row in
                   row[friendCol]
               } ?? []
           } catch {
               print("Error obteniendo amigos: \(error)")
               return []
           }
       }
   
      func fetchAllUsers(excluding currentUser: String) -> [String] {
          var usersList: [String] = []
          
          // Tabla y columna
          let usersTable = Table("users")
          let usernameColumn = Expression<String>("username") // <- Tipo explícito
          
          do {
              for row in try db!.prepare(usersTable) {
                  let username = row[usernameColumn]
                  if username != currentUser {
                      usersList.append(username)
                  }
              }
          } catch {
              print("Error al cargar usuarios: \(error)")
          }
          
          return usersList
      }
    func fetchRecipes(ofUsers users: [String]) -> [Recipe] {
        var result: [Recipe] = []
        do {
            var query = recipes.order(recipeId.desc)
            if !users.isEmpty {
                query = query.filter(users.contains(recipeUser) || recipeIsPublic)
            }
            for row in try db!.prepare(query) {
                result.append(
                    Recipe(
                        id: Int(row[recipeId]),
                        user: row[recipeUser],
                        title: row[recipeTitle],
                        image: row[recipeImage],
                        description: row[recipeDescription],
                        category: row[recipeCategory],
                        isPublic: row[recipeIsPublic],
                        isLiked: row[recipeIsLiked],
                        isSaved: row[recipeIsSaved]
                    )
                )
            }
        } catch {
            print("Fetch recipes error:", error)
        }
        return result
    }



    
    // MARK: - Recetas
    func addRecipe(user: String, title: String, image: String, description: String, category: String, isPublic: Bool) {
        let insert = recipes.insert(
            recipeUser <- user,
            recipeTitle <- title,
            recipeImage <- image,
            recipeDescription <- description,
            recipeCategory <- category,
            recipeIsPublic <- isPublic,
            recipeIsLiked <- false,
            recipeIsSaved <- false
        )
        do {
            try db?.run(insert)
        } catch {
            print("Inserción de receta error:", error)
        }
    }
    func updateRecipe(_ recipe: Recipe) {
          do {
              let recipesTable = Table("recipes")
              let idExp = Expression<Int64>("id")
              let titleExp = Expression<String>("title")
              let descriptionExp = Expression<String>("description")
              let categoryExp = Expression<String>("category")
              let imageExp = Expression<String>("image")
              let isPublicExp = Expression<Bool>("isPublic")
              
              let recipeRow = recipesTable.filter(idExp == Int64(recipe.id))
              
              try db?.run(recipeRow.update(
                  titleExp <- recipe.title,
                  descriptionExp <- recipe.description,
                  categoryExp <- recipe.category,
                  imageExp <- recipe.image,
                  isPublicExp <- recipe.isPublic
              ))
              
          } catch {
              print("Error al actualizar la receta: \(error)")
          }
      }
    // Trae **todas** las recetas públicas o las propias del usuario
    func fetchRecipes(forUser username: String? = nil) -> [Recipe] {
        var result: [Recipe] = []
        do {
            var query = recipes.order(recipeId.desc)
            if let user = username {
                query = query.filter(recipeIsPublic == true || recipeUser == user)
            }
            for row in try db!.prepare(query) {
                result.append(
                    Recipe(
                        id: Int(row[recipeId]),
                        user: row[recipeUser],
                        title: row[recipeTitle],
                        image: row[recipeImage],
                        description: row[recipeDescription],
                        category: row[recipeCategory],
                        isPublic: row[recipeIsPublic],
                        isLiked: row[recipeIsLiked],
                        isSaved: row[recipeIsSaved]
                    )
                )
            }
        } catch {
            print("Fetch recipes error:", error)
        }
        return result
    }

    func updateReaction(id: Int64, isLiked: Bool, isSaved: Bool) {
        let recipe = recipes.filter(recipeId == id)
        do {
            try db?.run(recipe.update(
                recipeIsLiked <- isLiked,
                recipeIsSaved <- isSaved
            ))
        } catch {
            print("Update reaction error:", error)
        }
    }
}
