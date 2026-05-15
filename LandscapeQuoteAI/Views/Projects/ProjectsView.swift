import SwiftData
import SwiftUI

struct ProjectsView: View {
    @Query(sort: \QuoteProject.createdDate, order: .reverse) private var projects: [QuoteProject]
    @State private var searchText = ""
    @State private var selectedStatus: QuoteStatus?

    private var filteredProjects: [QuoteProject] {
        projects.filter { project in
            let matchesStatus = selectedStatus == nil || project.status == selectedStatus
            let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let matchesSearch = search.isEmpty ||
            project.clientName.lowercased().contains(search) ||
            project.siteAddress.lowercased().contains(search) ||
            project.projectType.title.lowercased().contains(search)
            return matchesStatus && matchesSearch
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                filterBar

                if filteredProjects.isEmpty {
                    EmptyStateView(title: "No matching projects", message: "Adjust the filters or create a new estimate.", systemImage: "folder")
                } else {
                    ForEach(filteredProjects) { project in
                        NavigationLink {
                            ProjectDetailView(project: project)
                        } label: {
                            ProjectSummaryRow(project: project)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Project Library")
        .searchable(text: $searchText, prompt: "Search clients or projects")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    EstimateFlowView()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create new estimate")
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                statusChip(title: "All", status: nil)
                ForEach(QuoteStatus.allCases) { status in
                    statusChip(title: status.title, status: status)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func statusChip(title: String, status: QuoteStatus?) -> some View {
        Button {
            selectedStatus = status
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(selectedStatus == status ? .white : AppTheme.text)
                .background(selectedStatus == status ? AppTheme.primary : Color.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
