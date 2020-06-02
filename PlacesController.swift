//
//  JSONController.swift
//  Queue
//
//  Created by ghtre on 8/26/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
import GooglePlaces
import MapKit
import GoogleMaps
//import SwiftyJSON
import Contacts
class PlacesController {
    private let decoder = JSONDecoder()
//    private var dataReceived : Data?
    private lazy var sessionConfig = URLSessionConfiguration.default
    private lazy var session = URLSession(configuration: sessionConfig)
    
    private let groupDispatch : DispatchGroup = DispatchGroup()

    internal let kPlacesAPIKey  = ""
    private let k = "i"
    private let i = ""
    weak var delegate_pop_found : PopDataReceivedDelegate?
    
    init(){
        
    }
    private let o = ""
    private let p = ""
    
    func google_get_place_data(place_id:String){
        
        var string_parse = "https://maps.googleapis.com/maps/api/place/details/json?"
        
        var string_conc = ""
        let params_url : [String:String] = [
            "fields" : "name,formatted_address,geometry",
            "place_id": place_id
        ]
        
        for i in params_url {
            string_conc = string_conc + "&" + String(i.key) + "=" + String(i.value)
//            print("string conc: \(string_conc)")
        }
        let full_str = string_parse + string_conc + "&key=\(self.kPlacesAPIKey)"
        let urlString = full_str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string:full_str){
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) {data, response, error in
                if((error) != nil){
                    print("\(String(describing: error))")
                }
                do {
                    let data_string = String(data: data!, encoding: String.Encoding.utf8)
                    if let result = data_string!.data(using: .utf8) {
                        let json = try JSON(data: result)
//                        print("json for places found: \(json)")
                        let json_input = json["result"]
//                        print("results data: \(json_input)")
                        let name = json_input["name"]
                        let addr = json_input["formatted_address"]
//                        print("addr: \(addr)")
                        let geo = json_input["geometry"]["location"]
                        let lat = geo["lat"]
                        let lon = geo["lng"]
                        let lat_double = Double(lat.stringValue)
                        let lon_double = Double(lon.stringValue)
                        let cast_lat = CLLocationDegrees(exactly: lat_double!)
                        let cast_lon = CLLocationDegrees(exactly: lon_double!)
                        let dict = [CNPostalAddressStreetKey:addr.stringValue]
                        let place_mark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: cast_lat!, longitude: cast_lon!),addressDictionary: dict)
//                        print("place mark: \(place_mark)")
                        let map_item = MKMapItem(placemark: place_mark)
                        map_item.name = name.stringValue
                        self.google_get_popular_times(idx: 0, place: map_item, google_search: addr.stringValue, day: Date())
                    }
                } catch {
                    print("Error in serialization: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    func google_get_places_near(idx:Int, lat:Double, lon:Double, radius:Int, day:Date, category:String){
//                print("place search: \(lon)")
            
        var string_parse = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        var string_conc = ""
        let params_url : [String:String] = [
            "opennow" : "true",
            "types" : category,
            "radius" : String(radius),
            "location": String(lat) + "," + String(lon)
        ]
        
        for i in params_url {
            string_conc = string_conc + "&" + String(i.key) + "=" + String(i.value)
//            print("string conc: \(string_conc)")
        }
        let full_str = string_parse + string_conc + "&key=\(self.kPlacesAPIKey)"
        if let url = URL(string:full_str){
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) {data, response, error in
                if((error) != nil){
                    print("\(String(describing: error))")
                }
                do {
                    if let data_parse = data {
                        let data_string = String(data: data_parse, encoding: String.Encoding.utf8)
                        if let result = data_string!.data(using: .utf8) {
                            let json = try JSON(data: result)
    //                        print("json for places: \(json)")
                            let results = json["results"]
                            var idx = 0
                            if results.count == 0 {
                                self.delegate_pop_found?.google_without_results()
                                return
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FinishedPopulatingData"), object: results.count)
                            for key in results{
                                do{
                                    let json_input = try JSON(key.1)
                                    let place_id = json_input["place_id"]
                                    
                                    self.google_get_place_data(place_id: place_id.stringValue)
                                    
                                    idx += 1
                                }catch{
                                    print("error from key: ")
                                }
    //                            print("result: ", i)
                            }
    //                        print("results: \(results)")
                        }
                    }
                } catch {
                    print("Error in serialization: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    
    func parse_photo(photo_ref:String) {
    
        let string_parse = "https://maps.googleapis.com/maps/api/place/photo?"
        var string_conc = ""
        let params_url : [String:String] = [
            "maxwidth":"400",
            "photoreference":photo_ref
        ]
        for i in params_url {
            string_conc = string_conc + "&" + String(i.key) + "=" + String(i.value)
        }
        
//        string_parse = string_parse + string_conc
        let full_str = string_parse + string_conc + "&key=\(self.kPlacesAPIKey)"
        
        let urlString = full_str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string:urlString!){
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) {data, response, error in
                if((error) != nil){
                    print("\(String(describing: error))")
                }
                do {
                    let data_string = String(data: data!, encoding: String.Encoding.utf8)
                    if let result = data_string!.data(using: .utf8) {
                        let json = try JSON(data: result)
//                        print("json is like: \(json)")
                    }
                } catch {
                    print("Error in serialization: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
        
    }
    func get_images(place_id: String, place:MKMapItem) {
        let string_parse = "https://maps.googleapis.com/maps/api/place/details/json?"
        var string_conc = ""
        let params_url : [String:String] = [
            "placeid":place_id
        ]
        for i in params_url {
            string_conc = string_conc + "&" + String(i.key) + "=" + String(i.value)
        }
        
//        string_parse = string_parse + string_conc
        let full_str = string_parse + string_conc + "&key=\(self.kPlacesAPIKey)"
//        print("full string: \(full_str)")
        let urlString = full_str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string:urlString!){
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) {data, response, error in
                if((error) != nil){
                    print("\(String(describing: error))")
                }
                do {
                    let data_string = String(data: data!, encoding: String.Encoding.utf8)
                    if let result = data_string!.data(using: .utf8) {
                        let json = try JSON(data: result)
//                        print("json returned: \(json)")
//                        self.parse_photo(photo_ref:json["photo_reference"].stringValue)
                    }
                }catch {
                    print("Error in serialization: \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    private var count_found = 0
    private let queue = DispatchQueue(label:"RefreshQueue")
    func google_refresh_pop_data(places:[PopularPlace], day:Date, total_places:Int, completion:@escaping() -> Void){
        print("refreshing...")
        for i in places {
            let input = i.mapItem()
            self.google_get_popular_times_refresh(place: input, day: Date(), total_places: total_places)
        }
        queue.async {
            repeat{
                if self.count_found >= total_places {
                    self.count_found = 0
                    
                    break
                }
                sleep(1)
            }while true
            completion()
        }
    }
    
    
    func google_get_popular_times_refresh(place:MKMapItem?, day:Date, total_places:Int){
        var language = "en"
        if let lang = Locale.current.languageCode {
            language = lang
        }
        var place_insert = ""
        place_insert = place!.placemark.title!
        
        
//        print("placemark title: \(place_insert)")
        var string_parse = "https://www.google.com/search?"
        var string_conc = ""
        let params_url : [String:String] = [
            "tbm": "map",
            "tch": "1",
            "hl": language,
            "q": place_insert,
            "pb": "!4m12!1m3!1d4005.9771522653964!2d-122.42072974863942!3d37.8077459796541!2m3!1f0!2f0!3f0!3m2!1i1125!2i976!4f13.1!7i20!10b1!12m6!2m3!5m1!6e2!20e3!10b1!16b1!19m3!2m2!1i392!2i106!20m61!2m2!1i203!2i100!3m2!2i4!5b1!6m6!1m2!1i86!2i86!1m2!1i408!2i200!7m46!1m3!1e1!2b0!3e3!1m3!1e2!2b1!3e2!1m3!1e2!2b0!3e3!1m3!1e3!2b0!3e3!1m3!1e4!2b0!3e3!1m3!1e8!2b0!3e3!1m3!1e3!2b1!3e2!1m3!1e9!2b1!3e2!1m3!1e10!2b0!3e3!1m3!1e10!2b1!3e2!1m3!1e10!2b0!3e4!2b1!4b1!9b0!22m6!1sa9fVWea_MsX8adX8j8AE%3A1!2zMWk6Mix0OjExODg3LGU6MSxwOmE5ZlZXZWFfTXNYOGFkWDhqOEFFOjE!7e81!12e3!17sa9fVWea_MsX8adX8j8AE%3A564!18e15!24m15!2b1!5m4!2b1!3b1!5b1!6b1!10m1!8e3!17b1!24b1!25b1!26b1!30m1!2b1!36b1!26m3!2m2!1i80!2i92!30m28!1m6!1m2!1i0!2i0!2m2!1i458!2i976!1m6!1m2!1i1075!2i0!2m2!1i1125!2i976!1m6!1m2!1i0!2i0!2m2!1i1125!2i20!1m6!1m2!1i0!2i956!2m2!1i1125!2i976!37m1!1e81!42b1!47m0!49m1!3b1"
        ]
        for i in params_url.reversed() {
            string_conc = string_conc + "&" + String(i.key) + "=" + String(i.value)
        }
        string_parse = string_parse + string_conc
        let full_str = string_parse + string_conc + "&key=\(self.k + self.i)"
        let urlString = full_str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string:urlString!){
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) {data, response, error in
                if((error) != nil){
                    print("\(String(describing: error))")
                    self.delegate_pop_found?.increment_place()
                    
                }else{
                    
                
                do {
                    let data_string = String(data: data!, encoding: String.Encoding.utf8)
                    
                    let idx_end = data_string!.index(data_string!.endIndex, offsetBy: -7)
                    let start = data_string!.index(data_string!.startIndex, offsetBy: 0)
                    let string = String(data_string![start...idx_end])
                    let data_scrubbed = string.data(using: String.Encoding.utf8)
                    let response = try JSONSerialization.jsonObject(with: data_scrubbed!, options: [])
                    
                    guard let jsonArray = response as? [String: Any] else {
                          return
                    }
                    let klk = String(jsonArray["d"]! as! String)
                    var my_gd_string = ""
                    var l = 0
                    for i in klk {
                        if l == 4 {
                            my_gd_string.append(i)
                        }else{
                            l += 1
                        }
                    }
//                    print("place refresh: \(place)")
                    if let dataFromString = my_gd_string.data(using: .utf8, allowLossyConversion: false) {
                        
                        let json = try JSON(data: dataFromString)
                        let idxs = [0,1,0,14]
                        let first = self.scrub_array(indexes: idxs, data_array_scrub: json)
//                        print("first: \(first)")
//                        let place_id = self.scrub_array(indexes: [78], data_array_scrub: first)
//                        print("place id: \(place_id)")
//                        self.get_images(place_id: place_id.stringValue, place: place)
//                        exit(0)
                        let idxs_last = [84,0]
                        let idxs_rapid = [84, 7, 1]
                        let idxs_hours = [34]
                        let rapid_change = self.scrub_array(indexes: idxs_rapid, data_array_scrub: first)
                        let popular_times = self.scrub_array(indexes: idxs_last, data_array_scrub: first)
//                        print("===== rapid change refresh is: \(rapid_change)")
//                        print("pop times refresh change are:\(popular_times)")
                        let hours_times = self.scrub_array(indexes: idxs_hours, data_array_scrub: first)
                        let calanderDate = Calendar.current.dateComponents([ .hour, .weekday], from: day)
                        var popular_data : JSON?
                        
                        
                        for i in 0 ..< popular_times[calanderDate.weekday! - 1][1].count {
                            let max_data = popular_times[calanderDate.weekday! - 1][1][i]
                            
                            if max_data[0].stringValue == String(calanderDate.hour!) {
                                popular_data = popular_times[calanderDate.weekday! - 1][1][i]
                            }
                        }
                        
                        if rapid_change.stringValue != "" {
//                            print("rapid change: \(rapid_change.stringValue) place: \(place)")
                            //Update variables
                            DispatchQueue.main.async {
                            let del = UIApplication.shared.delegate as! AppDelegate
                            
                            let filter = del.favorite_places!.filter({
                                   ($0.coordinate.latitude == place!.placemark.coordinate.latitude) && ($0.coordinate.longitude == place!.placemark.coordinate.longitude)
                               })
                                                               
                           if filter.count > 0{
                               if let idx = del.favorite_places!.index(of: filter[0]) {
                                   del.favorite_places![idx].popularity = Float(rapid_change.stringValue)
                               }
                               
                               return
                           }
                            
                            return
                            }
                        }
                        
                        if let check = popular_data?[2].stringValue {
                            DispatchQueue.main.async {
                            let del = UIApplication.shared.delegate as! AppDelegate
                            if check != "" {
                                
                                    let filter = del.favorite_places!.filter({
                                        ($0.coordinate.latitude == place!.placemark.coordinate.latitude) && ($0.coordinate.longitude == place!.placemark.coordinate.longitude)
                                    })
                                    
                                    if filter.count > 0{
                                        if let idx = del.favorite_places!.index(of: filter[0]) {
                                            del.favorite_places![idx].popularity = Float(popular_data![1].stringValue)
                                            del.deleteData(place: del.favorite_places![idx])
                                            del.saveData(place: del.favorite_places![idx])
                                        }
                                        
                                        return
                                    }
                                
                                
                            }else{
                                    
                                let filter = del.favorite_places!.filter({
                                    ($0.coordinate.latitude == place!.placemark.coordinate.latitude) && ($0.coordinate.longitude == place!.placemark.coordinate.longitude)
                                })
                                
                                if filter.count > 0{
                                    if let idx = del.favorite_places!.index(of: filter[0]) {
                                        del.favorite_places![idx].popularity = Float(-1)
                                        del.deleteData(place: del.favorite_places![idx])
                                        del.saveData(place: del.favorite_places![idx])
                                    }
                                    
                                    return
                                }
                            }
                        }
                        }else{
                            DispatchQueue.main.async {
                                let del = UIApplication.shared.delegate as! AppDelegate
                                let filter = del.favorite_places!.filter({
                                    ($0.coordinate.latitude == place!.placemark.coordinate.latitude) && ($0.coordinate.longitude == place!.placemark.coordinate.longitude)
                                })
                                
                                if filter.count > 0{
                                    if let idx = del.favorite_places!.index(of: filter[0]) {
                                        del.favorite_places![idx].popularity = Float(-1)
                                        del.deleteData(place: del.favorite_places![idx])
                                        del.saveData(place: del.favorite_places![idx])
                                    }
                                    
                                    return
                                }
                            }
                            
                        }
//                        print("total: \(total) idx:\(idx)")
                    }
                    
                    self.count_found += 1
                    
                }catch {
                    self.count_found += 1
                    print("Error in serialization: \(error.localizedDescription)")
                }
                }
            }
        task.resume()
        }
    }
    
    func google_get_popular_times(idx:Int, place:MKMapItem?, google_search:String, day:Date){
//        print("place search: \(google_search)")
        var language = "en"
        if let lang = Locale.current.languageCode {
            language = lang
        }
        var place_insert = ""
        if google_search != "" {
            place_insert = google_search
        }else{
            place_insert = place!.placemark.title!
        }
        
        
        
//        print("placemark title: \(place_insert)")
        var string_parse = "https://www.google.com/search?"
        var string_conc = ""
        let params_url : [String:String] = [
            "tbm": "map",
            "tch": "1",
            "hl": language,
            "q": place_insert,
            "pb": "!4m12!1m3!1d4005.9771522653964!2d-122.42072974863942!3d37.8077459796541!2m3!1f0!2f0!3f0!3m2!1i1125!2i976!4f13.1!7i20!10b1!12m6!2m3!5m1!6e2!20e3!10b1!16b1!19m3!2m2!1i392!2i106!20m61!2m2!1i203!2i100!3m2!2i4!5b1!6m6!1m2!1i86!2i86!1m2!1i408!2i200!7m46!1m3!1e1!2b0!3e3!1m3!1e2!2b1!3e2!1m3!1e2!2b0!3e3!1m3!1e3!2b0!3e3!1m3!1e4!2b0!3e3!1m3!1e8!2b0!3e3!1m3!1e3!2b1!3e2!1m3!1e9!2b1!3e2!1m3!1e10!2b0!3e3!1m3!1e10!2b1!3e2!1m3!1e10!2b0!3e4!2b1!4b1!9b0!22m6!1sa9fVWea_MsX8adX8j8AE%3A1!2zMWk6Mix0OjExODg3LGU6MSxwOmE5ZlZXZWFfTXNYOGFkWDhqOEFFOjE!7e81!12e3!17sa9fVWea_MsX8adX8j8AE%3A564!18e15!24m15!2b1!5m4!2b1!3b1!5b1!6b1!10m1!8e3!17b1!24b1!25b1!26b1!30m1!2b1!36b1!26m3!2m2!1i80!2i92!30m28!1m6!1m2!1i0!2i0!2m2!1i458!2i976!1m6!1m2!1i1075!2i0!2m2!1i1125!2i976!1m6!1m2!1i0!2i0!2m2!1i1125!2i20!1m6!1m2!1i0!2i956!2m2!1i1125!2i976!37m1!1e81!42b1!47m0!49m1!3b1"
        ]
        for i in params_url.reversed() {
            string_conc = string_conc + "&" + String(i.key) + "=" + String(i.value)
        }
        string_parse = string_parse + string_conc
        let full_str = string_parse + string_conc + "&key=\(self.k + self.i)"
        let urlString = full_str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string:urlString!){
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) {data, response, error in
                if((error) != nil){
                    print("\(String(describing: error))")
                    
                }
                do {
                    if let data_result = data {
                        
                    
                    let data_string = String(data: data_result, encoding: String.Encoding.utf8)
                    
                    let idx_end = data_string!.index(data_string!.endIndex, offsetBy: -7)
                    let start = data_string!.index(data_string!.startIndex, offsetBy: 0)
                    let string = String(data_string![start...idx_end])
                    let data_scrubbed = string.data(using: String.Encoding.utf8)
                    let response = try JSONSerialization.jsonObject(with: data_scrubbed!, options: [])
                    
                    guard let jsonArray = response as? [String: Any] else {
                          return
                    }
                    let klk = String(jsonArray["d"]! as! String)
                    var my_gd_string = ""
                    var l = 0
                    for i in klk {
                        if l == 4 {
                            my_gd_string.append(i)
                        }else{
                            l += 1
                        }
                    }
                    if let dataFromString = my_gd_string.data(using: .utf8, allowLossyConversion: false) {
                        
                        let json = try JSON(data: dataFromString)
                        let idxs = [0,1,0,14]
                        let first = self.scrub_array(indexes: idxs, data_array_scrub: json)
                        var idx = 0
//                        let place_id = self.scrub_array(indexes: [78], data_array_scrub: first)
//                        print("place id: \(place_id)")
//                        self.get_images(place_id: place_id.stringValue, place: place)
//                        exit(0)
                        let idxs_last = [84,0]
                        let idxs_rapid = [84, 7, 1]
                        let idxs_hours = [34]
                        let rapid_change = self.scrub_array(indexes: idxs_rapid, data_array_scrub: first)
                        let popular_times = self.scrub_array(indexes: idxs_last, data_array_scrub: first)
                            
                        if google_search != "" {
                            let phone_number = self.scrub_array_phonenumber(data_array_scrub: first)
                            place?.phoneNumber = phone_number
                        }
                        
                        let hours_times = self.scrub_array(indexes: idxs_hours, data_array_scrub: first)
                        let calanderDate = Calendar.current.dateComponents([ .hour, .weekday], from: day)
                        var popular_data : JSON?
                        
                        
                        for i in 0 ..< popular_times[calanderDate.weekday! - 1][1].count {
                            let max_data = popular_times[calanderDate.weekday! - 1][1][i]
                            
                            if max_data[0].stringValue == String(calanderDate.hour!) {
                                popular_data = popular_times[calanderDate.weekday! - 1][1][i]
                            }
                        }
                        if rapid_change.stringValue != "" {
//                            print("rapid change: \(rapid_change.stringValue) place: \(place)")
                            let int : Dictionary<MKMapItem,JSON> = [place!:rapid_change]
                            self.delegate_pop_found?.pop_data_received(data: int, business_hours: hours_times[4][0][1])
                            return
                        }
                        
                        if let check = popular_data?[2].stringValue {
                            if check != "" {
                                let int : Dictionary<MKMapItem,JSON> = [place!:popular_data![1]]
                                self.delegate_pop_found?.pop_data_received(data: int, business_hours: hours_times[4][0][1])
                            }else{
                                self.delegate_pop_found?.none_found(map_item: place!, none_flag: false, business_hours: hours_times[4][0][1])
                            }
                        }else{
                            self.delegate_pop_found?.none_found(map_item: place!, none_flag: true, business_hours: hours_times[4][0][1])
                        }
//                        print("total: \(total) idx:\(idx)")
                    }
                        }
                }catch {
                    print("Error in serialization: \(error.localizedDescription)")
                }
            }
        task.resume()
        }
    }
    func scrub_array_phonenumber(data_array_scrub:JSON)->String{
//        for i in data_array_scrub {
//            print("Data is: \(i.1)")
//        }
        return data_array_scrub[90][0].stringValue
    }
    func scrub_array(indexes:[Int],data_array_scrub:JSON) -> JSON {
        var result = data_array_scrub
        for i in indexes{
            result = result[i]
        }
        return result
    }
}


