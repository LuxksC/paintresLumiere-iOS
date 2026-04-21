//
//  AuthCoordinatorProtocol.swift
//  PaintresLumiere
//
//  Created by Lucas Souza on 20/04/26.
//

import Foundation

protocol AuthCoordinatorProtocol: AnyObject {
  func loginDidSucceed()
  func loginDidRequestSignUp()
  func loginDidRequestForgotPassword()
  func signUpDidSucceed()
  func signUpDidRequestLogin()
  func forgotPasswordDidFinish()
}
