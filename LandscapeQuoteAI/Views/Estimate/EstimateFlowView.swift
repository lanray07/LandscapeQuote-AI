import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct EstimateFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings
    @Environment(StoreKitManager.self) private var storeKitManager
    @Query(sort: \QuoteProject.createdDate, order: .reverse) private var projects: [QuoteProject]

    @State private var draft = EstimateDraft()
    @State private var generatedEstimate: GeneratedEstimate?
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedPhotos: [UIImage] = []
    @State private var capturedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingPaywall = false
    @State private var isGenerating = false
    @State private var errorMessage: String?

    private let aiQuoteService = MockAIQuoteService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                clientCard
                projectCard
                measurementsCard
                photosCard
                generateCard

                if generatedEstimate != nil {
                    QuoteBuilderView(
                        estimate: Binding(
                            get: { generatedEstimate ?? GeneratedEstimate.empty },
                            set: { generatedEstimate = $0 }
                        ),
                        discount: $draft.discount,
                        taxEnabled: $draft.taxEnabled,
                        taxPercentage: settings.taxPercentage,
                        currencyCode: settings.currency.rawValue
                    )
                    saveCard
                }
            }
            .padding(16)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("New Estimate")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItems) { _, newItems in
            guard storeKitManager.isPro else {
                selectedPhotoItems.removeAll()
                showingPaywall = true
                return
            }

            Task {
                await loadPhotos(from: newItems)
            }
        }
        .sheet(isPresented: $showingCamera, onDismiss: appendCapturedImage) {
            PhotoCapturePicker(image: $capturedImage)
        }
        .sheet(isPresented: $showingPaywall) {
            NavigationStack {
                PaywallView()
            }
        }
        .alert("Estimate issue", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var clientCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Client details", systemImage: "person.crop.rectangle")

            TextField("Client name", text: $draft.clientName)
                .textInputAutocapitalization(.words)
                .textContentType(.name)
                .textFieldStyle(.roundedBorder)

            TextField("Client phone or email", text: $draft.clientContact)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            TextField("Site address", text: $draft.siteAddress, axis: .vertical)
                .textInputAutocapitalization(.words)
                .textContentType(.fullStreetAddress)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
        .appCard()
    }

    private var projectCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Project type", systemImage: draft.projectType.symbolName)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(ProjectType.allCases) { type in
                    Button {
                        draft.projectType = type
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: type.symbolName)
                            Text(type.title)
                                .font(.caption.weight(.semibold))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .padding(.horizontal, 10)
                        .foregroundStyle(draft.projectType == type ? .white : AppTheme.text)
                        .background(draft.projectType == type ? AppTheme.primary : AppTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCard()
    }

    private var measurementsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Measurements", systemImage: "ruler")

            // TODO: Add LiDAR/photo measurement extraction here once the computer vision measurement layer is ready.
            HStack(spacing: 10) {
                NumberEntry(title: "Length", suffix: "m", value: $draft.length)
                NumberEntry(title: "Width", suffix: "m", value: $draft.width)
            }

            NumberEntry(title: "Area override", suffix: "sq m", value: $draft.manualArea)

            TextField("Manual notes", text: $draft.notes, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.roundedBorder)

            LabeledContent("Estimate area") {
                Text("\(draft.calculatedArea.formatted(.number.precision(.fractionLength(0...1)))) sq m")
                    .fontWeight(.semibold)
            }
        }
        .appCard()
    }

    private var photosCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Site photos", systemImage: "camera")

            if storeKitManager.isPro {
                HStack(spacing: 10) {
                    PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 8, matching: .images) {
                        Label("Library", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            showingCamera = true
                        } else {
                            errorMessage = "Camera is not available on this device."
                        }
                    } label: {
                        Label("Camera", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if selectedPhotos.isEmpty {
                    Text("No photos attached yet.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.mutedText)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(selectedPhotos.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: selectedPhotos[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 96, height: 96)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                    Button {
                                        selectedPhotos.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.white, .black.opacity(0.65))
                                    }
                                    .padding(6)
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Photo uploads are included with Pro.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.text)
                    Text("Free quotes still work with manual measurements and notes.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                    Button {
                        showingPaywall = true
                    } label: {
                        Label("View Pro", systemImage: "crown")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .appCard()
    }

    private var generateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI estimate generator")
                .font(.headline)
                .foregroundStyle(AppTheme.text)

            Text("Uses a local mock estimator for this MVP. OpenAI can be wired into the service later without rewriting the quote builder.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedText)

            PrimaryButton(
                title: generatedEstimate == nil ? "Generate Estimate" : "Regenerate Estimate",
                systemImage: "sparkles",
                isLoading: isGenerating,
                isDisabled: !draft.isReadyForEstimate
            ) {
                Task {
                    await generateEstimate()
                }
            }
        }
        .appCard()
    }

    private var saveCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Save quote")
                .font(.headline)
                .foregroundStyle(AppTheme.text)

            Text("The project, line items, photos, and quote data are stored locally on this device for the MVP.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedText)

            PrimaryButton(title: "Save Project Quote", systemImage: "tray.and.arrow.down.fill") {
                saveQuote()
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

    private func generateEstimate() async {
        isGenerating = true
        defer { isGenerating = false }

        do {
            generatedEstimate = try await aiQuoteService.generateEstimate(
                for: draft,
                settings: settings,
                includeUpsells: storeKitManager.isPro
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        var images: [UIImage] = []

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }

        selectedPhotos = images
    }

    private func appendCapturedImage() {
        guard let capturedImage else { return }
        selectedPhotos.append(capturedImage)
        self.capturedImage = nil
    }

    private func saveQuote() {
        guard let generatedEstimate else {
            errorMessage = "Generate an estimate before saving the project."
            return
        }

        guard QuoteLimitService.canCreateQuote(projects: projects, isPro: storeKitManager.isPro) else {
            showingPaywall = true
            return
        }

        let project = QuoteProject(
            clientName: draft.clientName,
            clientContact: draft.clientContact,
            siteAddress: draft.siteAddress,
            projectType: draft.projectType,
            status: .draft,
            length: draft.length,
            width: draft.width,
            area: draft.calculatedArea,
            notes: draft.notes,
            businessName: settings.businessName,
            currencyCode: settings.currency,
            discount: draft.discount,
            taxEnabled: draft.taxEnabled,
            taxPercentage: settings.taxPercentage,
            timelineEstimate: generatedEstimate.timelineEstimate,
            upsellSuggestions: generatedEstimate.upsellSuggestions,
            contractorNotes: generatedEstimate.contractorNotes
        )

        modelContext.insert(project)

        for (index, line) in generatedEstimate.lineItems.enumerated() {
            let item = QuoteLineItem(
                name: line.name,
                quantity: line.quantity,
                unitCost: line.unitCost,
                labourCost: line.labourCost,
                markupPercentage: line.markupPercentage,
                taxable: line.taxable,
                sortOrder: index,
                project: project
            )
            modelContext.insert(item)
            project.lineItems.append(item)
        }

        if storeKitManager.isPro {
            for image in selectedPhotos {
                if let data = image.jpegData(compressionQuality: 0.82) {
                    let photo = ProjectPhoto(imageData: data, project: project)
                    modelContext.insert(photo)
                    project.photos.append(photo)
                }
            }
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "The quote could not be saved. Please try again."
        }
    }
}

private struct NumberEntry: View {
    let title: String
    let suffix: String
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)

            HStack {
                TextField(title, value: $value, format: .number.precision(.fractionLength(0...2)))
                    .keyboardType(.decimalPad)
                Text(suffix)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedText)
            }
            .padding(10)
            .background(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
