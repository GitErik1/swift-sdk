/**
 * Copyright IBM Corporation 2018
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
// swiftlint:disable file_length

import Foundation

/**

 ---
 Language Translator v3 is [available](https://www.ibm.com/watson/developercloud/language-translator/api/v3/). See the
 [migration guide](https://console.bluemix.net/docs/services/language-translator/migrating.html).
 ---
 IBM Watson&trade; Language Translator translates text from one language to another. The service offers multiple
 domain-specific models that you can customize based on your unique terminology and language. Use Language Translator to
 take news from across the globe and present it in your language, communicate with your customers in their own language,
 and more.
 */
public class LanguageTranslator {

    /// The base URL to use when contacting the service.
    public var serviceURL = "https://gateway.watsonplatform.net/language-translator/api"

    /// The default HTTP headers for all requests to the service.
    public var defaultHeaders = [String: String]()

    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private var authMethod: AuthenticationMethod
    private let domain = "com.ibm.watson.developer-cloud.LanguageTranslatorV2"

    /**
     Create a `LanguageTranslator` object.

     - parameter username: The username used to authenticate with the service.
     - parameter password: The password used to authenticate with the service.
     */
    public init(username: String, password: String) {
        self.authMethod = BasicAuthentication(username: username, password: password)
    }

    /**
     Create a `LanguageTranslator` object.

     - parameter apiKey: An API key for IAM that can be used to obtain access tokens for the service.
     - parameter iamUrl: The URL for the IAM service.
     */
    public init(apiKey: String, iamUrl: String? = nil) {
        self.authMethod = IAMAuthentication(apiKey: apiKey, url: iamUrl)
    }

    /**
     Create a `LanguageTranslator` object.

     - parameter accessToken: An access token for the service.
     */
    public init(accessToken: String) {
        self.authMethod = IAMAccessToken(accessToken: accessToken)
    }

    public func accessToken(_ newToken: String) {
        if self.authMethod is IAMAccessToken {
            self.authMethod = IAMAccessToken(accessToken: newToken)
        }
    }

    /**
     If the response or data represents an error returned by the Language Translator service,
     then return NSError with information about the error that occured. Otherwise, return nil.

     - parameter data: Raw data returned from the service that may represent an error.
     - parameter response: the URL response returned from the service.
     */
    private func errorResponseDecoder(data: Data, response: HTTPURLResponse) -> Error {

        let code = response.statusCode
        do {
            let json = try JSONDecoder().decode([String: JSON].self, from: data)
            var userInfo: [String: Any] = [:]
            if case let .some(.string(message)) = json["error_message"] {
                userInfo[NSLocalizedDescriptionKey] = message
            }
            return NSError(domain: domain, code: code, userInfo: userInfo)
        } catch {
            return NSError(domain: domain, code: code, userInfo: nil)
        }
    }

    /**
     Translate.

     Translates the input text from the source language to the target language.

     - parameter text: Input text in UTF-8 encoding. Multiple entries will result in multiple translations in the
       response.
     - parameter modelID: Model ID of the translation model to use. If this is specified, the **source** and
       **target** parameters will be ignored. The method requires either a model ID or both the **source** and
       **target** parameters.
     - parameter source: Language code of the source text language. Use with `target` as an alternative way to select
       a translation model. When `source` and `target` are set, and a model ID is not set, the system chooses a default
       model for the language pair (usually the model based on the news domain).
     - parameter target: Language code of the translation target language. Use with source as an alternative way to
       select a translation model.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter completionHandler: A function executed when the request completes with a successful result or error
     */
    public func translate(
        text: [String],
        modelID: String? = nil,
        source: String? = nil,
        target: String? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping (WatsonResponse<TranslationResult>?, Error?) -> Void)
    {
        // construct body
        let translateRequest = TranslateRequest(text: text, modelID: modelID, source: source, target: target)
        guard let body = try? JSONEncoder().encode(translateRequest) else {
            completionHandler(nil, RestError.serializationError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "application/json"

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + "/v2/translate",
            headerParameters: headerParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject(completionHandler: completionHandler)
    }

    /**
     List identifiable languages.

     Lists the languages that the service can identify. Returns the language code (for example, `en` for English or `es`
     for Spanish) and name of each language.

     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter completionHandler: A function executed when the request completes with a successful result or error
     */
    public func listIdentifiableLanguages(
        headers: [String: String]? = nil,
        completionHandler: @escaping (WatsonResponse<IdentifiableLanguages>?, Error?) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v2/identifiable_languages",
            headerParameters: headerParameters
        )

        // execute REST request
        request.responseObject(completionHandler: completionHandler)
    }

    /**
     Identify language.

     Identifies the language of the input text.

     - parameter text: Input text in UTF-8 format.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter completionHandler: A function executed when the request completes with a successful result or error
     */
    public func identify(
        text: String,
        headers: [String: String]? = nil,
        completionHandler: @escaping (WatsonResponse<IdentifiedLanguages>?, Error?) -> Void)
    {
        // construct body
        // convert body parameter to NSData with UTF-8 encoding
        guard let body = text.data(using: .utf8) else {
            let message = "text could not be encoded to NSData with NSUTF8StringEncoding."
            let userInfo = [NSLocalizedDescriptionKey: message]
            let error = NSError(domain: domain, code: 0, userInfo: userInfo)
            completionHandler(nil, error)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = "text/plain"

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + "/v2/identify",
            headerParameters: headerParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject(completionHandler: completionHandler)
    }

    /**
     List models.

     Lists available translation models.

     - parameter source: Specify a language code to filter results by source language.
     - parameter target: Specify a language code to filter results by target language.
     - parameter defaultModels: If the default parameter isn't specified, the service will return all models (default
       and non-default) for each language pair. To return only default models, set this to `true`. To return only
       non-default models, set this to `false`.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter completionHandler: A function executed when the request completes with a successful result or error
     */
    public func listModels(
        source: String? = nil,
        target: String? = nil,
        defaultModels: Bool? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping (WatsonResponse<TranslationModels>?, Error?) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        if let source = source {
            let queryParameter = URLQueryItem(name: "source", value: source)
            queryParameters.append(queryParameter)
        }
        if let target = target {
            let queryParameter = URLQueryItem(name: "target", value: target)
            queryParameters.append(queryParameter)
        }
        if let defaultModels = defaultModels {
            let queryParameter = URLQueryItem(name: "default", value: "\(defaultModels)")
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + "/v2/models",
            headerParameters: headerParameters,
            queryItems: queryParameters
        )

        // execute REST request
        request.responseObject(completionHandler: completionHandler)
    }

    /**
     Create model.

     Uploads a TMX glossary file on top of a domain to customize a translation model.
     Depending on the size of the file, training can range from minutes for a glossary to several hours for a large
     parallel corpus. Glossary files must be less than 10 MB. The cumulative file size of all uploaded glossary and
     corpus files is limited to 250 MB.

     - parameter baseModelID: The model ID of the model to use as the base for customization. To see available models,
       use the `List models` method.
     - parameter name: An optional model name that you can use to identify the model. Valid characters are letters,
       numbers, dashes, underscores, spaces and apostrophes. The maximum length is 32 characters.
     - parameter forcedGlossary: A TMX file with your customizations. The customizations in the file completely
       overwrite the domain translaton data, including high frequency or high confidence phrase translations. You can
       upload only one glossary with a file size less than 10 MB per call.
     - parameter parallelCorpus: A TMX file that contains entries that are treated as a parallel corpus instead of a
       glossary.
     - parameter monolingualCorpus: A UTF-8 encoded plain text file that is used to customize the target language
       model.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter completionHandler: A function executed when the request completes with a successful result or error
     */
    public func createModel(
        baseModelID: String,
        name: String? = nil,
        forcedGlossary: URL? = nil,
        parallelCorpus: URL? = nil,
        monolingualCorpus: URL? = nil,
        headers: [String: String]? = nil,
        completionHandler: @escaping (WatsonResponse<TranslationModel>?, Error?) -> Void)
    {
        // construct body
        let multipartFormData = MultipartFormData()
        if let forcedGlossary = forcedGlossary {
            multipartFormData.append(forcedGlossary, withName: "forced_glossary")
        }
        if let parallelCorpus = parallelCorpus {
            multipartFormData.append(parallelCorpus, withName: "parallel_corpus")
        }
        if let monolingualCorpus = monolingualCorpus {
            multipartFormData.append(monolingualCorpus, withName: "monolingual_corpus")
        }
        guard let body = try? multipartFormData.toData() else {
            completionHandler(nil, RestError.encodingError)
            return
        }

        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"
        headerParameters["Content-Type"] = multipartFormData.contentType

        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "base_model_id", value: baseModelID))
        if let name = name {
            let queryParameter = URLQueryItem(name: "name", value: name)
            queryParameters.append(queryParameter)
        }

        // construct REST request
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "POST",
            url: serviceURL + "/v2/models",
            headerParameters: headerParameters,
            queryItems: queryParameters,
            messageBody: body
        )

        // execute REST request
        request.responseObject(completionHandler: completionHandler)
    }

    /**
     Delete model.

     Deletes a custom translation model.

     - parameter modelID: Model ID of the model to delete.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter completionHandler: A function executed when the request completes with a successful result or error
     */
    public func deleteModel(
        modelID: String,
        headers: [String: String]? = nil,
        completionHandler: @escaping (WatsonResponse<DeleteModelResult>?, Error?) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct REST request
        let path = "/v2/models/\(modelID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completionHandler(nil, RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "DELETE",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters
        )

        // execute REST request
        request.responseObject(completionHandler: completionHandler)
    }

    /**
     Get model details.

     Gets information about a translation model, including training status for custom models.

     - parameter modelID: Model ID of the model to get.
     - parameter headers: A dictionary of request headers to be sent with this request.
     - parameter completionHandler: A function executed when the request completes with a successful result or error
     */
    public func getModel(
        modelID: String,
        headers: [String: String]? = nil,
        completionHandler: @escaping (WatsonResponse<TranslationModel>?, Error?) -> Void)
    {
        // construct header parameters
        var headerParameters = defaultHeaders
        if let headers = headers {
            headerParameters.merge(headers) { (_, new) in new }
        }
        headerParameters["Accept"] = "application/json"

        // construct REST request
        let path = "/v2/models/\(modelID)"
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completionHandler(nil, RestError.encodingError)
            return
        }
        let request = RestRequest(
            session: session,
            authMethod: authMethod,
            errorResponseDecoder: errorResponseDecoder,
            method: "GET",
            url: serviceURL + encodedPath,
            headerParameters: headerParameters
        )

        // execute REST request
        request.responseObject(completionHandler: completionHandler)
    }

}
