import SwiftUI

// MARK: - Sustainability Score View
/// Impact visualization — celebrate the user's contribution to sustainable fashion
struct SustainabilityScoreView: View {
    let score: SustainabilityScore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.modaicsWarmSand
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero score section
                        heroSection
                            .padding(.top, 20)
                        
                        // Impact breakdown
                        impactBreakdownSection
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                        
                        // Achievements
                        achievementsSection
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                        
                        // Community impact
                        communityImpactSection
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                        
                        // Tips to improve
                        tipsSection
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Your Impact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                    }
                }
            }
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 24) {
            // Animated score ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(score.accentColor.opacity(0.15), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(score.rating) / 100)
                    .stroke(
                        score.accentColor,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.5), value: score.rating)
                
                // Score
                VStack(spacing: 4) {
                    Text("\(score.rating)")
                        .font(.modaicsDisplayMedium(size: 56))
                        .foregroundColor(.modaicsCharcoalClay)
                    
                    Text("out of 100")
                        .font(.modaicsCaptionRegular(size: 14))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                }
            }
            
            // Level badge
            VStack(spacing: 8) {
                Text(score.level.title)
                    .font(.modaicsDisplayMedium(size: 24))
                    .foregroundColor(score.accentColor)
                
                Text(score.level.description)
                    .font(.modaicsBodyRegular(size: 16))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Impact Breakdown
    private var impactBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Impact Breakdown")
                .font(.modaicsHeadingSemiBold(size: 20))
                .foregroundColor(.modaicsCharcoalClay)
            
            VStack(spacing: 16) {
                ImpactMetricCard(
                    icon: "drop.fill",
                    iconColor: .blue,
                    value: "12,400L",
                    label: "Water saved",
                    description: "Equivalent to 6 months of drinking water",
                    progress: 0.7
                )
                
                ImpactMetricCard(
                    icon: "leaf.fill",
                    iconColor: .green,
                    value: "45.2kg",
                    label: "CO₂ prevented",
                    description: "Like planting 2 trees",
                    progress: 0.6
                )
                
                ImpactMetricCard(
                    icon: "arrow.3.trianglepath",
                    iconColor: .modaicsTerracotta,
                    value: "18",
                    label: "Garments recirculated",
                    description: "Extending the life of quality pieces",
                    progress: 0.8
                )
                
                ImpactMetricCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: .purple,
                    value: "$1,240",
                    label: "Money saved",
                    description: "vs. buying new",
                    progress: 0.5
                )
            }
        }
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Achievements")
                .font(.modaicsHeadingSemiBold(size: 20))
                .foregroundColor(.modaicsCharcoalClay)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 16)], spacing: 16) {
                ForEach(Achievement.allCases) { achievement in
                    AchievementBadge(achievement: achievement, isUnlocked: achievement.rawValue <= score.rating / 20)
                }
            }
        }
    }
    
    // MARK: - Community Impact
    private var communityImpactSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Community Impact")
                .font(.modaicsHeadingSemiBold(size: 20))
                .foregroundColor(.modaicsCharcoalClay)
            
            VStack(spacing: 12) {
                HStack {
                    CommunityStat(value: "156", label: "People connected")
                    Spacer()
                    CommunityStat(value: "12", label: "Stories shared")
                }
                
                Divider()
                    .background(Color.modaicsCharcoalClay.opacity(0.1))
                
                Text("You've helped build a community of conscious fashion lovers. Every exchange strengthens our collective impact.")
                    .font(.modaicsBodyRegular(size: 15))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.7))
                    .lineSpacing(4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
            )
        }
    }
    
    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Level Up Your Impact")
                .font(.modaicsHeadingSemiBold(size: 20))
                .foregroundColor(.modaicsCharcoalClay)
            
            VStack(spacing: 12) {
                TipCard(
                    icon: "camera.fill",
                    title: "Document your pieces",
                    description: "Add photos and stories to increase engagement",
                    points: "+10 points"
                )
                
                TipCard(
                    icon: "person.2.fill",
                    title: "Trade with the community",
                    description: "Direct swaps have the highest sustainability impact",
                    points: "+25 points"
                )
                
                TipCard(
                    icon: "heart.fill",
                    title: "Write meaningful notes",
                    description: "Share the story behind each piece you pass on",
                    points: "+15 points"
                )
            }
        }
    }
}

// MARK: - Impact Metric Card
struct ImpactMetricCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    let description: String
    let progress: Double
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value)
                        .font(.modaicsHeadingSemiBold(size: 20))
                        .foregroundColor(.modaicsCharcoalClay)
                    
                    Spacer()
                    
                    Text(label)
                        .font(.modaicsCaptionMedium(size: 13))
                        .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
                }
                
                Text(description)
                    .font(.modaicsCaptionRegular(size: 13))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.5))
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.modaicsCharcoalClay.opacity(0.1))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(iconColor)
                            .frame(width: geo.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.color.opacity(0.15) : Color.modaicsCharcoalClay.opacity(0.05))
                    .frame(width: 72, height: 72)
                
                Image(systemName: isUnlocked ? achievement.icon : "lock.fill")
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? achievement.color : .modaicsCharcoalClay.opacity(0.3))
            }
            
            Text(achievement.title)
                .font(.modaicsCaptionMedium(size: 12))
                .foregroundColor(isUnlocked ? .modaicsCharcoalClay : .modaicsCharcoalClay.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Community Stat
struct CommunityStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.modaicsHeadingSemiBold(size: 24))
                .foregroundColor(.modaicsTerracotta)
            
            Text(label)
                .font(.modaicsCaptionRegular(size: 14))
                .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
        }
    }
}

// MARK: - Tip Card
struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    let points: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.modaicsDeepOlive)
                .frame(width: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.modaicsBodyMedium(size: 16))
                    .foregroundColor(.modaicsCharcoalClay)
                
                Text(description)
                    .font(.modaicsCaptionRegular(size: 13))
                    .foregroundColor(.modaicsCharcoalClay.opacity(0.6))
            }
            
            Spacer()
            
            Text(points)
                .font(.modaicsCaptionMedium(size: 12))
                .foregroundColor(.modaicsTerracotta)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.modaicsTerracotta.opacity(0.1))
                )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.modaicsDeepOlive.opacity(0.05))
        )
    }
}

// MARK: - Achievement Enum
enum Achievement: Int, CaseIterable, Identifiable {
    case seedling = 1
    case sprout = 2
    case growing = 3
    case blooming = 4
    case flourishing = 5
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .seedling: return "Seedling"
        case .sprout: return "Sprout"
        case .growing: return "Growing"
        case .blooming: return "Blooming"
        case .flourishing: return "Flourishing"
        }
    }
    
    var icon: String {
        switch self {
        case .seedling: return "leaf"
        case .sprout: return "leaf.arrow.triangle.circlepath"
        case .growing: return "tree"
        case .blooming: return "tree.fill"
        case .flourishing: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .seedling: return .green
        case .sprout: return .mint
        case .growing: return .blue
        case .blooming: return .modaicsTerracotta
        case .flourishing: return .purple
        }
    }
}

// MARK: - Sustainability Level Extension
extension SustainabilityLevel {
    var title: String {
        switch self {
        case .seedling: return "Seedling"
        case .growing: return "Growing Green"
        case .blooming: return "In Bloom"
        case .flourishing: return "Fully Flourishing"
        }
    }
    
    var description: String {
        switch self {
        case .seedling:
            return "You're just beginning your sustainable fashion journey. Every small step counts!"
        case .growing:
            return "Your commitment is showing. You're making a real difference!"
        case .blooming:
            return "Beautiful work! Your wardrobe choices are inspiring others."
        case .flourishing:
            return "You're a sustainability champion! Your impact ripples through our community."
        }
    }
}

struct SustainabilityScoreView_Previews: PreviewProvider {
    static var previews: some View {
        SustainabilityScoreView(score: SustainabilityScore(rating: 65, level: .blooming))
    }
}