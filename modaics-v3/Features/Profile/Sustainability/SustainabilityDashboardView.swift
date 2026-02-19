import SwiftUI
import Combine

// MARK: - Sustainability Dashboard View
public struct SustainabilityDashboardView: View {
    @ObservedObject public var viewModel: SustainabilityViewModel
    @State private var showFullReport = false
    
    public init(viewModel: SustainabilityViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Impact Dashboard
            impactDashboard
            
            // Eco Points Section
            ecoPointsSection
            
            // Badges Section
            badgesSection
        }
        .padding(20)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $showFullReport) {
            FullReportSheet(viewModel: viewModel)
        }
    }
    
    // MARK: - Impact Dashboard
    private var impactDashboard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.modaicsEco)
                
                Text("YOUR IMPACT")
                    .font(.forestHeadlineSmall)
                    .foregroundColor(.sageWhite)
            }
            
            // Metric Cards
            HStack(spacing: 12) {
                ImpactCard(
                    icon: "drop.fill",
                    value: formatWater(viewModel.waterSavedLiters),
                    label: "Water",
                    change: "+\(Int(viewModel.monthlyChange.water))%",
                    color: .natureTeal
                )
                
                ImpactCard(
                    icon: "cloud.fill",
                    value: "\(Int(viewModel.carbonSavedKg)) kg",
                    label: "CO₂",
                    change: "+\(Int(viewModel.monthlyChange.carbon))%",
                    color: .modaicsEco
                )
                
                ImpactCard(
                    icon: "arrow.3.trianglepath",
                    value: "\(viewModel.itemsCirculated)",
                    label: "Circulated",
                    change: "+\(viewModel.monthlyChange.items) new",
                    color: .luxeGold
                )
            }
            
            // View Full Report Button
            Button(action: { showFullReport = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 14))
                    Text("View Full Report")
                        .font(.forestCaptionMedium)
                }
                .foregroundColor(.luxeGold)
            }
        }
    }
    
    // MARK: - Eco Points Section
    private var ecoPointsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.modaicsEco)
                    
                    Text("ECO POINTS")
                        .font(.forestHeadlineSmall)
                        .foregroundColor(.sageWhite)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.modaicsEco)
                    Text("\(viewModel.ecoPoints)")
                        .font(.forestHeadlineMedium)
                        .foregroundColor(.modaicsEco)
                }
            }
            
            Text("Earned from sustainable actions")
                .font(.forestCaptionMedium)
                .foregroundColor(.sageMuted)
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.modaicsSurfaceHighlight)
                            .frame(height: 8)
                        
                        // Fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.modaicsEco)
                            .frame(width: geometry.size.width * viewModel.progressPercentage, height: 8)
                    }
                }
                .frame(height: 8)
                
                Text("\(viewModel.pointsToNext) points to next reward")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
            }
            
            Divider()
                .background(Color.modaicsSurfaceHighlight)
            
            // How to Earn
            VStack(alignment: .leading, spacing: 12) {
                Text("HOW TO EARN")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.luxeGold)
                
                VStack(spacing: 10) {
                    EcoPointRow(icon: "arrow.left.arrow.right", text: "Items Swapped", points: "+50 pts each", color: .modaicsEco)
                    EcoPointRow(icon: "dollarsign.circle", text: "Second-hand Buy", points: "+25 pts each", color: .modaicsEco)
                    EcoPointRow(icon: "calendar", text: "Event Attendance", points: "+75 pts each", color: .modaicsEco)
                    EcoPointRow(icon: "star.fill", text: "Sustainability Badge", points: "+100 pts", color: .modaicsEco)
                    EcoPointRow(icon: "camera.fill", text: "Garment Story", points: "+30 pts", color: .modaicsEco)
                    EcoPointRow(icon: "gift.fill", text: "Donation", points: "+40 pts", color: .modaicsEco)
                }
            }
            
            // Premium CTA
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                    Text("Upgrade to Premium for 2x pts")
                        .font(.forestCaptionMedium)
                }
                .foregroundColor(.luxeGold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.luxeGold.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Badges Section
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.luxeGold)
                    
                    Text("BADGES")
                        .font(.forestHeadlineSmall)
                        .foregroundColor(.sageWhite)
                }
                
                Spacer()
                
                Text("\(viewModel.earnedBadges.count)/\(SustainabilityBadge.allCases.count)")
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageMuted)
            }
            
            // Badges Grid
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ModaicsSustainabilityBadge.allCases, id: \.self) { badge in
                        BadgeView(
                            badge: badge,
                            isEarned: viewModel.earnedBadges.contains(badge),
                            progress: viewModel.badgeProgress[badge] ?? 0
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Helpers
    private func formatWater(_ liters: Double) -> String {
        if liters >= 1000 {
            return "\(Int(liters / 1000))kL"
        }
        return "\(Int(liters))L"
    }
}

// MARK: - Impact Card
private struct ImpactCard: View {
    let icon: String
    let value: String
    let label: String
    let change: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.forestHeadlineMedium)
                .foregroundColor(.sageWhite)
            
            Text(label)
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
            
            Text(change)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.modaicsEco)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.modaicsEco.opacity(0.15))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.modaicsSurfaceHighlight.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Eco Point Row
private struct EcoPointRow: View {
    let icon: String
    let text: String
    let points: String
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(text)
                    .font(.forestBodySmall)
                    .foregroundColor(.sageWhite)
            }
            
            Spacer()
            
            Text(points)
                .font(.forestCaptionMedium)
                .foregroundColor(.modaicsEco)
        }
    }
}

// MARK: - Badge View
private struct BadgeView: View {
    let badge: ModaicsSustainabilityBadge
    let isEarned: Bool
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isEarned ? badge.color.opacity(0.2) : Color.modaicsSurfaceHighlight)
                    .frame(width: 56, height: 56)
                
                Image(systemName: isEarned ? badge.icon : "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isEarned ? badge.color : .sageMuted.opacity(0.5))
                
                if isEarned {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.modaicsEco)
                                .background(Circle().fill(Color.modaicsBackground))
                        }
                        Spacer()
                    }
                    .frame(width: 56, height: 56)
                }
            }
            
            Text(isEarned ? badge.rawValue : "????")
                .font(.forestCaptionSmall)
                .foregroundColor(isEarned ? .sageWhite : .sageMuted.opacity(0.5))
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

// MARK: - Full Report Sheet
private struct FullReportSheet: View {
    @ObservedObject var viewModel: SustainabilityViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Circularity Score
                        VStack(spacing: 16) {
                            Text("CIRCULARITY SCORE")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.luxeGold)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 12)
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: Double(viewModel.calculateCircularityScore()) / 100)
                                    .stroke(
                                        AngularGradient(
                                            colors: [.modaicsEco, .luxeGold],
                                            center: .center,
                                            startAngle: .degrees(-90),
                                            endAngle: .degrees(270)
                                        ),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 150, height: 150)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 4) {
                                    Text("\(viewModel.calculateCircularityScore())")
                                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                                        .foregroundColor(.sageWhite)
                                    Text("/100")
                                        .font(.forestCaptionMedium)
                                        .foregroundColor(.sageMuted)
                                }
                            }
                            
                            Text(viewModel.calculateCircularityScore() >= 70 ? "Excellent" : viewModel.calculateCircularityScore() >= 40 ? "Good" : "Getting Started")
                                .font(.forestHeadlineSmall)
                                .foregroundColor(.modaicsEco)
                        }
                        .padding(24)
                        .background(Color.modaicsSurface)
                        .cornerRadius(12)
                        
                        // Monthly Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("MONTHLY IMPACT")
                                .font(.forestCaptionMedium)
                                .foregroundColor(.luxeGold)
                            
                            VStack(spacing: 12) {
                                ImpactBreakdownRow(
                                    icon: "drop.fill",
                                    label: "Water Saved",
                                    value: "\(Int(viewModel.waterSavedLiters))L",
                                    equivalent: "≈ \(Int(viewModel.waterSavedLiters / 150)) showers"
                                )
                                
                                ImpactBreakdownRow(
                                    icon: "cloud.fill",
                                    label: "CO₂ Prevented",
                                    value: "\(String(format: "%.1f", viewModel.carbonSavedKg))kg",
                                    equivalent: "≈ \(Int(viewModel.carbonSavedKg / 4.6)) car miles"
                                )
                                
                                ImpactBreakdownRow(
                                    icon: "arrow.3.trianglepath",
                                    label: "Items Circulated",
                                    value: "\(viewModel.itemsCirculated)",
                                    equivalent: "Kept in use, not landfills"
                                )
                            }
                        }
                        .padding(24)
                        .background(Color.modaicsSurface)
                        .cornerRadius(12)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Impact Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.forestCaptionMedium)
                        .foregroundColor(.luxeGold)
                }
            }
        }
    }
}

// MARK: - Impact Breakdown Row
private struct ImpactBreakdownRow: View {
    let icon: String
    let label: String
    let value: String
    let equivalent: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.modaicsEco)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                
                Text(value)
                    .font(.forestHeadlineMedium)
                    .foregroundColor(.sageWhite)
                
                Text(equivalent)
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct SustainabilityDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        SustainabilityDashboardView(viewModel: SustainabilityViewModel())
            .preferredColorScheme(.dark)
    }
}
