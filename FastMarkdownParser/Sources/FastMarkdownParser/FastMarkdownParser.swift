// The Swift Programming Language
// https://docs.swift.org/swift-book
import MarkdownParserFFI
import Foundation

public struct FastMarkdownParser {
    public static func testTelloWorld() {
        markdown_parser_ffi_hello_world()
    }
    public static func parse(source: String) throws -> Result<[ MarkdownNode ], SomeError> {
        switch Self.internalParseToJsonStringUnsafe(source: source, prettyPrint: false) {
        case .failure(let error): return .failure(error)
        case .success(let output):
            let outJsonData = output.data(using: .utf8)!
            let decoder = JSONDecoder()
            let outputArray = try decoder.decode([MarkdownNode].self, from: outJsonData)
            return .success(outputArray)
        }
    }
    public static func fastUnsafeParser(source: String) throws -> [ MarkdownNode ] {
        fatalError("TODO")
    }
    public static func internalParseToJsonStringSlow(source: String, prettyPrint: Bool = false) -> Result<String, SomeError> {
        // MARK: COPY ALL BYTES TO INPUT BUFFER
        let inputByteVector = markdown_parser_ffi_byte_vector_new()
        for byte in Array(source.utf8) {
            markdown_parser_ffi_byte_vector_push(inputByteVector, byte)
        }
        // MARK: PARSE!
        let markupEngineParseResult = markdown_parser_ffi_utf8_byte_vector_parse(inputByteVector)
        // MARK: COPY ALL RUST BUFFER BYTES TO SWIFT ARRAY
        var outputBytes: [UInt8] = []
        for i in 0..<markdown_parser_ffi_byte_vector_length(markupEngineParseResult.output) {
            let out = markdown_parser_ffi_byte_vector_get(markupEngineParseResult.output, i)
            assert(out.status.rawValue == 0)
            outputBytes.append(out.data)
        }
        // MARK: CLEANUP
        markdown_parser_ffi_byte_vector_free(inputByteVector)
        markdown_parser_ffi_byte_vector_free(markupEngineParseResult.output)
        let outputString = String(decoding: outputBytes, as: UTF8.self)
        if markupEngineParseResult.status.rawValue != 0 {
            return .failure(SomeError(message: outputString))
        }
        if prettyPrint {
            if let jsonStringData = outputString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonStringData, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                return .success(String(decoding: jsonData, as: UTF8.self))
            } else {
                return .success(outputString)
            }
        }
        return .success(outputString)
    }
    public static func internalParseToJsonStringUnsafe(source: String, prettyPrint: Bool = false) -> Result<String, SomeError> {
        let sourcePointer: UnsafePointer<CChar> = (source as NSString).utf8String!
        let parseResult = markdown_parser_ffi_utf8_parse_to_json_string(sourcePointer)
        let outputString = String(cString: parseResult.output.pointer)
        markdown_parser_ffi_rust_c_string_free(parseResult.output)
        if parseResult.status.rawValue != 0 {
            return .failure(SomeError(message: outputString))
        }
        return .success(outputString)
    }
    public struct SomeError: Error {
        public let message: String
    }
}

