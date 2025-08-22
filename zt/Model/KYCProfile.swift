import Foundation

// MARK: - Gender

enum Gender: String, CaseIterable, Codable, Identifiable {
    case male   = "Erkek"
    case female = "Kadın"

    var id: String { rawValue }
}

// MARK: - KYCProfile

struct KYCProfile: Codable, Identifiable {
    // Firestore doc id olarak customerId kullanıyoruz
    var id: String { customerId }

    let customerId: String         // Identity.Customer.id ile eş
    let nationalId: String         // T.C. Kimlik No

    var firstName: String
    var lastName: String
    var birthDate: Date
    var phone: String
    var email: String
    var address: String

    var nationality: String        // Uyruk
    var residenceCountry: String   // Şu an yaşadığı ülke
    var gender: Gender
    var hasCriminalRecord: Bool
    
    var kvkkAccepted: Bool = false
    var kvkkAcceptedAt: Date? = nil
    var kvkkVersion: String? = nil

    // Hesaplanan alanlar
    var fullName: String { "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces) }

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    // Basit kontroller (UI/Controller isterse kullanır)
    var isEmailLike: Bool {
        email.contains("@") && email.contains(".")
    }

    var isPhoneLike: Bool {
        // çok basit: en az 10 rakam
        phone.filter(\.isNumber).count >= 10
    }
}


// MARK: - Lists (uyruk & ülke)

struct Lists {
    static let nationalities: [String] = [
        "Türk","Alman","Amerikan","İngiliz","Fransız","İtalyan","İspanyol",
        "Rus","Azeri","Ukraynalı","Bulgar","Yunan","Romen","Arnavut",
        "Gürcü","Çinli","Japon","Koreli","Hindistanlı","Pakistanlı",
        "İranlı","Suriyeli","Mısırlı"
    ]

    static let countries: [String] = [
        "Türkiye","Almanya","Amerika Birleşik Devletleri","Birleşik Krallık",
        "Fransa","İtalya","İspanya","Rusya","Azerbaycan","Ukrayna",
        "Bulgaristan","Yunanistan","Romanya","Arnavutluk","Gürcistan",
        "Çin","Japonya","Güney Kore","Hindistan","Pakistan",
        "İran","Suriye","Mısır"
    ]
}

