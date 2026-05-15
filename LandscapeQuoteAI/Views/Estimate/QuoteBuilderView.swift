import SwiftUI

struct QuoteBuilderView: View {
    @Binding var estimate: GeneratedEstimate
    @Binding var discount: Double
    @Binding var taxEnabled: Bool
    let taxPercentage: Double
    let currencyCode: String

    private var subtotal: Double {
        estimate.lineItems.reduce(0) { $0 + $1.total }
    }

    private var discountAmount: Double {
        subtotal * max(0, discount) / 100
    }

    private var taxableSubtotal: Double {
        estimate.lineItems.filter(\.taxable).reduce(0) { $0 + $1.total }
    }

    private var taxAmount: Double {
        guard taxEnabled else { return 0 }
        return max(0, taxableSubtotal - discountAmount) * max(0, taxPercentage) / 100
    }

    private var total: Double {
        max(0, subtotal - discountAmount + taxAmount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Quote builder")
                    .font(.headline)
                    .foregroundStyle(AppTheme.text)

                Spacer()

                Button {
                    estimate.lineItems.append(EditableLineItem(
                        name: "New line item",
                        quantity: 1,
                        unitCost: 0,
                        labourCost: 0,
                        markupPercentage: estimate.profitMarginPercentage
                    ))
                } label: {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Add line item")
            }

            ForEach(Array(estimate.lineItems.indices), id: \.self) { index in
                EditableLineItemRow(
                    item: $estimate.lineItems[index],
                    currencyCode: currencyCode,
                    onDelete: {
                        estimate.lineItems.remove(at: index)
                    }
                )
            }

            VStack(spacing: 12) {
                HStack {
                    Text("VAT/tax")
                    Spacer()
                    Toggle("VAT/tax", isOn: $taxEnabled)
                        .labelsHidden()
                }

                LabeledContent("Discount") {
                    HStack(spacing: 6) {
                        TextField("0", value: $discount, format: .number.precision(.fractionLength(0...1)))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .frame(width: 76)
                        Text("%")
                            .foregroundStyle(AppTheme.mutedText)
                    }
                }

                Divider()

                totalLine("Subtotal", subtotal.currency(currencyCode))
                if discount > 0 {
                    totalLine("Discount", "-\(discountAmount.currency(currencyCode))")
                }
                if taxEnabled {
                    totalLine("VAT/tax", taxAmount.currency(currencyCode))
                }
                totalLine("Final price", total.currency(currencyCode), isTotal: true)
            }
            .padding(14)
            .background(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .appCard()
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
}

private struct EditableLineItemRow: View {
    @Binding var item: EditableLineItem
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
                        .frame(width: 18)
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
                    TextField("Line item name", text: $item.name)
                        .textInputAutocapitalization(.words)
                        .textFieldStyle(.roundedBorder)

                    HStack(spacing: 10) {
                        NumberField(title: "Qty", value: $item.quantity)
                        NumberField(title: "Unit", value: $item.unitCost)
                    }

                    HStack(spacing: 10) {
                        NumberField(title: "Labour", value: $item.labourCost)
                        NumberField(title: "Markup %", value: $item.markupPercentage)
                    }

                    Toggle("Taxable", isOn: $item.taxable)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct NumberField: View {
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
