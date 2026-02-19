import SwiftUI

// MARK: - Profile Wardrobe Content View
public struct ProfileWardrobeContentView: View {
    @ObservedObject public var viewModel: ProfileWardrobeViewModel
    
    public init(viewModel: ProfileWardrobeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Sub-tabs
            wardrobeSubTabs
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Content
            if viewModel.filteredWardrobe.isEmpty {
                EmptyStateView(
                    icon: "hanger",
                    title: "No \(viewModel.selectedWardrobeTab.label) Items",
                    message: emptyStateMessage
                )
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding(.horizontal, 20)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(viewModel.filteredWardrobe) { item in
                        WardrobeItemCard(item: item)
                            .onTapGesture {
                                viewModel.selectedItem = item
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteItem(item)
                                    }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Wardrobe Sub Tabs
    private var wardrobeSubTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProfileWardrobeViewModel.WardrobeTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedWardrobeTab = tab
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 12))
                            Text(tab.label)
                                .font(.forestCaptionSmall)
                            
                            let count = viewModel.itemCount(for: tab)
                            if count > 0 {
                                Text("(\(count))")
                                    .font(.forestCaptionSmall)
                            }
                        }
                        .foregroundColor(viewModel.selectedWardrobeTab == tab ? .luxeGold : .sageMuted)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedWardrobeTab == tab
                            ? Color.luxeGold.opacity(0.15)
                            : Color.modaicsSurface
                        )
                        .overlay(
                            Capsule()
                                .stroke(viewModel.selectedWardrobeTab == tab ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var emptyStateMessage: String {
        switch viewModel.selectedWardrobeTab {
        case .active:
            return "Your wardrobe is empty. List your first piece to get started."
        case .sold:
            return "No sold items yet."
        case .swapped:
            return "No swapped items yet."
        case .rented:
            return "No rented items yet."
        }
    }
}

// MARK: - Wardrobe Item Card
public struct WardrobeItemCard: View {
    let item: WardrobeItem
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack {
                Rectangle()
                    .fill(Color.modaicsSurfaceHighlight)
                    .aspectRatio(1.3, contentMode: .fill)
                
                Image(systemName: "photo")
                    .font(.system(size: 32))
                    .foregroundColor(.sageSubtle)
                
                if item.isSold {
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                        
                        Text("SOLD")
                            .font(.forestCaptionMedium)
                            .fontWeight(.bold)
                            .foregroundColor(.luxeGold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.modaicsBackground.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
            }
            .frame(height: 120)
            .clipped()
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.forestCaptionMedium)
                    .foregroundColor(.sageWhite)
                    .lineLimit(1)
                
                Text("\(item.brand) · Size \(item.size)")
                    .font(.forestCaptionSmall)
                    .foregroundColor(.sageMuted)
                    .lineLimit(1)
                
                HStack {
                    if item.isSold {
                        Text(item.price, format: .currency(code: "USD"))
                            .font(.forestBodySmall)
                            .foregroundColor(.sageMuted)
                            .strikethrough()
                    } else {
                        Text(item.price, format: .currency(code: "USD"))
                            .font(.forestBodySmall)
                            .fontWeight(.bold)
                            .foregroundColor(.luxeGold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        
                        Text(statusText)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.sageMuted)
                    }
                }
            }
            .padding(10)
        }
        .background(Color.modaicsSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.modaicsSurfaceHighlight, lineWidth: 0.5)
        )
    }
    
    private var statusColor: Color {
        switch item.status {
        case .listed: return .modaicsEco
        case .available: return .modaicsSurfaceHighlight
        case .sold: return .luxeGold
        case .swapped: return .blue
        case .rented: return .purple
        }
    }
    
    private var statusText: String {
        switch item.status {
        case .listed: return "Listed"
        case .available: return "Available"
        case .sold: return "Sold"
        case .swapped: return "Swapped"
        case .rented: return "Rented"
        }
    }
}

// MARK: - Saved Items View
public struct SavedItemsView: View {
    @ObservedObject public var viewModel: ProfileWardrobeViewModel
    
    public init(viewModel: ProfileWardrobeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Filter pills
            savedFilterPills
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Content
            if viewModel.filteredSaved.isEmpty {
                EmptyStateView(
                    icon: "heart",
                    title: "No Saved Items",
                    message: "Heart items you love to see them here."
                )
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding(.horizontal, 20)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(viewModel.filteredSaved) { item in
                        ZStack(alignment: .topTrailing) {
                            WardrobeItemCard(item: item)
                            
                            // Heart overlay
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.luxeGold)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.modaicsBackground.opacity(0.8))
                                )
                                .padding(8)
                        }
                        .onTapGesture {
                            viewModel.selectedItem = item
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.unsaveItem(item)
                                }
                            } label: {
                                Label("Unsave", systemImage: "heart.slash")
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var savedFilterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ProfileWardrobeViewModel.SavedFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedSavedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(.forestCaptionSmall)
                            .foregroundColor(viewModel.selectedSavedFilter == filter ? .sageWhite : .sageMuted)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedSavedFilter == filter
                                ? Color.luxeGold.opacity(0.2)
                                : Color.modaicsSurface
                            )
                            .overlay(
                                Capsule()
                                    .stroke(viewModel.selectedSavedFilter == filter ? Color.luxeGold : Color.modaicsSurfaceHighlight, lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Activity View
public struct ActivityView: View {
    @ObservedObject public var viewModel: ProfileWardrobeViewModel
    
    public init(viewModel: ProfileWardrobeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        LazyVStack(spacing: 0) {
            let groupedActivities = groupActivitiesByDate()
            
            ForEach(Array(groupedActivities.keys.sorted()), id: \.self) { section in
                VStack(alignment: .leading, spacing: 0) {
                    // Section Header
                    Text(section.uppercased())
                        .font(.forestCaptionMedium)
                        .foregroundColor(.luxeGold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    
                    // Activities
                    ForEach(groupedActivities[section] ?? []) { activity in
                        ActivityRow(activity: activity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        
                        Divider()
                            .background(Color.modaicsSurfaceHighlight)
                            .padding(.leading, 68)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func groupActivitiesByDate() -> [String: [ActivityItem]] {
        var grouped: [String: [ActivityItem]] = [:]
        
        let calendar = Calendar.current
        let now = Date()
        
        for activity in viewModel.activityFeed {
            let section: String
            
            if calendar.isDateInToday(activity.timestamp) {
                section = "Today"
            } else if calendar.isDateInYesterday(activity.timestamp) {
                section = "Yesterday"
            } else if calendar.isDate(activity.timestamp, equalTo: now, toGranularity: .weekOfYear) {
                section = "This Week"
            } else {
                section = "Earlier"
            }
            
            grouped[section, default: []].append(activity)
        }
        
        return grouped
    }
}

// MARK: - Activity Row
private struct ActivityRow: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(activity.iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: activity.icon)
                    .font(.system(size: 16))
                    .foregroundColor(activity.iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.forestBodySmall)
                    .foregroundColor(.sageWhite)
                    .lineLimit(2)
                
                if let subtitle = activity.subtitle {
                    Text(subtitle)
                        .font(.forestCaptionSmall)
                        .foregroundColor(.sageMuted)
                }
            }
            
            Spacer()
            
            // Time
            Text(formatTime(activity.timestamp))
                .font(.forestCaptionSmall)
                .foregroundColor(.sageMuted)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
struct ProfileWardrobeContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileWardrobeContentView(viewModel: ProfileWardrobeViewModel())
            .preferredColorScheme(.dark)
    }
}
