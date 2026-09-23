import AuxRingKit
import SwiftUI

/// Named screen for the live driver. The running UI is the Practices sheet.
struct PracticesView: View {
    var body: some View {
        ZStack {
            Color(uiColor: AuxColor.background).ignoresSafeArea()
            VStack(alignment: .leading, spacing: AuxSpace.unit) {
                Text("Practices")
                    .font(Font(AuxType.sectionTitle()))
                    .foregroundStyle(Color(uiColor: AuxColor.ink))
                Text("Sealed and partial days live here.")
                    .font(Font(AuxType.body()))
                    .foregroundStyle(Color(uiColor: AuxColor.muted))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(AuxSpace.step(2))
        }
    }
}
