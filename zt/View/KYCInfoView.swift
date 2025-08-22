import SwiftUI



private struct FieldBox<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .tint(.white)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct KYCInfoView: View {
    @StateObject private var vm: KYCInfoController
    @FocusState private var focusedField: Bool
    @State private var goNext = false
    @State private var showKVKK = false// ➜ yeni sayfaya geçiş
    

    init(customerId: String, nationalId: String) {
        _vm = StateObject(wrappedValue: KYCInfoController(customerId: customerId, nationalId: nationalId))
    }

    var body: some View {
        ZStack {
            Color(red: 0.84, green: 0.0, blue: 0.0).ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Müşteri Bilgileri")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Referans
                        Label("Müşteri No: \(vm.customerId)", systemImage: "person.text.rectangle")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))
                        Label("TC No: \(vm.nationalId)", systemImage: "person.badge.key")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.9))

                        // Alanlar
                        FieldBox { TextField("Ad", text: $vm.firstName).focused($focusedField) }
                        FieldBox { TextField("Soyad", text: $vm.lastName).focused($focusedField) }

                        FieldBox {
                            HStack {
                                Text("Doğum Tarihi")
                                Spacer()
                                DatePicker("", selection: $vm.birthDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                            }
                            .accessibilityElement(children: .combine)
                        }

                        FieldBox {
                            TextField("Telefon", text: $vm.phone)
                                .keyboardType(.phonePad)
                                .focused($focusedField)
                        }
                        FieldBox {
                            TextField("E‑posta", text: $vm.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .focused($focusedField)
                        }
                        FieldBox {
                            TextField("Adres", text: $vm.address, axis: .vertical)
                                .focused($focusedField)
                        }

                        // Uyruk & Ülke
                        SearchablePicker(title: "Uyruk",
                                         options: Lists.nationalities,
                                         selection: $vm.nationality)
                        SearchablePicker(title: "Yaşadığı Ülke",
                                         options: Lists.countries,
                                         selection: $vm.residenceCountry)

                        // Cinsiyet
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Cinsiyet")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Picker("Cinsiyet", selection: $vm.gender) {
                                ForEach(Gender.allCases, id: \.self) { g in
                                    Text(g.rawValue).tag(g)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        Toggle("Herhangi bir suç geçmişim var", isOn: $vm.hasCriminalRecord)
                            .tint(.white)
                            .foregroundColor(.white)

                        // Alttaki butona yer bırak
                        Color.clear.frame(height: 84)
                    }
                    .padding(16)
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .scrollDismissesKeyboard(.interactively)
                }
                
                Button {
                    showKVKK = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: vm.kvkkAccepted ? "checkmark.seal.fill" : "exclamationmark.shield")
                        Text(vm.kvkkAccepted ? "KVKK Onayı Alındı" : "KVKK Metnini Oku ve Onayla")
                            .bold()
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(minHeight: 44)
                    .background(.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // 3) Sheet ekle (View sonuna doğru, .sheet modifier)
                .sheet(isPresented: $showKVKK) {
                    KVKKSheet(
                        text:
                """
                6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında...
                 
                """
                    ) {
                        vm.markKVKKAccepted()
                    }
                }

                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.yellow)
                        .font(.footnote)
                        .padding(.horizontal, 20)
                }
            }

            // NavigationLink: kayıt sonrası yeni sayfaya geç
            NavigationLink("", isActive: $goNext) {
                KYCReviewView(customerId: vm.customerId, nationalId: vm.nationalId)
            }
            .hidden()
        }
        // Alt buton — yalnızca form geçerli olunca görünür
        .safeAreaInset(edge: .bottom) {
            if vm.isValid {
                Button {
                    Task {
                        await vm.save()
                        if vm.didSave { goNext = true }
                    }
                } label: {
                    Text("Devam")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 44)   // daha küçük
                }
                .disabled(vm.isSaving)
                .background(vm.isSaving ? .white.opacity(0.4) : .white)
                .foregroundColor(Color(red: 0.84, green: 0.0, blue: 0.0))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.bottom, 2)   // daha aşağıda dursun
            }
        }
        // Klavye "Done" kaldırıldı (toolbar yok)
        .animation(.easeInOut, value: vm.isSaving)
        .animation(.easeInOut, value: vm.isValid)
    }
}

