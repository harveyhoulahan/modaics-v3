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
            // Impact Dashboard - simplified
            impactDashboard
            
            // Eco Points Section - simplified
            ecoPointsSection
            
            // Badges Section
            badgesSection
        }
        .padding(20)
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.warmDivider, lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
        .sheet(isPresented: $showFullReport) {
            FullReportSheet(viewModel: viewModel)
        }
    }
    
    // MARK: - Impact Dashboard
    private var impactDashboard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header - serif title
            Text("Your impact")
                .font(.editorialSmall)
                .foregroundColor(.sageWhite)
            
            // Simple text metrics - NO emerald gradient icons
            HStack(spacing: 24) {
                ImpactMetric(value: "\(viewModel.ecoPoints)", label: "Eco points")
                ImpactMetric(value: "\(Int(viewModel.carbonSavedKg))kg", label: "CO₂ saved")
                ImpactMetric(value: "\(viewModel.itemsCirculated)", label: "Circulated")
            }
            
            // View Full Report Button
            Button(action: { showFullReport = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 14))
                    Text("View full report")
                        .font(.bodyText(12, weight: .medium))
                }
                .foregroundColor(.agedBrass)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Eco Points Section
    private var ecoPointsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("\(viewModel.ecoPoints)")
                    .font(.bodyText(24, weight: .medium))
                    .foregroundColor(.sageWhite)
                
                Text("points earned")
                    .font(.bodyText(14))
                    .foregroundColor(.warmCharcoal)
                
                Spacer()
            }
            
            Divider()
                .background(Color.warmDivider)
            
            // How to Earn
            VStack(alignment: .leading, spacing: 12) {
                Text("How to earn")
                    .font(.bodyText(12, weight: .medium))
                    .foregroundColor(.agedBrass)
                
                VStack(spacing: 10) {
                    EcoPointRow(icon: "arrow.left.arrow.right", text: "Items swapped", points: "+50 pts")
                    EcoPointRow(icon: "dollarsign.circle", text: "Second-hand buy", points: "+25 pts")
                    EcoPointRow(icon: "calendar", text: "Event attendance", points: "+75 pts")
                    EcoPointRow(icon: "star.fill", text: "Sustainability badge", points: "+100 pts")
                    EcoPointRow(icon: "camera.fill", text: "Garment story", points: "+30 pts")
                    EcoPointRow(icon: "gift.fill", text: "Donation", points: "+40 pts")
                }
            }
        }
    }
    
    // MARK: - Badges Section
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Badges")
                    .font(.bodyText(14, weight: .medium))
                    .foregroundColor(.sageWhite)
                
                Spacer()
                
                Text("\(viewModel.earnedBadges.count)/\(ModaicsSustainabilityBadge.allCases.count)")
                    .font(.bodyText(12))
                    .foregroundColor(.warmCharcoal)
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
}

// MARK: - Impact Metric
private struct ImpactMetric: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.bodyText(18, weight: .medium))
                .foregroundColor(.sageWhite)
            
            Text(label)
                .font(.bodyText(12))
                .foregroundColor(.warmCharcoal)
        }
    }
}

// MARK: - Eco Point Row
private struct EcoPointRow: View {
    let icon: String
    let text: String
    let points: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.agedBrass)
                    .frame(width: 20)
                
                Text(text)
                    .font(.bodyText(13))
                    .foregroundColor(.sageWhite)
            }
            
            Spacer()
            
            Text(points)
                .font(.bodyText(12, weight: .medium))
                .foregroundColor(.agedBrass)
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
                    .fill(isEarned ? Color.agedBrass.opacity(0.2) : Color.modaicsSurfaceHighlight)
                    .frame(width: 56, height: 56)
                
                Image(systemName: isEarned ? badge.icon : "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isEarned ? Color.agedBrass : .sageMuted.opacity(0.5))
                
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
                .font(.bodyText(11))
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
                            Text("Circularity score")
                                .font(.editorialSmall)
                                .foregroundColor(.sageWhite)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.modaicsSurfaceHighlight, lineWidth: 12)
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: Double(viewModel.calculateCircularityScore()) / 100)
                                    .stroke(
                                        Color.agedBrass,
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 150, height: 150)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 4) {
                                    Text("\(viewModel.calculateCircularityScore())")
                                        .font(.bodyText(48, weight: .medium))
                                        .foregroundColor(.sageWhite)
                                    Text("/100")
                                        .font(.bodyText(14))
                                        .foregroundColor(.sageMuted)
                                }
                            }
                            
                            Text(viewModel.calculateCircularityScore() >= 70 ? "Excellent" : viewModel.calculateCircularityScore() >= 40 ? "Good" : "Getting Started")
                                .font(.bodyText(16, weight: .medium))
                                .foregroundColor(.agedBrass)
                        }
                        .padding(24)
                        .background(Color.modaicsSurface)
                        .cornerRadius(12)
                        
                        // Monthly Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Monthly impact")
                                .font(.editorialSmall)
                                .foregroundColor(.sageWhite)
                            
                            VStack(spacing: 12) {
                                ImpactBreakdownRow(
                                    icon: "drop.fill",
                                    label: "Water saved",
                                    value: "\(Int(viewModel.waterSavedLiters))L",
                                    equivalent: "≈ \(Int(viewModel.waterSavedLiters / 150)) showers"
                                )
                                
                                ImpactBreakdownRow(
                                    icon: "cloud.fill",
                                    label: "CO₂ prevented",
                                    value: "\(String(format: "%.1f", viewModel.carbonSavedKg))kg",
                                    equivalent: "≈ \(Int(viewModel.carbonSavedKg / 4.6)) car miles"
                                )
                                
                                ImpactBreakdownRow(
                                    icon: "arrow.3.trianglepath",
                                    label: "Items circulated",
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
            .navigationTitle("Impact report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.bodyText(12, weight: .medium))
                        .foregroundColor(.agedBrass)
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
                .foregroundColor(.agedBrass)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.bodyText(12))
                    .foregroundColor(.sageMuted)
                
                Text(value)
                    .font(.bodyText(16, weight: .medium))
                    .foregroundColor(.sageWhite)
                
                Text(equivalent)
                    .font(.bodyText(11))
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
