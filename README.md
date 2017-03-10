# TMDbClient - themoviedb.org with Swift

![badge-swift] ![badge-carthage] ![badge-platforms]

Delightful API interface to interact with [themoviedb.org]'s API.

## Installation

Add _TMDbClient_ via [carthage] by adding the following line to your *Cartfile*:

```
github 'opfeffer/TMDbClient' ~> 1.0
```

## Getting started

In your `AppDelegate` initialize the _TMDbClient_ library by calling

```
TMDbClient.initialize(with: {your_api_key_here})
```

[badge-swift]: https://img.shields.io/badge/swift%20version-3.1-green.svg
[badge-carthage]: https://img.shields.io/badge/compatible-carthage-brightgreen.svg
[badge-platforms]: https://img.shields.io/badge/platforms-iOS-lightgrey.svg
[themoviedb.org]: http://api.themoviedb.org
[carthage]: https://github.com/Carthage/Carthage

## Unavailable Features

Currently, this library only provides read-access to TMDb contents. User Authentication/Guest Sessions are not supported at this time.  

## Todos:
- [ ] build recovery mechanism for `/configuration` request timeouts.
