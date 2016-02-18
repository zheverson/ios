
import UIKit

struct cell {
    var name: String
    var title: String
    var id: String
    var ratio: CGFloat
}

struct Feeds {
    var feedsData = [cell]()
    mutating func getData(url: String) {
        let nsurl = NSURL(string: url)
        let jsonData = json(nsurl!, type: [[String: AnyObject]]())
        for i in jsonData {
            let name = i["name"] as! String
            let title = i["title"] as! String
            let id = i["id"] as! String
            let ratio = i["ratio"] as! CGFloat
            let feed = cell(name: name, title: title, id: id, ratio: ratio)
            feedsData.append(feed)
        }
    }
}
