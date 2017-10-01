//
//  FlickrApi.swift
//  TT_VirtualTourist
//
//  Created by Tigran Tshorokhyan on 9/25/17.
//  Copyright © 2017 Tigran Tshorokhyan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrApi: NSObject {
   
    
    var session: URLSession
    static var numbersOfPages = -99
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    
    func taskForGETMethod(_ methodParameters: [String: AnyObject], completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var parameters = methodParameters
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters as! [String : String]))
        parameters[FlickrParameterKeys.APIKey] = FlickrParameterValues.APIKey as AnyObject
        let urlString = Flickr.APIBaseURL + FlickrApi.escapedParameters(parameters)
        
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if error != nil {
                completionHandler(nil, error! as NSError)
                return
            }
            
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            FlickrApi.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        
        task.resume()
        print("this is the URSString--- \(urlString) ---the end.")
        
        
       return task
    }
    
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        var parsedResult: [String:AnyObject]?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult, nil)
    }
    
    
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    
    private func flickrURLFromParameters(_ parameters: [String: String]) -> URL {
        
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        print("URL--- \(components.url!) ---")
        return components.url!
    }
    
    
    class func sharedInstance() -> FlickrApi {
        struct Singleton {
            static var sharedInstance = FlickrApi()
        }
        return Singleton.sharedInstance
    }
    
}

extension FlickrApi {
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func getPhotos(pin: Pin!, latitude: Double, longitude: Double, withPageNumber: Int, completionHandler: @escaping (_ pages: Int, _ error: NSError?) -> Void) {
        
        var parameters: [String: AnyObject] = [FlickrParameterKeys.SafeSearch:      FlickrParameterValues.UseSafeSearch as AnyObject,
                                               FlickrParameterKeys.Method:          FlickrParameterValues.SearchMethod as AnyObject,
                                               FlickrParameterKeys.APIKey:          FlickrParameterValues.APIKey as AnyObject,
                                               FlickrParameterKeys.Extras:          FlickrParameterValues.MediumURL as AnyObject,
                                               FlickrParameterKeys.Format:          FlickrParameterValues.ResponseFormat as AnyObject,
                                               FlickrParameterKeys.NoJSONCallback:  FlickrParameterValues.DisableJSONCallback as AnyObject,
                                               FlickrParameterKeys.PerPages:        FlickrParameterValues.PerPages as AnyObject,
                                               FlickrParameterKeys.BoundingBox:     bboxString(latitude: latitude, longitude: longitude) as AnyObject]
        
        
        if withPageNumber != -99 {
            parameters[FlickrParameterKeys.Page] = "\(withPageNumber)" as AnyObject
        } else {
            parameters[FlickrParameterKeys.Page] = FlickrParameterValues.Page as AnyObject
        }
        
        
        let _ = taskForGETMethod(parameters as [String : AnyObject]) { (results, error) in
            if error != nil {
                completionHandler(0, error as NSError?)
                return
            }
            
            let photosDictionary = results?[FlickrResponseKeys.Photos] as? [String:AnyObject]
            if let photosArray = photosDictionary?[FlickrResponseKeys.Photo] as? [[String: AnyObject]] {
                let numOfPhotoPages = (photosDictionary?[FlickrResponseKeys.Pages] as? Int)!
                pin?.numOfPages = Int64(numOfPhotoPages)
                if photosArray.count > 0 {
                    for i: Int in 0 ..< photosArray.count {
                        performUIUpdatesOnMain {
                            
                            let photoDictionary = photosArray[i] as [String: AnyObject]
                            let imageUrlString = photoDictionary[FlickrResponseKeys.MediumURL] as? String
                            let newPhoto = Photo(imageURL: imageUrlString!, pin: pin!, insertInto: self.sharedContext)
                            newPhoto.pin = pin!
                            do {
                                try self.sharedContext.save()
                            } catch let error as NSError {
                                completionHandler(0, error)
                                return
                            }
                            
                        }
                    }
                    completionHandler(numOfPhotoPages, nil)
                }
            }
        }
        
    }
    
    func downloadImageFromURLString(_ urlString: String, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        
        let imageURL = URL(string: urlString)
        let request = URLRequest(url: imageURL!)
        let task = session.dataTask(with: request) { (results, response, error) in
            if error == nil {
                completionHandler(results, nil)
            } else {
                completionHandler(nil, error)
            }
        }
        print("downloadImageFromURLString")
        task.resume()
    }
    
    func bboxString(latitude: Double, longitude: Double) -> String {
        let minLon = max(longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
        let minLat = max(latitude - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
        let maxLon = min(longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.1)
        let maxLat = min(latitude + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1)
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
    
    
}


