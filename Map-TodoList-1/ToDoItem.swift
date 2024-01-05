import Foundation
import CoreLocation

// ToDoItem 구조체는 할 일 목록의 각 항목에 대한 정보를 저장합니다.
struct ToDoItem: Codable {
    var id: UUID
    var title: String
    var description: String?
    var coordinate: CLLocationCoordinate2D
    var isCompleted: Bool

    // Codable 프로토콜을 채택함으로써 UserDefaults에 저장하기 쉽게 만듭니다.
    // CLLocationCoordinate2D는 기본적으로 Codable을 채택하지 않으므로, 추가적인 처리가 필요합니다.
    enum CodingKeys: String, CodingKey {
        case id, title, description, isCompleted, latitude, longitude
    }

    init(id: UUID = UUID(), title: String, description: String? = nil, coordinate: CLLocationCoordinate2D, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.coordinate = coordinate
        self.isCompleted = isCompleted
    }

    // CLLocationCoordinate2D를 위한 커스텀 인코딩 및 디코딩
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(isCompleted, forKey: .isCompleted)
    }
}
