import AuxRingKit
import SwiftUI

/// Named screen for the live driver. The running UI is the Stats sheet.
struct StatsView: View {
    var body: some View {
        ZStack {
            Color(uiColor: AuxColor.background).ignoresSafeArea()
            VStack(alignment: .leading, spacing: AuxSpace.unit) {
                Text("Stats")
                    .font(Font(AuxType.sectionTitle()))
                    .foregroundStyle(Color(uiColor: AuxColor.ink))
                Text("Sealed days, rings, and the day streak.")
                    .font(Font(AuxType.body()))
                    .foregroundStyle(Color(uiColor: AuxColor.muted))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(AuxSpace.step(2))
        }
    }
}
