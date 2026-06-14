import Foundation

// MARK: - JsonHelper
//
// Centralizes JSON decoding for the project. The shared `decoder` is used by
// both production network responses and preview/test fixtures so behavior
// stays consistent — snake_case → camelCase, ISO-8601 dates.

enum JsonHelper {

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func decode<T: Decodable>(_ data: Data, as type: T.Type = T.self) throws -> T {
        try decoder.decode(type, from: data)
    }
}

#if DEBUG

// MARK: - Bundle fixtures (DEBUG only)
//
// Loads mock JSON files under Networking/Mocks/. Used by SwiftUI previews and
// PreviewProductService so previews render with realistic data shapes without
// hitting the network. JSON files are bundled only in DEBUG builds.

extension JsonHelper {

    enum FixtureError: Error {
        case missingResource(String)
    }

    static func decodeFixture<T: Decodable>(
        _ filename: String,
        as type: T.Type = T.self,
        bundle: Bundle = .main
    ) throws -> T {
        let (name, ext) = splitFilename(filename)
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            throw FixtureError.missingResource(filename)
        }
        let data = try Data(contentsOf: url)
        return try decode(data, as: type)
    }

    private static func splitFilename(_ filename: String) -> (name: String, ext: String) {
        let url = URL(fileURLWithPath: filename)
        let ext = url.pathExtension.isEmpty ? "json" : url.pathExtension
        let name = url.deletingPathExtension().lastPathComponent
        return (name, ext)
    }
}

#endif
