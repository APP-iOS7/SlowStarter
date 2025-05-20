
import Foundation

struct Item: Identifiable, Codable {
    var itemId: String
    var category: String?
    var title: String?
    var subtitle: String?
    var price: Int?
    var designURL: String?

    var id: String { itemId }

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case category
        case title
        case subtitle
        case price
        case designURL = "design_url"
    }
}

extension Item {
    static let mock: Item = Item(
        itemId: "45832D0B-5DFC-4A23-BFE9-CF3D7422F0C2",
        category: "badge",
        title: "Completion Badge",
        subtitle: "Awarded for finishing a course",
        price: 100,
        designURL: "https://example.com/item.png"
    )
}
