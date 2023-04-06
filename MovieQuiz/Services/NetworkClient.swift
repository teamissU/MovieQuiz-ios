import Foundation

struct NetworkClient {

    func fetch(url: URL, handler: @escaping (Result<Data, MovieError>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let errorDesc = error?.localizedDescription {
                handler(.failure(.net(desc: errorDesc)))
                return
            }
            
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(.net(desc: "\(response.statusCode)")))
                return
            }
            
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}
