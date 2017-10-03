/**
 * Copyright IBM Corporation 2016-2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import RestKit

class CodableExtensionsTests: XCTestCase {

    // Note: When encoding a JSON object to a string, Mac and Linux produce different key orderings.
    // This is valid, since there is no required order for the keys in a Swift Dictionary or JSON object.
    // However, the different key orderings make it difficult to compare the strings for equality.
    // Instead of directly comparing strings for equality, we have chosen to sort the strings and
    // ensure that they contain the same characters.

    static var allTests = [
        ("testEncodeNil", testEncodeNil),
        ("testEncodeMetadata", testEncodeMetadata),
        ("testEncodeCustom", testEncodeCustom),
        ("testEncodeAdditionalProperties", testEncodeAdditionalProperties),
        ("testEncodeOptional", testEncodeOptional),
        ("testEncodeOptionalEmpty", testEncodeOptionalEmpty),
        ("testEncodeOptionalNil", testEncodeOptionalNil),
        ("testDecodeMetadata", testDecodeMetadata),
        ("testDecodeCustom", testDecodeCustom),
        ("testDecodeAdditionalProperties", testDecodeAdditionalProperties),
        ("testDecodeOptional", testDecodeOptional),
        ("testDecodeOptionalEmpty", testDecodeOptionalEmpty),
        ("testDecodeOptionalNil", testDecodeOptionalNil)
    ]

    func testEncodeNil() {
        let model: ServiceModelOptional? = nil
        let encoder = JSONEncoder()
        let data = try! encoder.encodeIfPresent(model)
        let json = String(data: data, encoding: .utf8)!
        let expected = ""
        XCTAssertEqual(json.sorted(), expected.sorted())
    }

    func testEncodeMetadata() {
        let metadata: [String: JSONValue] = [
            "null": .null,
            "bool": .boolean(true),
            "int": .int(1),
            "double": .double(0.5),
            "string": .string("this is a string"),
            "array": .array([.int(1), .int(2), .int(3)]),
            "object": .object(["x": .int(1)])
        ]
        let model = ServiceModel(name: "name", metadata: metadata, additionalProperties: [:])
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(model)
        let json = String(data: data, encoding: .utf8)!
        let expected = """
            {
              "name" : "name",
              "metadata" : {
                "null" : null,
                "bool" : true,
                "int" : 1,
                "double" : 0.5,
                "string" : "this is a string",
                "array" : [
                  1,
                  2,
                  3
                ],
                "object" : {
                  "x" : 1
                }
              }
            }
            """
        XCTAssertEqual(json.sorted(), expected.sorted())
    }

    func testEncodeCustom() {
        let custom = CustomModel(
            null: nil, // JSONEncoder strips this null value from the resulting JSON
            boolean: true,
            int: 1,
            double: 0.5,
            string: "this is a string",
            array: [1, 2, 3],
            object: ["x": 1]
        )
        let metadata = ["custom": try! JSONValue(from: custom)]
        let model = ServiceModel(name: "name", metadata: metadata, additionalProperties: [:])
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(model)
        let json = String(data: data, encoding: .utf8)!
        let expected = """
            {
              "name" : "name",
              "metadata" : {
                "custom" : {
                  "boolean" : true,
                  "int" : 1,
                  "double" : 0.5,
                  "string" : "this is a string",
                  "array" : [
                    1,
                    2,
                    3
                  ],
                  "object" : {
                    "x" : 1
                  }
                }
              }
            }
            """
        XCTAssertEqual(json.sorted(), expected.sorted())
    }
    
    func testEncodeAdditionalProperties() {
        let additionalProperties: [String: JSONValue] = [
            "null": .null,
            "bool": .boolean(true),
            "int": .int(1),
            "double": .double(0.5),
            "string": .string("this is a string"),
            "array": .array([.int(1), .int(2), .int(3)]),
            "object": .object(["x": .int(1)])
        ]
        let model = ServiceModel(name: "name", metadata: [:], additionalProperties: additionalProperties)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(model)
        let json = String(data: data, encoding: .utf8)!
        let expected = """
            {
              "name" : "name",
              "metadata" : {

              },
              "null" : null,
              "bool" : true,
              "int" : 1,
              "double" : 0.5,
              "string" : "this is a string",
              "array" : [
                1,
                2,
                3
              ],
              "object" : {
                "x" : 1
              }
            }
            """
        XCTAssertEqual(json.sorted(), expected.sorted())
    }
    
    func testEncodeOptional() {
        let metadata: [String: JSONValue] = [
            "null": .null,
            "bool": .boolean(true),
            "int": .int(1),
            "double": .double(0.5),
            "string": .string("this is a string"),
            "array": .array([.int(1), .int(2), .int(3)]),
            "object": .object(["x": .int(1)])
        ]
        let additionalProperties: [String: JSONValue] = [
            "null": .null,
            "bool": .boolean(true),
            "int": .int(1),
            "double": .double(0.5),
            "string": .string("this is a string"),
            "array": .array([.int(1), .int(2), .int(3)]),
            "object": .object(["x": .int(1)])
        ]
        let model = ServiceModelOptional(name: "name", metadata: metadata, additionalProperties: additionalProperties)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(model)
        let json = String(data: data, encoding: .utf8)!
        let expected = """
            {
              "name" : "name",
              "metadata" : {
                "null" : null,
                "bool" : true,
                "int" : 1,
                "double" : 0.5,
                "string" : "this is a string",
                "array" : [
                  1,
                  2,
                  3
                ],
                "object" : {
                  "x" : 1
                }
              },
              "null" : null,
              "bool" : true,
              "int" : 1,
              "double" : 0.5,
              "string" : "this is a string",
              "array" : [
                1,
                2,
                3
              ],
              "object" : {
                "x" : 1
              }
            }
            """
        XCTAssertEqual(json.sorted(), expected.sorted())
    }
    
    func testEncodeOptionalEmpty() {
        let model = ServiceModelOptional(name: "", metadata: nil, additionalProperties: [:])
        let encoder = JSONEncoder()
        let data = try! encoder.encode(model)
        let json = String(data: data, encoding: .utf8)!
        let expected = "{\"name\":\"\"}"
        XCTAssertEqual(json.sorted(), expected.sorted())
    }
    
    func testEncodeOptionalNil() {
        let model = ServiceModelOptional(name: nil, metadata: nil, additionalProperties: nil)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(model)
        let json = String(data: data, encoding: .utf8)!
        let expected = "{}"
        XCTAssertEqual(json.sorted(), expected.sorted())
    }

    func testDecodeMetadata() {
        let json = """
            {
              "name" : "name",
              "metadata" : {
                "null" : null,
                "bool" : true,
                "int" : 1,
                "double" : 0.5,
                "string" : "this is a string",
                "array" : [1, 2, 3],
                "object" : {"x" : 1}
              }
            }
            """
        let data = json.data(using: .utf8)!
        let model = try! JSONDecoder().decode(ServiceModel.self, from: data)
        XCTAssertEqual(model.name, "name")
        XCTAssertEqual(model.metadata["null"], .null)
        XCTAssertEqual(model.metadata["bool"], .boolean(true))
        XCTAssertEqual(model.metadata["int"], .int(1))
        XCTAssertEqual(model.metadata["double"], .double(0.5))
        XCTAssertEqual(model.metadata["string"], .string("this is a string"))
        XCTAssertEqual(model.metadata["array"], .array([.int(1), .int(2), .int(3)]))
        XCTAssertEqual(model.metadata["object"], .object(["x": .int(1)]))
        XCTAssertEqual(model.additionalProperties.count, 0)
    }

    func testDecodeCustom() {
        let json = """
            {
              "name" : "name",
              "metadata" : {
                "custom" : {
                  "null": null,
                  "boolean" : true,
                  "int" : 1,
                  "double" : 0.5,
                  "string" : "this is a string",
                  "array" : [
                    1,
                    2,
                    3
                  ],
                  "object" : {
                    "x" : 1
                  }
                }
              }
            }
            """
        let data = json.data(using: .utf8)!
        let model = try! JSONDecoder().decode(ServiceModel.self, from: data)
        let custom = try! model.metadata["custom"]!.toValue(CustomModel.self)
        XCTAssertEqual(model.name, "name")
        XCTAssertEqual(custom.null, nil)
        XCTAssertEqual(custom.boolean, true)
        XCTAssertEqual(custom.int, 1)
        XCTAssertEqual(custom.double, 0.5)
        XCTAssertEqual(custom.string, "this is a string")
        XCTAssertEqual(custom.array, [1, 2, 3])
        XCTAssertEqual(custom.object, ["x": 1])
        XCTAssertEqual(model.additionalProperties.count, 0)
    }

    func testDecodeAdditionalProperties() {
        let json = """
            {
              "name" : "name",
              "metadata" : { },
              "null" : null,
              "bool" : true,
              "int" : 1,
              "double" : 0.5,
              "string" : "this is a string",
              "array" : [1, 2, 3],
              "object" : { "x" : 1 }
            }
            """
        let data = json.data(using: .utf8)!
        let model = try! JSONDecoder().decode(ServiceModel.self, from: data)
        XCTAssertEqual(model.name, "name")
        XCTAssertEqual(model.metadata.count, 0)
        XCTAssertEqual(model.additionalProperties["null"], .null)
        XCTAssertEqual(model.additionalProperties["bool"], .boolean(true))
        XCTAssertEqual(model.additionalProperties["int"], .int(1))
        XCTAssertEqual(model.additionalProperties["double"], .double(0.5))
        XCTAssertEqual(model.additionalProperties["string"], .string("this is a string"))
        XCTAssertEqual(model.additionalProperties["array"], .array([.int(1), .int(2), .int(3)]))
        XCTAssertEqual(model.additionalProperties["object"], .object(["x": .int(1)]))
    }

    func testDecodeOptional() {
        let json = """
            {
              "name" : "name",
              "metadata" : {
                "null" : null,
                "bool" : true,
                "int" : 1,
                "double" : 0.5,
                "string" : "this is a string",
                "array" : [1, 2, 3],
                "object" : {"x" : 1}
              },
              "null" : null,
              "bool" : true,
              "int" : 1,
              "double" : 0.5,
              "string" : "this is a string",
              "array" : [1, 2, 3],
              "object" : { "x" : 1 }
            }
            """
        let data = json.data(using: .utf8)!
        let model = try! JSONDecoder().decode(ServiceModelOptional.self, from: data)
        let metadata = model.metadata!
        let additionalProperties = model.additionalProperties!
        XCTAssertEqual(model.name!, "name")
        XCTAssertEqual(metadata["null"], .null)
        XCTAssertEqual(metadata["bool"], .boolean(true))
        XCTAssertEqual(metadata["int"], .int(1))
        XCTAssertEqual(metadata["double"], .double(0.5))
        XCTAssertEqual(metadata["string"], .string("this is a string"))
        XCTAssertEqual(metadata["array"], .array([.int(1), .int(2), .int(3)]))
        XCTAssertEqual(metadata["object"], .object(["x": .int(1)]))
        XCTAssertEqual(additionalProperties["null"], .null)
        XCTAssertEqual(additionalProperties["bool"], .boolean(true))
        XCTAssertEqual(additionalProperties["int"], .int(1))
        XCTAssertEqual(additionalProperties["double"], .double(0.5))
        XCTAssertEqual(additionalProperties["string"], .string("this is a string"))
        XCTAssertEqual(additionalProperties["array"], .array([.int(1), .int(2), .int(3)]))
        XCTAssertEqual(additionalProperties["object"], .object(["x": .int(1)]))
    }

    func testDecodeOptionalEmpty() {
        let json = "{\"name\":\"\"}"
        let data = json.data(using: .utf8)!
        let model = try! JSONDecoder().decode(ServiceModelOptional.self, from: data)
        XCTAssertEqual(model.name, "")
        XCTAssertNil(model.metadata)
        XCTAssertNil(model.additionalProperties)
    }

    func testDecodeOptionalNil() {
        let json = "{ }"
        let data = json.data(using: .utf8)!
        let model = try! JSONDecoder().decode(ServiceModelOptional.self, from: data)
        XCTAssertNil(model.name)
        XCTAssertNil(model.metadata)
        XCTAssertNil(model.additionalProperties)
    }
}

//===----------------------------------------------------------------------===//
// ServiceModel
//===----------------------------------------------------------------------===//

private struct ServiceModel: Codable {
    let name: String
    let metadata: [String: JSONValue]
    let additionalProperties: [String: JSONValue]

    init(name: String, metadata: [String: JSONValue], additionalProperties: [String: JSONValue]) {
        self.name = name
        self.metadata = metadata
        self.additionalProperties = additionalProperties
    }

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case metadata = "metadata"
        static let allValues = [name, metadata]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dynamic = try decoder.container(keyedBy: DynamicKeys.self)
        name = try container.decode(String.self, forKey: .name)
        metadata = try container.decode([String: JSONValue].self, forKey: .metadata)
        additionalProperties = try dynamic.decode([String: JSONValue].self, excluding: CodingKeys.allValues)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dynamic = encoder.container(keyedBy: DynamicKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(metadata, forKey: .metadata)
        try dynamic.encode(additionalProperties)
    }
}

//===----------------------------------------------------------------------===//
// ServiceModelOptional
//===----------------------------------------------------------------------===//

private struct ServiceModelOptional: Codable {
    let name: String?
    let metadata: [String: JSONValue]?
    let additionalProperties: [String: JSONValue]?

    init(name: String?, metadata: [String: JSONValue]?, additionalProperties: [String: JSONValue]?) {
        self.name = name
        self.metadata = metadata
        self.additionalProperties = additionalProperties
    }

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case metadata = "metadata"
        static let allValues = [name, metadata]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dynamic = try decoder.container(keyedBy: DynamicKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        metadata = try container.decodeIfPresent([String: JSONValue].self, forKey: .metadata)
        additionalProperties = try dynamic.decodeIfPresent([String: JSONValue].self, excluding: CodingKeys.allValues)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var dynamic = encoder.container(keyedBy: DynamicKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try dynamic.encodeIfPresent(additionalProperties)
    }
}

//===----------------------------------------------------------------------===//
// CustomModel
//===----------------------------------------------------------------------===//

private struct CustomModel: Codable {
    let null: String?
    let boolean: Bool
    let int: Int
    let double: Double
    let string: String
    let array: [Int]
    let object: [String: Int]
}
