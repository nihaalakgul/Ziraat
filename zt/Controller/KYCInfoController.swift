import Foundation
import SwiftUI

@MainActor
final class KYCInfoController: ObservableObject {
    // Referanslar
    let customerId: String
    let nationalId: String

    // Form alanları
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var birthDate = Date(timeIntervalSince1970: 0)
    @Published var phone = ""
    @Published var email = ""
    @Published var address = ""
    @Published var nationality = ""
    @Published var residenceCountry = ""
    @Published var gender: Gender = .male
    @Published var hasCriminalRecord = false

    // UI durumları
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    // KVKK
    @Published var kvkkAccepted: Bool = false
    let kvkkVersion = "v1.0"
    



    // Bağımlılıklar
    private let svc: FirebaseService

    init(customerId: String, nationalId: String, service: FirebaseService = .shared) {
        self.customerId = customerId
        self.nationalId = nationalId
        self.svc = service
    }

    // Hesaplananlar
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    // Basit validasyon
    var isValid: Bool {
        // Zorunlu alanlar dolu mu?
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty,
              !lastName.trimmingCharacters(in: .whitespaces).isEmpty,
              !phone.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !nationality.isEmpty,
              !residenceCountry.isEmpty
        else { return false }

        // Basit format kontrolleri
        let phoneDigitsOK = phone.filter(\.isNumber).count >= 10
        let emailLikeOK = email.contains("@") && email.contains(".")
        let isAdultOK = age >= 18

        // KVKK şartı eklendi
        return phoneDigitsOK && emailLikeOK && isAdultOK && kvkkAccepted
    }

    func save() async {
        guard isValid else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let profile = KYCProfile(
            customerId: customerId,
            nationalId: nationalId,
            firstName: firstName,
            lastName: lastName,
            birthDate: birthDate,
            phone: phone,
            email: email,
            address: address,
            nationality: nationality,
            residenceCountry: residenceCountry,
            gender: gender,
            hasCriminalRecord: hasCriminalRecord,
            kvkkAccepted: kvkkAccepted,
            kvkkAcceptedAt: kvkkAccepted ? Date() : nil,
            kvkkVersion: kvkkVersion

        )

        do {
            try await svc.upsertKYCProfile(profile)
            didSave = true
        } catch {
            errorMessage = "Bilgiler kaydedilemedi. Lütfen tekrar deneyin."
        }
    }

    // KVKK onayı geldiğinde (sheet'ten) çağır
    func markKVKKAccepted() {
        kvkkAccepted = true
    }
}

