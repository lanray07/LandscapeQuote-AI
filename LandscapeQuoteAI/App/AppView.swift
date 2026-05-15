import SwiftData
import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            }
        }
        .tint(AppTheme.primary)
    }
}

struct StartupErrorView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.orange)

            Text("Storage unavailable")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.text)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.mutedText)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(AppTheme.background.ignoresSafeArea())
    }
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                ProjectsView()
            }
            .tabItem {
                Label("Projects", systemImage: "folder.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .task {
            SampleDataSeeder.seedIfNeeded(context: modelContext)
        }
    }
}
