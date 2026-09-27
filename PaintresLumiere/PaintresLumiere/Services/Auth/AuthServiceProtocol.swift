//
//  AuthServiceProtocol.swift
//  PaintresLumiere
//
//  Created by Lucas Souza on 12/04/26.
//

protocol AuthServiceProtocol: AnyObject, Sendable {
    func login(email: String, password: String) async throws -> String
    func signUp(name: String, email: String, password: String,
                phone: String?, cpf: String?, cnpj: String?) async throws -> String
    func authenticateWithGoogle(idToken: String) async throws -> String
    func authenticateWithApple(identityToken: String, email: String?, fullName: String?) async throws -> String
    func logout() async throws
    func deleteAccount() async throws
}
