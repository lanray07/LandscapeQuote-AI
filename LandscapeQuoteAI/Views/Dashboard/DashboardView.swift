import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(StoreKitManager.self) private var storeKitManager
    @Environment(AppSettings.self) private var settings
    @Query(sort: \QuoteProject.createdDate, order: .reverse) private var projects: [QuoteProject]
    @State private var showingPaywall = false

    private var draftCount: Int {
        projects.filter { $0.status == .draft }.count
    }

    private var approvedCount: Int {
        projects.filter { $0.status == .approved }.count
    }

    private var monthlyRevenue: Double {
        projects
            .filter {
                $0.status == .approved &&
                Calendar.current.isDate($0.createdDate, equalTo: .now, toGranularity: .month) &&
                Calendar.current.isDate($0.createdDate, equalTo: .now, toGranularity: .year)
            }
            .reduce(0) { $0 + $1.totalPrice }
    }

    private var currentMonthQuoteCount: Int {
        QuoteLimitService.quotesCreatedThisMonth(in: projects)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                metricsGrid
                createQuoteCard
                recentProjects
            }
            .padding(16)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("LandscapeQuote AI")
        .sheet(isPresented: $showingPaywall) {
            NavigationStack {
                PaywallView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Turn garden photos and rough measurements into a professional quote in minutes.")
                .font(.headline)
                .foregroundStyle(AppTheme.text)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Label(storeKitManager.subscriptionStatusText, systemImage: storeKitManager.isPro ? "checkmark.seal.fill" : "leaf.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(storeKitManager.isPro ? AppTheme.primary : AppTheme.mutedText)

                Spacer()

                Text(storeKitManager.isPro ? "Unlimited" : "\(max(0, QuoteLimitService.freeMonthlyLimit - currentMonthQuoteCount)) free left")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedText)
            }
        }
        .appCard()
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MetricCard(title: "Total quotes", value: "\(projects.count)", systemImage: "doc.text.fill")
            MetricCard(title: "Draft quotes", value: "\(draftCount)", systemImage: "square.and.pencil", tint: .orange)
            MetricCard(title: "Approved", value: "\(approvedCount)", systemImage: "checkmark.circle.fill", tint: .green)
            MetricCard(title: "Monthly revenue", value: monthlyRevenue.currency(settings.currency.rawValue), systemImage: "chart.line.uptrend.xyaxis", tint: AppTheme.accent)
        }
    }

    private var createQuoteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ready for the next job?")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.text)
                Text("Capture details, generate a first estimate, then tune the line items before saving.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedText)
            }

            if QuoteLimitService.canCreateQuote(projects: projects, isPro: storeKitManager.isPro) {
                NavigationLink {
                    EstimateFlowView()
                } label: {
                    Label("Create New Estimate", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .foregroundStyle(.white)
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                PrimaryButton(title: "Upgrade to Create More", systemImage: "crown") {
                    showingPaywall = true
                }
            }
        }
        .appCard()
    }

    private var recentProjects: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent quotes")
                .font(.headline)
                .foregroundStyle(AppTheme.text)

            if projects.isEmpty {
                EmptyStateView(title: "No quotes yet", message: "Create your first estimate to see it here.", systemImage: "doc.badge.plus")
            } else {
                ForEach(projects.prefix(3)) { project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        ProjectSummaryRow(project: project)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ProjectSummaryRow: View {
    let project: QuoteProject

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.projectType.symbolName)
                .foregroundStyle(AppTheme.primary)
                .frame(width: 36, height: 36)
                .background(AppTheme.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(project.clientName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.text)
                Text(project.projectType.title)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(project.totalPrice.currency(project.currencyCode))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.text)
                Text(project.status.title)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.1))
                    .foregroundStyle(AppTheme.primary)
                    .clipShape(Capsule())
            }
        }
        .appCard(padding: 12)
    }
}
