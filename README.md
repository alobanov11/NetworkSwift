# NetworkSwift


**NetworkSwift** a plain, simple and convenient wrapper around `URLSession` that supports common needs. A library that is small enough to read in one go but useful enough to include in any project.

- Super friendly API
- No external dependencies
- Optimized for unit testing
- Minimal implementation
- Simple request cancellation
- Cancelable requests
- Multipart requests



## How to use

First of all, you need to create an object conforms to `INetworkDataProvider` protocol. It provides baseURL & baseHeaders which could be different & depended on RequestApi (e.g. .v1, .v2, .staging etc.)

```swift
public final class NetworkDataProvider: INetworkDataProvider {
    public func baseURL(for api: RequestAPI) -> String? {
        switch api {
        case .v2:
            return Urls.productionV2
        default:
            return Urls.productionV1
        }
    }

    public func baseHeaders(for _: RequestAPI) -> [String: String] {
        var headers = [String: String]()

        if let accessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        return headers
    }
}

```

Then just create a request

```swift
public final class SomeRequest: Request<SomeEntity> {
    public override var api: RequestAPI {
        .v2
    }

    public override func parameters() -> RequestParameters {
        .init(
            path: String,
            method: HTTPMethod,
            contentType: ContentType, // json / formURLEncoded / multipart([MultipartData])
            query: [String: Any]?,
            body: [String: Any]?,
            headers: [String: String]?
        )
    }

    public override func encode(_ data: Data?) throws -> SomeEntity {
        try self.mapSomeEntity(data)
    }
}
```

And dispatch the request

```swift

let dispatcher = NetworkDispatcher(urlSession:)
let dataProvider = NetworkDataProvider()
let network = Network(dataProvider:dispatcher:)

let task = network.dispatch(GetProfileRequest(id:)) { result in
    /// Swift.Result
}

task.cancel()
```

## Requirements

ReactSwift supports **iOS 9 and up**, and can be compiled with **Swift 4.2 and up**.



## Installation

### Swift Package Manager

The ReactSwift package URL is:

```
`https://github.com/alobanov11/NetworkSwift`
```



## License

Lasso is licensed under the [Apache-2.0 Open Source license](http://choosealicense.com/licenses/apache-2.0/).

You are free to do with it as you please.  We _do_ welcome attribution, and would love to hear from you if you are using it in a project!
