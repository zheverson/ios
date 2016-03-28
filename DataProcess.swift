
import Foundation

func encodeURL(url: String) -> NSURL {
    let formatedURL = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let url = NSURL(string: formatedURL!)
    return url!
}
