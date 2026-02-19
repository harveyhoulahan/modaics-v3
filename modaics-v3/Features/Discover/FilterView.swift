import SwiftUI

// MARK: - FilterView
// Filter sheet with price, category, size, condition, sustainability filters
// Uses shared FlowLayout component from Core/Components

public struct FilterView: View {
    @Binding var isPresented: Bool
    @Binding var filters: FilterCriteria
    let onApply: () -> Void
    let onReset: () -> Void
    
    public init(
        isPresented: Binding<Bool>,
        filters: Binding<FilterCriteria>,
        onApply: @escaping () -> Void,
        onReset: @escaping () -> Void
    ) {
        self._isPresented = isPresented
        self._filters = filters
        self.onApply = onApply
        self.onReset = onReset
    }
    
    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // MARK: Price Range
                    priceSection
                    
                    Divider()
                        .background(Color.luxeGold.opacity(0.2))
                    
                    // MARK: Categories
                    categorySection
                    
                    Divider()
                        .background(Color.luxeGold.opacity(0.2))
                    
                    // MARK: Sizes
                    sizeSection
                    
                    Divider()
                        .background(Color.luxeGold.opacity(0.2))
                    
                    // MARK: Conditions
                    conditionSection
                    
                    Divider()
                        .background(Color.luxeGold.opacity(0.2))
                    
                    // MARK: Sustainability
                    sustainabilitySection
                    
                    // Bottom padding for button
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.modaicsBackground.ignoresSafeArea())
            .navigationTitle("FILTERS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("CLOSE") {
                        isPresented = false
                    }
                    .font(.forestCaptionMedium)
                    .foregroundColor(Color.sageWhite)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("RESET") {
                        resetFilters()
                    }
                    .font(.forestCaptionMedium)
                    .foregroundColor(Color.luxeGold)
                    .disabled(!hasActiveFilters)
                    .opacity(hasActiveFilters ? 1.0 : 0.5)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Apply Button
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.luxeGold.opacity(0.2))
                    
                    Button(action: {
                        onApply()
                        isPresented = false
                    }) {
                        Text("APPLY FILTERS")
                            .font(.forestBodyLarge)
                            .foregroundColor(Color.modaicsBackground)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.luxeGold)
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color.modaicsBackground)
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Sections
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PRICE RANGE")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.luxeGold)
                .tracking(1.5)
            
            // Custom Range Slider (simplified version)
            VStack(spacing: 12) {
                HStack {
                    Text("$\(Int(filters.minPrice))")
                        .font(.forestCaptionMedium)
                        .foregroundColor(Color.sageWhite)
                        .frame(width: 60, alignment: .leading)
                    
                    Spacer()
                    
                    Text("$\(Int(filters.maxPrice))")
                        .font(.forestCaptionMedium)
                        .foregroundColor(Color.sageWhite)
                        .frame(width: 60, alignment: .trailing)
                }
                
                // Price slider using Slider
                Slider(value: $filters.maxPrice, in: filters.minPrice...2000, step: 10)
                    .tint(Color.luxeGold)
                
                // Preset buttons
                HStack(spacing: 8) {
                    ForEach([50, 100, 250, 500, 1000], id: \.self) { price in
                        Button(action: {
                            filters.maxPrice = Double(price)
                        }) {
                            Text("$\(price)")
                                .font(.forestCaptionSmall)
                                .foregroundColor(filters.maxPrice == Double(price) ? Color.modaicsBackground : Color.sageWhite)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(filters.maxPrice == Double(price) ? Color.luxeGold : Color.modaicsSurface)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CATEGORY")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.luxeGold)
                .tracking(1.5)
            
            FlowLayout(spacing: 8) {
                ForEach(Category.allCases) { category in
                    FilterChip(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: filters.category == category
                    ) {
                        if filters.category == category {
                            filters.category = nil
                        } else {
                            filters.category = category
                        }
                    }
                }
            }
        }
    }
    
    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SIZE")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.luxeGold)
                .tracking(1.5)
            
            // Clothing sizes
            Text("CLOTHING")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.sageMuted)
            
            HStack(spacing: 8) {
                ForEach([Size.xs, .s, .m, .l, .xl, .xxl, .xxxl, .os], id: \.self) { size in
                    SizeChip(
                        size: size.rawValue,
                        isSelected: filters.size == size
                    ) {
                        if filters.size == size {
                            filters.size = nil
                        } else {
                            filters.size = size
                        }
                    }
                }
            }
            
            // Shoe sizes - Women's
            Text("WOMEN'S SHOES")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.sageMuted)
                .padding(.top, 8)
            
            HStack(spacing: 8) {
                ForEach([Size.w5, .w6, .w7, .w8, .w9, .w10, .w11], id: \.self) { size in
                    SizeChip(
                        size: size.rawValue.replacingOccurrences(of: "W ", with: ""),
                        isSelected: filters.size == size
                    ) {
                        if filters.size == size {
                            filters.size = nil
                        } else {
                            filters.size = size
                        }
                    }
                }
            }
            
            // Shoe sizes - Men's
            Text("MEN'S SHOES")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.sageMuted)
                .padding(.top, 8)
            
            HStack(spacing: 8) {
                ForEach([Size.m7, .m8, .m9, .m10, .m11, .m12], id: \.self) { size in
                    SizeChip(
                        size: size.rawValue.replacingOccurrences(of: "M ", with: ""),
                        isSelected: filters.size == size
                    ) {
                        if filters.size == size {
                            filters.size = nil
                        } else {
                            filters.size = size
                        }
                    }
                }
            }
        }
    }
    
    private var conditionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CONDITION")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.luxeGold)
                .tracking(1.5)
            
            VStack(spacing: 8) {
                ForEach(Condition.allCases) { condition in
                    ConditionRow(
                        condition: condition,
                        isSelected: filters.condition == condition
                    ) {
                        if filters.condition == condition {
                            filters.condition = nil
                        } else {
                            filters.condition = condition
                        }
                    }
                }
            }
        }
    }
    
    private var sustainabilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUSTAINABILITY")
                .font(.forestCaptionSmall)
                .foregroundColor(Color.luxeGold)
                .tracking(1.5)
            
            VStack(spacing: 12) {
                Toggle(isOn: $filters.sustainabilityOnly) {
                    HStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(Color.modaicsEco)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ECO-FRIENDLY ONLY")
                                .font(.forestCaptionMedium)
                                .foregroundColor(Color.sageWhite)
                            
                            Text("Items with sustainability score 60+")
                                .font(.forestCaptionSmall)
                                .foregroundColor(Color.sageMuted)
                        }
                    }
                }
                .tint(Color.luxeGold)
                
                Toggle(isOn: $filters.vintageOnly) {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(Color.luxeGold)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("VINTAGE ONLY")
                                .font(.forestCaptionMedium)
                                .foregroundColor(Color.sageWhite)
                            
                            Text("Pre-loved vintage items")
                                .font(.forestCaptionSmall)
                                .foregroundColor(Color.sageMuted)
                        }
                    }
                }
                .tint(Color.luxeGold)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var hasActiveFilters: Bool {
        filters.category != nil ||
        filters.condition != nil ||
        filters.size != nil ||
        filters.minPrice > 0 ||
        filters.maxPrice < 2000 ||
        filters.sustainabilityOnly ||
        filters.vintageOnly
    }
    
    private func resetFilters() {
        filters = FilterCriteria()
        onReset()
    }
}

// MARK: - Filter Criteria
public struct FilterCriteria {
    public var category: Category?
    public var condition: Condition?
    public var size: Size?
    public var minPrice: Double
    public var maxPrice: Double
    public var sustainabilityOnly: Bool
    public var vintageOnly: Bool
    
    public init(
        category: Category? = nil,
        condition: Condition? = nil,
        size: Size? = nil,
        minPrice: Double = 0,
        maxPrice: Double = 2000,
        sustainabilityOnly: Bool = false,
        vintageOnly: Bool = false
    ) {
        self.category = category
        self.condition = condition
        self.size = size
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.sustainabilityOnly = sustainabilityOnly
        self.vintageOnly = vintageOnly
    }
    
    public var isEmpty: Bool {
        category == nil &&
        condition == nil &&
        size == nil &&
        minPrice == 0 &&
        maxPrice == 2000 &&
        !sustainabilityOnly &&
        !vintageOnly
    }
    
    public var activeFilterCount: Int {
        var count = 0
        if category != nil { count += 1 }
        if condition != nil { count += 1 }
        if size != nil { count += 1 }
        if minPrice > 0 || maxPrice < 2000 { count += 1 }
        if sustainabilityOnly { count += 1 }
        if vintageOnly { count += 1 }
        return count
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.forestCaptionSmall)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.clear : Color.luxeGold.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Size Chip
struct SizeChip: View {
    let size: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(size)
                .font(.forestCaptionSmall)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? Color.modaicsBackground : Color.sageWhite)
                .frame(minWidth: 40, minHeight: 36)
                .background(isSelected ? Color.luxeGold : Color.modaicsSurface)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.clear : Color.luxeGold.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Condition Row
struct ConditionRow: View {
    let condition: Condition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(condition.displayName)
                        .font(.forestCaptionMedium)
                        .foregroundColor(Color.sageWhite)
                    
                    Text(conditionDescription)
                        .font(.forestCaptionSmall)
                        .foregroundColor(Color.sageMuted)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.luxeGold)
                        .font(.system(size: 22))
                } else {
                    Circle()
                        .stroke(Color.luxeGold.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding()
            .background(Color.modaicsSurface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.luxeGold.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
    
    private var conditionDescription: String {
        switch condition {
        case .new:
            return "Never worn, with original tags"
        case .likeNew:
            return "Worn once or twice, no flaws"
        case .excellent:
            return "Gently used, minimal signs of wear"
        case .good:
            return "Visible wear but still great condition"
        case .fair:
            return "Significant wear, priced accordingly"
        }
    }
}

// MARK: - Preview
struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            isPresented: .constant(true),
            filters: .constant(FilterCriteria()),
            onApply: {},
            onReset: {}
        )
    }
}
