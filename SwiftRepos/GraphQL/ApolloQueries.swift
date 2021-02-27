//
//  ApolloQueries.swift
//  SwiftRepos
//
//  Created by Tochi on 24/02/2021.
//

import Foundation
import Apollo


class ApolloNetwork{
    static let instance = ApolloNetwork()
    private(set) lazy var apollo: ApolloClient = {
        let client = URLSessionClient()
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(client: client, store: store)
        let url = URL(string: "https://api.github.com/graphql")!
        let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: url)
        return ApolloClient(networkTransport: transport, store: store)
    }()
    
    class NetworkInterceptorProvider: LegacyInterceptorProvider {
        override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
            var interceptors = super.interceptors(for: operation)
            interceptors.insert(CustomInterceptor(), at: 0)
            return interceptors
        }
    }

    
    /// Custom Interceptor to accommodate Headers
    class CustomInterceptor: ApolloInterceptor {        
        func interceptAsync<Operation: GraphQLOperation>(
            chain: RequestChain,
            request: HTTPRequest<Operation>,
            response: HTTPResponse<Operation>?,
            completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {
            
            request.addHeader(name: "authorization", value: "Bearer \(gitToken)")

            chain.proceedAsync(request: request,
                               response: response,
                               completion: completion)
        }
    }
    
}
