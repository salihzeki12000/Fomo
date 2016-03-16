//
// Itinerary.swift
// ============================


import UIKit


class Itinerary: NSObject {
    
    var id: String?
    var creator: User?
    var travellers: [User]? 
    var tripName: String?
    var startDate: NSDate?
    var numDays: Int?
    var endDate: NSDate?
    var city: City?
    var coverPhoto: UIImage?
    var days: [Day]?
    var rawData: NSDictionary?
    
    override init() {}
    
    init(dictionary: NSDictionary) {
        if dictionary.count == 0 {
            return
        }
        self.id = dictionary["groupID"] as? String
        self.travellers = User.usersWithArray(dictionary["travellers"] as! [NSDictionary])

        self.tripName = dictionary["tripName"] as? String
        let startDateStr = dictionary["startDate"] as? String
        self.startDate = DateFormatter.dateFromString(startDateStr)
        self.rawData = dictionary
        
        let numDays = dictionary["numDays"] as? Int
        
        let attractions = dictionary["itinerary"] as? [NSDictionary]
    
        self.days = []
        
        var attrStartIndex = 0
        
        for _ in 0...numDays! {
            // TODO(jlee): Check if we have enough attractions to fill itinerary.

            let tripEventsDict: [NSDictionary] = Array(attractions![attrStartIndex...attrStartIndex+3])
            let dayDict: NSDictionary = [
                "tripEvents": tripEventsDict,
            ]
            attrStartIndex = attrStartIndex + 3
            self.days?.append(Day(dictionary: dayDict))
        }
        
        
    }
    
    class func itinerariesWithArray(array: [NSDictionary]) -> [Itinerary] {
        var its = [Itinerary]()
        
        for dictionary in array {
            its.append(Itinerary(dictionary: dictionary))
        }
        
        return its
    }

    
    func numberDays() -> Int {
        return (days?.count)!
    }
    
    func refreshItinerary(completion: (itinerary: Itinerary) -> ()) {
        RecommenderClient.sharedInstance.get_itinerary(self) { (response: Itinerary?, error: NSError?) -> () in
            completion(itinerary: response!)
        }
    }
    
    func createItinerary(completion: (response: Itinerary?, error: NSError?) -> ()) {
        let currentUser = Cache.currentUser
        self.creator = currentUser
        RecommenderClient.sharedInstance.add_itinerary(self, completion: completion)
    }
    
    func getLatestItineraryForCurrentUser(completion: (response: Itinerary) -> ()) {
        let currentUser = Cache.currentUser
        RecommenderClient.sharedInstance.get_itineraries_for_user(currentUser!) { (response: [Itinerary]?, error: NSError?) -> () in
            if let response = response {
                completion(response: response.first!)
            }
        }
    }
    
    class func generateTestInstance() -> Itinerary {
        let itinerary = Itinerary(dictionary: NSDictionary())
        itinerary.id = User.generateTestInstance().email ?? "" + ":FakeItineraryID"
        itinerary.creator = User.generateTestInstance()
        itinerary.travellers = [User.generateTestInstance(), User.generateTestInstance()]
        itinerary.tripName = "San Francisco 2016"

        let today = NSDate()
        let tomorrow = NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: 1,
            toDate: today,
            options: NSCalendarOptions(rawValue: 0))
        
        itinerary.startDate = today
        itinerary.endDate = tomorrow
        itinerary.city = City.generateTestInstance()
        itinerary.coverPhoto = UIImage(named: "SanFrancisco")
        itinerary.days = [Day.generateTestInstance(itinerary.city!), Day.generateTestInstance(itinerary.city!), Day.generateTestInstance(itinerary.city!)]
        
        return itinerary
    }
}
