import Foundation
import Result

@available(*, unavailable, renamed: "MoyaError", message: "Moya.Error has been renamed to MoyaError in version 8.0.0")
public typealias Error = MoyaError

extension Endpoint {
    @available(*, unavailable, renamed: "adding(newParameters:)")
    public func endpointByAddingParameters(_ parameters: [String: AnyObject]) -> Endpoint<Target> { fatalError() }

    @available(*, unavailable, renamed: "adding(newHTTPHeaderFields:)")
    public func endpointByAddingHTTPHeaderFields(_ httpHeaderFields: [String: String]) -> Endpoint<Target> { fatalError() }

    @available(*, unavailable, renamed: "adding(newParameterEncoding:)")
    public func endpointByAddingParameterEncoding(_ newParameterEncoding: Moya.ParameterEncoding) -> Endpoint<Target> { fatalError() }

    @available(*, unavailable, renamed: "adding(parameters:httpHeaderFields:parameterEncoding:)")
    public func endpointByAdding(_ parameters: [String: AnyObject]? = nil, httpHeaderFields: [String: String]? = nil, parameterEncoding: Moya.ParameterEncoding? = nil)  -> Endpoint<Target> { fatalError() }
}

@available(*, unavailable, renamed: "MultiTarget", message: "StructTarget has been renamed to MultiTarget in version 8.0.0")
enum StructTarget { }

extension MoyaProvider {
    @available(*, unavailable, renamed: "notifyPluginsOfImpendingStub(for:target:)")
    internal final func notifyPluginsOfImpendingStub(_ request: URLRequest, target: Target) { fatalError() }
}

extension Response {
    @available(*, unavailable, renamed: "filter(statusCodes:)")
    public func filterStatusCodes(_ range: ClosedRange<Int>) throws -> Response { fatalError() }

    @available(*, unavailable, renamed: "filter(statusCode:)")
    public func filterStatusCode(_ code: Int) throws -> Response { fatalError() }
}

extension PluginType {
    @available(*, unavailable, renamed: "willSend(_:)")
    func willSendRequest(_ request: RequestType, target: TargetType) { fatalError() }

    @available(*, unavailable, renamed: "didReceive(_:)")
    func didReceiveResponse(_ result: Result<Moya.Response, MoyaError>, target: TargetType) { fatalError() }
}
