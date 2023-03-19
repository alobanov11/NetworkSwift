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

First of all, you need to create an object conforms to `IURLProvider` protocol. It provides baseURL & baseHeaders which could be different & depended on Endpoint (e.g. .v1, .v2, .staging etc.)

Create a request:

```swift
public struct SomeRequest: INetworkRequest {
    public let path = "some/request"
    public let method: HTTPMethod = .get
    public let body: HTTPParameters

    init(token: String, refreshToken: String) {
        self.body = [
            "accessToken": token,
            "refreshToken": refreshToken,
        ]
    }

    public func decode(_ data: Data?) throws -> SomeEntity {
        try self.mapEntity(data)
    }
}
```

And then dispatch the request

```swift

let network = NetworkClient(session:, requestBuilder:)

let task = network.dispatch(SomeRequest(:)) { result in
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

NetworkSwift is licensed under the [Apache-2.0 Open Source license](http://choosealicense.com/licenses/apache-2.0/).

You are free to do with it as you please.  We _do_ welcome attribution, and would love to hear from you if you are using it in a project!
