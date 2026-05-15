import SwiftData
import SwiftUI
import UIKit

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Environment(StoreKitManager.self) private var storeKitManager
    @Bindable var project: QuoteProject

    @State private var shareItem: ShareItem?
    @State private var showingPaywall = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                summaryCard
                editProjectCard
                lineItemsCard
                photosCard
                notesCard
                exportCard
            }
            .padding(16)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(project.clientName.isEmpty ? "Quote" : project.clientName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    project.updatedDate = .now
                    try? modelContext.save()
                }
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.url])
        }
        .sheet(isPresented: $showingPaywall) {
            NavigationStack {
                PaywallView()
            }
        }
        .alert("Quote export", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onDisappear {
            project.updatedDate = .now
            try? modelContext.save()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(project.projectType.title)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.text)
                    Text(project.totalPrice.currency(project.currencyCode))
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.primaryDark)
                        .minimumScaleFactor(0.7)
                }

                Spacer()

                Picker("Status", selection: Binding(
                    get: { project.status },
                    set: {
                        project.status = $0
                        project.updatedDate = .now
                    }
                )) {
                    ForEach(QuoteStatus.allCases) { status in
                        Text(status.title).tag(status)
                    }
                }
                .pickerStyle(.menu)
            }

            Divider()

            LabeledContent("Timeline", value: project.timelineEstimate)
            LabeledContent("Area", value: "\(project.area.formatted(.number.precision(.fractionLength(0...1)))) sq m")
            LabeledContent("Valid until", value: project.validUntil.formatted(date: .abbreviated, time: .omitted))
        }
        .appCard()
    }

    private var editProjectCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Client and project", systemImage: "person.text.rectangle")

            TextField("Client name", text: $project.clientName)
                .textFieldStyle(.roundedBorder)

            TextField("Phone or email", text: $project.clientContact)
                .textFieldStyle(.roundedBorder)

            TextField("Site address", text: $project.siteAddress, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)

            Picker("Project type", selection: Binding(
                get: { project.projectType },
                set: { project.projectType = $0 }
            )) {
                ForEach(ProjectType.allCases) { type in
                    Text(type.title).tag(type)
                }
            }

            HStack(spacing: 10) {
                ProjectNumberField(title: "Length", value: $project.length)
                ProjectNumberField(title: "Width", value: $project.width)
                ProjectNumberField(title: "Area", value: $project.area)
            }

            TextField("Notes", text: $project.notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)
        }
        .appCard()
    }

    private var lineItemsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Line items", systemImage: "list.bullet.rectangle")
                Spacer()
                Button {
                    addLineItem()
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Add line item")
            }

            if project.lineItems.isEmpty {
                Text("No line items yet.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedText)
            } else {
                ForEach(project.sortedLineItems) { item in
                    QuoteLineItemModelRow(
                        item: item,
                        currencyCode: project.currencyCode,
                        onDelete: {
                            modelContext.delete(item)
                            try? modelContext.save()
                        }
                    )
                }
            }

            Divider()
            totalLine("Subtotal", project.subtotal.currency(project.currencyCode))
            if project.discount > 0 {
                totalLine("Discount", "-\(project.discountAmount.currency(project.currencyCode))")
            }
            if project.taxEnabled {
                totalLine("VAT/tax", project.taxAmount.currency(project.currencyCode))
            }
            totalLine("Final price", project.totalPrice.currency(project.currencyCode), isTotal: true)
        }
        .appCard()
    }

    private var photosCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Photos", systemImage: "photo.on.rectangle")

            if project.photos.isEmpty {
                Text("No photos saved for this project.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedText)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(project.photos) { photo in
                            if let image = UIImage(data: photo.imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 106, height: 106)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                }
            }
        }
        .appCard()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("AI notes", systemImage: "sparkles")

            if project.upsellSuggestions.isEmpty {
                Text("AI upsell suggestions are available with Pro.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedText)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested upsells")
                        .font(.subheadline.weight(.semibold))
                    ForEach(project.upsellSuggestions, id: \.self) { suggestion in
                        Label(suggestion, systemImage: "plus.circle")
                            .font(.subheadline)
                    }
                }
            }

            if !project.contractorNotes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contractor notes")
                        .font(.subheadline.weight(.semibold))
                    ForEach(project.contractorNotes, id: \.self) { note in
                        Label(note, systemImage: "checklist")
                            .font(.subheadline)
                    }
                }
            }
        }
        .appCard()
    }

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("PDF export", systemImage: "doc.richtext")

            Text(storeKitManager.isPro ? "Generate a client-ready PDF quote with terms and signature line." : "PDF export is included with Pro.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedText)

            PrimaryButton(
                title: storeKitManager.isPro ? "Export PDF Quote" : "Upgrade for PDF Export",
                systemImage: storeKitManager.isPro ? "square.and.arrow.up" : "crown"
            ) {
                if storeKitManager.isPro {
                    exportPDF()
                } else {
                    showingPaywall = true
                }
            }
        }
        .appCard()
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(AppTheme.primary)
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.text)
        }
    }

    private func totalLine(_ title: String, _ value: String, isTotal: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .subheadline)
            Spacer()
            Text(value)
                .font(isTotal ? .headline.bold() : .subheadline.weight(.semibold))
        }
        .foregroundStyle(isTotal ? AppTheme.primaryDark : AppTheme.text)
    }

    private func addLineItem() {
        let item = QuoteLineItem(
            name: "New line item",
            quantity: 1,
            unitCost: 0,
            labourCost: 0,
            markupPercentage: settings.defaultProfitMargin,
            sortOrder: project.lineItems.count,
            project: project
        )
        modelContext.insert(item)
        project.lineItems.append(item)
        try? modelContext.save()
    }

    private func exportPDF() {
        do {
            let url = try PDFExportService().export(project: project, settings: settings)
            shareItem = ShareItem(url: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct QuoteLineItemModelRow: View {
    @Bindable var item: QuoteLineItem
    let currencyCode: String
    let onDelete: () -> Void
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    withAnimation(.snappy) {
                        expanded.toggle()
                    }
                } label: {
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.primary)
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name.isEmpty ? "Line item" : item.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.text)
                        .lineLimit(1)
                    Text(item.total.currency(currencyCode))
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                }

                Spacer()

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
            }

            if expanded {
                VStack(spacing: 12) {
                    TextField("Name", text: $item.name)
                        .textFieldStyle(.roundedBorder)

                    HStack(spacing: 10) {
                        ProjectNumberField(title: "Qty", value: $item.quantity)
                        ProjectNumberField(title: "Unit", value: $item.unitCost)
                    }

                    HStack(spacing: 10) {
                        ProjectNumberField(title: "Labour", value: $item.labourCost)
                        ProjectNumberField(title: "Markup %", value: $item.markupPercentage)
                    }

                    Toggle("Taxable", isOn: $item.taxable)
                }
            }
        }
        .padding(14)
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ProjectNumberField: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)

            TextField(title, value: $value, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }
}
