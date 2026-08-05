import Foundation

/// Loads remote images for use in widgets.
///
/// Uses `URLSession` to download image data. Widgets have limited runtime,
/// so this performs a synchronous download with a short timeout.
enum RemoteImageLoader {

    /// Downloads an image from a URL and returns its Data.
    ///
    /// - Parameters:
    ///   - url: The URL to download from.
    ///   - timeout: Maximum time to wait in seconds (default: 5).
    /// - Returns: The image data, or nil if the download failed.
    static func loadImageData(from url: String, timeout: TimeInterval = 5.0) -> Data? {
        guard let imageUrl = URL(string: url) else { return nil }

        let semaphore = DispatchSemaphore(value: 0)
        var resultData: Data?

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: imageUrl) { data, response, error in
            defer { semaphore.signal() }

            guard let data = data, error == nil else { return }
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return }

            resultData = data
        }

        task.resume()
        _ = semaphore.wait(timeout: .now() + timeout)

        return resultData
    }

    /// Downloads an image synchronously (for use in widget timeline providers).
    ///
    /// Widget timeline providers have a limited time budget (typically < 5 seconds).
    /// This method blocks the current thread until the download completes or times out.
    static func loadSync(from url: String) -> Data? {
        return loadImageData(from: url, timeout: 3.0)
    }
}
