//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by Mahesh Adhikari
//

import Foundation

class FlickrAPI {
    static let numberPerPage = 25

    enum Endpoint : String {
        case baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=8389e43793552d7e77babb14e32293a4&radius=5&radius_units=km&per_page=25"
        
        var url : URL? {
            return URL(string: self.rawValue)
        }
    }
    
    class func locationSearchURL(lat: Double, lon: Double, page: Int) -> URL? {
        // example URL for each with lat/lon : https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=cf5e26ab866d8f7e61b97552cf489baa&lat=48.856&lon=2.353&radius=2&radius_units=miles&per_page=50&page=1
        let fullURL = Endpoint.baseURL.rawValue + "&lat=\(lat)&lon=\(lon)&page=\(page)"
        return URL(string: fullURL)
    }
    
    class func getPhotosForLocation(pin: Pin, completion: @escaping (Pin, [PhotoInfo], Error?) -> Void) {
        //TO DO: Add random number generator to page.
        let page = Int.random(in: 1...10)
        let url = self.locationSearchURL(lat: pin.latitude, lon: pin.longitude, page: page)
        let urlRequest = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(pin, [], error)
                }
                return
            }
            // XML Parser!
            let xmlParser = XMLParser(data: data)
            let delegateStack = ParserDelegateStack(xmlParser: xmlParser)

            let responseParser = ResponseParser(tagName: "photos")
            delegateStack.push(responseParser)

            if xmlParser.parse() {
                print("Done parsing")
                print(responseParser.result!.total)
                DispatchQueue.main.async {
                    completion(pin, responseParser.result!.photos, nil)
                }
            } else {
                print("Invalid xml", xmlParser.parserError?.localizedDescription ?? "")
                DispatchQueue.main.async {
                    completion(pin,[], error)
                }
            }
        }
        task.resume()
    }
    
    class func imageURL(farm: Int, server: Int, id: String, secret: String) -> URL {
        // https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        let url = URL(string: urlString)!
        
        return url
    }
}
