import SwiftUI

struct KYCReviewView: View {
    let customerId: String
    let nationalId: String

    var body: some View {
        ZStack {
            Color(red: 0.84, green: 0.0, blue: 0.0).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("KYC – Adım 2")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Müşteri No: \(customerId)")
                    .foregroundColor(.white.opacity(0.9))
                Text("TC No: \(nationalId)")
                    .foregroundColor(.white.opacity(0.9))

                // Buraya bir sonraki adımı ekleyeceğiz (PEP/FATCA vb.)
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}




