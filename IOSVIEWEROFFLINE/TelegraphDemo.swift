//
//  TelegraphDemo.swift
//  IOSVIEWEROFFLINE
//
//  Created by CONG PHAM on 30/12/2020.
//

import Foundation
import Telegraph
public class TelegraphDemo: NSObject {
  var identity: CertificateIdentity?
  var caCertificate: Certificate?
  var tlsPolicy: TLSPolicy?

  var server: Server!
  var webSocketClient: WebSocketClient!
}

public extension TelegraphDemo {
  func start() {
    setupServer()
  }
}

extension TelegraphDemo {
  private func setupServer() {
    // Create the server instance
    if let identity = identity, let caCertificate = caCertificate {
      server = Server(identity: identity, caCertificates: [caCertificate])
    } else {
      server = Server()
    }

    server.webSocketConfig.pingInterval = 10
    let fileManger = FileManager.default
    let urlDoc = fileManger.urls(for: .documentDirectory, in: .userDomainMask)
    server.serveDirectory(urlDoc[0])
    server.concurrency = 4
    try! server.start(port: 8080, interface: "localhost")
  }
}

