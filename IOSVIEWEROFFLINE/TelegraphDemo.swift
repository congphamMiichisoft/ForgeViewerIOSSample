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

    // Set the delegates and a low web socket ping interval to demonstrate ping-pong
    server.delegate = self
    server.webSocketDelegate = self
    server.webSocketConfig.pingInterval = 10

    // Define the demo routes
    // Note: we're ignoring possible strong retain cycles in the demo
    

//    server.serveBundle(.main, "/")
    let fileManger = FileManager.default
    let urlDoc = fileManger.urls(for: .documentDirectory, in: .userDomainMask)
    server.serveDirectory(urlDoc[0])
    // Handle up to 4 requests simultaneously
    server.concurrency = 4

    // Start the server on localhost
    // Note: we'll skip error handling in the demo
    try! server.start(port: 8080, interface: "localhost")

    // Log the url for easy access
    print("[SERVER]", "Server is running - url:", serverURL())
  }
}


// MARK: - ServerDelegate implementation
extension TelegraphDemo: ServerDelegate {
  // Raised when the server gets disconnected.
  public func serverDidStop(_ server: Server, error: Error?) {
    print("[SERVER]", "Server stopped:", error?.localizedDescription ?? "no details")
  }
}

// MARK: - ServerWebSocketDelegate implementation
extension TelegraphDemo: ServerWebSocketDelegate {
  /// Raised when a web socket client connects to the server.
  public func server(_ server: Server, webSocketDidConnect webSocket: WebSocket, handshake: HTTPRequest) {
    let name = handshake.headers["X-Name"] ?? "stranger"
    print("[SERVER]", "WebSocket connected - name:", name)

    webSocket.send(text: "Welcome client \(name)")
    webSocket.send(data: Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05]))
  }

  /// Raised when a web socket client disconnects from the server.
  public func server(_ server: Server, webSocketDidDisconnect webSocket: WebSocket, error: Error?) {
    print("[SERVER]", "WebSocket disconnected:", error?.localizedDescription ?? "no details")
  }

  /// Raised when the server receives a web socket message.
  public func server(_ server: Server, webSocket: WebSocket, didReceiveMessage message: WebSocketMessage) {
    print("[SERVER]", "WebSocket message received:", message)
  }

  /// Raised when the server sends a web socket message.
  public func server(_ server: Server, webSocket: WebSocket, didSendMessage message: WebSocketMessage) {
    print("[SERVER]", "WebSocket message sent:", message)
  }
}

// MARK: - URLSessionDelegate implementation
extension TelegraphDemo: URLSessionDelegate {
  public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    // Use our custom TLS policy to verify if the server should be trusted
    let credential = tlsPolicy!.evaluateSession(trust: challenge.protectionSpace.serverTrust)
    completionHandler(credential == nil ? .cancelAuthenticationChallenge : .useCredential, credential)
  }
}

// MARK: - WebSocketClientDelegate implementation
extension TelegraphDemo: WebSocketClientDelegate {
  /// Raised when the web socket client has connected to the server.
  public func webSocketClient(_ client: WebSocketClient, didConnectToHost host: String) {
    print("[CLIENT]", "WebSocket connected - host:", host)
  }

  /// Raised when the web socket client received data.
  public func webSocketClient(_ client: WebSocketClient, didReceiveData data: Data) {
    print("[CLIENT]", "WebSocket message received - data:", data as NSData)
  }

  /// Raised when the web socket client received text.
  public func webSocketClient(_ client: WebSocketClient, didReceiveText text: String) {
    print("[CLIENT]", "WebSocket message received - text:", text)
  }

  /// Raised when the web socket client disconnects. Provides an error if the disconnect was unexpected.
  public func webSocketClient(_ client: WebSocketClient, didDisconnectWithError error: Error?) {
    print("[CLIENT]", "WebSocket disconnected - error:", error?.localizedDescription ?? "no error")
  }
}

// MARK: Request helpers
extension TelegraphDemo {
  

  /// Generates a server url, we'll assume the server has been started.
  private func serverURL(path: String = "") -> URL {
    var components = URLComponents()
    components.scheme = server.isSecure ? "https" : "http"
    components.host = "localhost"
    components.port = Int(server.port)
    components.path = path
    return components.url!
  }
}
