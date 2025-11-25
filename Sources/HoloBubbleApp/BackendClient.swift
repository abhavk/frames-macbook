import Foundation

struct BackendClient {
    var backendURL: URL? = URL(string: "https://your-server.example.com/analyze")

    func send(imageData: Data) async throws -> String {
        guard let url = backendURL else {
            throw BackendError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpBody = try makeBody(boundary: boundary, imageData: imageData)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw BackendError.serverFailure
        }

        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private func makeBody(boundary: String, imageData: Data) throws -> Data {
        var body = Data()
        let filename = "capture.png"
        let disposition = "form-data; name=\"file\"; filename=\"\(filename)\"\r\n"
        let contentType = "Content-Type: image/png\r\n\r\n"

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(disposition.data(using: .utf8)!)
        body.append(contentType.data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

enum BackendError: LocalizedError {
    case invalidURL
    case serverFailure

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Backend URL is missing or invalid."
        case .serverFailure:
            return "Server returned an unexpected response."
        }
    }
}
