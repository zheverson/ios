
import UIKit

protocol content {
    var type:contentType {get}
    var id: Int {get}
    
}
extension content {
    
    
    func getItemsBytes() -> NSData {
        let url = NSURL(string: host + "content/\(self.type.rawValue)/\(self.id)/items")
        return NSData(contentsOfURL: url!)!
    }
 
}

struct videoContent: content {
    
    var name: String
    var title: String
    var thumb_ratio: CGFloat
    var timeline: [CGFloat]?
    var items = [[Item]]()
    var id: Int
    var type: contentType
    
    init(name:String, title:String, ratio:CGFloat,type:contentType, id:Int) {
        self.name = name
        self.title = title
        self.thumb_ratio = ratio
        self.id = id
        self.type = .video
    }
    
    mutating func getItems() {
        let bytes = self.getItemsBytes()
        let jsondata = try! NSJSONSerialization.JSONObjectWithData(bytes, options: .AllowFragments) as? [String:AnyObject]
        self.timeline = jsondata!["timeline"] as? [CGFloat]
        let itemsData = jsondata!["items"] as! [[[String:AnyObject]]]
        for i in itemsData {
            var itemSection = [Item]()
            for j in i {
                let name = j["name"] as! String
                let id = j["id"] as! Int
                let price = j["price"] as! Double
                let brand = j["brand"] as! String
                let ratio = j["ratio"] as! CGFloat
                let item = Item(id: id, name: name, brand: brand, price: price, itemImageRatio: ratio)
                itemSection.append(item)
            }
            self.items.append(itemSection)
        }
    }
    
    func videoThumbURL() -> NSURL {
        return NSURL(string: host + "static/image/video_thumbnail/mobile/\(self.id)")!
    }
    
    func getSecondIndex(second:CGFloat) -> Int {
        guard second >= timeline![0] else {
            return -1
        }
        
        for i in 0.stride(to: (timeline?.count)! - 2, by: 2) {
            if case timeline![i]...timeline![i+2] = second {
                return i/2
            }
        }
        return -2
    }
}

enum contentType: String {
    case video
    case image
    case article
}

struct VideoContentArray {
    var feedsData = [videoContent]()
    mutating func getData(url: NSURL) {
   
        let bytes = NSData(contentsOfURL: url)
        
        let jsonData = try! NSJSONSerialization.JSONObjectWithData(bytes!, options: .AllowFragments) as! [[String:AnyObject]]
        for i in jsonData {
            let name = i["name"] as! String
            let title = i["title"] as! String
            let id = i["id"] as! Int
            let ratio = i["ratio"] as! CGFloat
            let feed = videoContent(name: name, title: title, ratio: ratio, type: contentType.video, id: id)
            feedsData.append(feed)
        }
    }
}



struct Item {
    var id: Int
    var color: String?
    var name: String?
    var brand: String?
    var price: Double?
    var itemImageRatio: CGFloat?
    
    var allColor = [Int: String]()
    var allColorArray = [Int]()
    var contents: VideoContentArray?
    
    init(id:Int) {
        self.id = id
    }
    
    init(id:Int, name:String, brand:String, price:Double, itemImageRatio:CGFloat) {
        self.id = id
        self.name = name
        self.brand = brand
        self.price = price
        self.itemImageRatio = itemImageRatio
    }
    
    mutating func getAllColor(completion:([Int:String], [Int]) -> ()){
        let url = NSURL(string: host + "item/\(self.id)/colors")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) {
            data,response,error in
            let jsondata = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [[AnyObject]]
            for i in jsondata! {
                let itemID = i[0] as! Int
                let color = i[1] as! String
                self.allColor[itemID] = color
                self.allColorArray.append(itemID)
            }
    
            completion(self.allColor, self.allColorArray)
        }
        task.resume()
    }
    
    func itemImageURL(type:String) -> NSURL {

        return NSURL(string: imageURL + "item/\(self.id)/\(type)")!
        
    }
    
    mutating func  getContents() {
        let url = NSURL(string: host + "item/\(self.id)/contents")
      
        self.contents = VideoContentArray()
        self.contents!.getData(url!)
    }
}