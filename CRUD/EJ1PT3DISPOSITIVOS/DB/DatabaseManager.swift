//
//  DatabaseManager.swift
//  EJ1PT3DISPOSITIVOS
//
//  Created by Omar Bermejo Osuna on 12/09/25.
//

import Foundation
import SQLite
import CryptoKit
import Security

final class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: Connection?

    // Tabla y columnas
    private let users = Table("users")
    private let id = Expression<Int64>("id")
    private let username = Expression<String>("username")
    private let passwordHash = Expression<String>("password_hash")
    private let salt = Expression<String>("salt")

    private init() {
        do {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbURL = documents.appendingPathComponent("app.sqlite3")
            db = try Connection(dbURL.path)
            try createTables()
        } catch {
            print("DB init error:", error)
        }
    }

    private func createTables() throws {
        try db?.run(users.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(username, unique: true)
            t.column(passwordHash)
            t.column(salt)
        })
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
    func registerUser(username: String, password: String) -> Bool {
        let saltData = generateSalt()
        let hash = hashPassword(password: password, salt: saltData)
        do {
            let insert = users.insert(
                self.username <- username,
                self.passwordHash <- hash,
                self.salt <- saltData.base64EncodedString()
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
}
