import SwiftUI

// MARK: - Location Picker Sheet
struct LocationPickerSheet: View {
    @Binding var location: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Location")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .padding()
                
                TextField("Enter location", text: $location)
                    .font(.forestBodyMedium)
                    .foregroundColor(.sageWhite)
                    .padding()
                    .background(Color.modaicsSurface)
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Spacer()
            }
            .background(Color.modaicsBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.sageMuted)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.luxeGold)
                }
            }
        }
    }
}

// MARK: - Link Item Picker Sheet
struct LinkItemPickerSheet: View {
    @Binding var linkedItem: LinkedItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Link Item")
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                    .padding()
                
                Text("This feature will show your wardrobe items to link")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .background(Color.modaicsBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.sageMuted)
                }
            }
        }
    }
}