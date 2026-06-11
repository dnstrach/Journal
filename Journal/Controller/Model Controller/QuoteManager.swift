//
//  QuoteManager.swift
//  Journal
//
//  Created by Dominique Strachan on 2/28/23.
//

import Foundation

class QuoteManager {
    // MARK: - Properties
    
    /// Shared singleton instance
    static let shared = QuoteManager()
    
    /// Base API URL
    let baseURL = URL(string: "https://zenquotes.io/")
    
    /// API path components
    let apiComponent = "api"
    let todayComponent = "today"
    let randomComponent = "random"
    
    /// UserDefaults keys
    let userDefaultKey = "quote"
    let quoteDateKey = "quoteDate"
    
    // MARK: - Network Methods
    
    /// Fetches quote from API
    func fetchQuote(completion: @escaping (Result<Quote, NetworkError>) -> Void) {
        
        // Ensure base URL exists
        guard var url = baseURL else {
            completion(.failure(.baseURLError))
            return
        }
        
        // Build URL:
        // https://zenquotes.io/api/today
        url.append(path: apiComponent)
        url.append(path: todayComponent)
        
        let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        )
        
        guard let builtURL = components?.url else {
            completion(.failure(.builtURLError))
            return
        }
        
        let request = URLRequest(url: builtURL)
        
        print("[QuoteManager] Built URL: \(builtURL.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Handle network errors
            if let error = error {
                completion(.failure(.invalidData(error.localizedDescription)))
                return
            }
            
            // Ensure successful response
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(.statusCode))
                return
            }
            
            // Ensure data exists
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                
                // API returns an array of quotes
                let quotes = try JSONDecoder().decode(
                    [Quote].self,
                    from: data
                )
                
                guard let firstQuote = quotes.first else {
                    completion(.failure(.unableToDecode))
                    return
                }
                
                completion(.success(firstQuote))
                
            } catch {
                print(error)
                completion(.failure(.unableToDecode))
            }
            
        }.resume()
    }
    
    // MARK: - UserDefaults Methods
    
    /// Saves quote and fetch date to UserDefaults
    func saveQuote(quote: Quote) {
        
        do {
            let data = try JSONEncoder().encode(quote)
            
            // Save quote
            UserDefaults.standard.set(
                data,
                forKey: userDefaultKey
            )
            
            // Save current date
            UserDefaults.standard.set(
                Date(),
                forKey: quoteDateKey
            )
            
        } catch {
            print("Unable to Encode Quote (\(error))")
        }
    }
    
    /// Fetches saved quote from UserDefaults
    func fetchSavedQuote() -> Quote? {
        
        guard let data = UserDefaults.standard.data(
            forKey: userDefaultKey
        ) else {
            return nil
        }
        
        do {
            let quote = try JSONDecoder().decode(
                Quote.self,
                from: data
            )
            
            return quote
            
        } catch {
            print("Unable to Decode Quote (\(error))")
            return nil
        }
    }
    
    /// Returns true if a quote has already been fetched today
    func hasQuoteForToday() -> Bool {
        
        guard let savedDate = UserDefaults.standard.object(
            forKey: quoteDateKey
        ) as? Date else {
            return false
        }
        
        return Calendar.current.isDateInToday(savedDate)
    }
    
    /// Optional helper if you ever want to force refresh
    func clearSavedQuote() {
        
        UserDefaults.standard.removeObject(
            forKey: userDefaultKey
        )
        
        UserDefaults.standard.removeObject(
            forKey: quoteDateKey
        )
    }
    
    func fetchRandomQuote(completion: @escaping (Result<Quote, NetworkError>) -> Void) {
        guard var url = baseURL else {
            completion(.failure(.baseURLError))
            return
        }

        url.append(path: apiComponent)
        url.append(path: randomComponent)

        guard let builtURL = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        )?.url else {
            completion(.failure(.builtURLError))
            return
        }

        print("[QuoteManager] Random URL: \(builtURL.absoluteString)")

        URLSession.shared.dataTask(with: builtURL) { data, response, error in
            if let error = error {
                completion(.failure(.invalidData(error.localizedDescription)))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(.statusCode))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let quotes = try JSONDecoder().decode([Quote].self, from: data)

                guard let firstQuote = quotes.first else {
                    completion(.failure(.unableToDecode))
                    return
                }

                completion(.success(firstQuote))
            } catch {
                print(error)
                completion(.failure(.unableToDecode))
            }
        }.resume()
    }
    
}

