import Foundation
import UIKit

enum PDFExportError: LocalizedError {
    case cannotCreateDocument

    var errorDescription: String? {
        switch self {
        case .cannotCreateDocument:
            "The PDF quote could not be created. Check available storage and try again."
        }
    }
}

@MainActor
final class PDFExportService {
    func export(project: QuoteProject, settings: AppSettings) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let fileName = sanitizedFileName("\(project.clientName)-\(project.projectType.title)-quote.pdf")
        let outputURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        do {
            try renderer.writePDF(to: outputURL) { context in
                context.beginPage()
                draw(project: project, settings: settings, in: pageRect)
            }
            return outputURL
        } catch {
            throw PDFExportError.cannotCreateDocument
        }
    }

    private func draw(project: QuoteProject, settings: AppSettings, in rect: CGRect) {
        let margin: CGFloat = 40
        var cursor: CGFloat = margin
        let width = rect.width - margin * 2
        let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
        let headingFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let bodyFont = UIFont.systemFont(ofSize: 11, weight: .regular)
        let smallFont = UIFont.systemFont(ofSize: 9, weight: .regular)
        let green = UIColor(red: 0.12, green: 0.36, blue: 0.22, alpha: 1)
        let textColor = UIColor(red: 0.12, green: 0.14, blue: 0.12, alpha: 1)

        drawText("Landscape Quote", at: CGPoint(x: margin, y: cursor), width: width, font: titleFont, color: green)
        cursor += 36
        drawText(project.businessName.isEmpty ? settings.businessName : project.businessName, at: CGPoint(x: margin, y: cursor), width: width, font: headingFont, color: textColor)
        cursor += 28

        drawSectionTitle("Client", y: cursor, margin: margin, width: width, font: headingFont, color: green)
        cursor += 18
        drawText(project.clientName, at: CGPoint(x: margin, y: cursor), width: width, font: bodyFont, color: textColor)
        cursor += 15
        drawText(project.clientContact, at: CGPoint(x: margin, y: cursor), width: width, font: bodyFont, color: textColor)
        cursor += 15
        drawText(project.siteAddress, at: CGPoint(x: margin, y: cursor), width: width, font: bodyFont, color: textColor)
        cursor += 28

        drawSectionTitle("Project", y: cursor, margin: margin, width: width, font: headingFont, color: green)
        cursor += 18
        drawText("\(project.projectType.title) - \(project.area.formatted(.number.precision(.fractionLength(0...1)))) sq m", at: CGPoint(x: margin, y: cursor), width: width, font: bodyFont, color: textColor)
        cursor += 15
        drawText("Estimated timeline: \(project.timelineEstimate)", at: CGPoint(x: margin, y: cursor), width: width, font: bodyFont, color: textColor)
        cursor += 25

        drawSectionTitle("Line items", y: cursor, margin: margin, width: width, font: headingFont, color: green)
        cursor += 22
        drawTableHeader(y: cursor, margin: margin, width: width, font: smallFont)
        cursor += 18

        for item in project.sortedLineItems {
            if cursor > rect.height - 160 { break }
            drawText(item.name, at: CGPoint(x: margin, y: cursor), width: 215, font: smallFont, color: textColor)
            drawText(item.quantity.formatted(.number.precision(.fractionLength(0...2))), at: CGPoint(x: margin + 225, y: cursor), width: 55, font: smallFont, color: textColor)
            drawText(formatCurrency(item.unitCost, code: project.currencyCode), at: CGPoint(x: margin + 285, y: cursor), width: 70, font: smallFont, color: textColor)
            drawText(formatCurrency(item.labourCost, code: project.currencyCode), at: CGPoint(x: margin + 360, y: cursor), width: 70, font: smallFont, color: textColor)
            drawText(formatCurrency(item.total, code: project.currencyCode), at: CGPoint(x: margin + 440, y: cursor), width: 75, font: smallFont, color: textColor)
            cursor += 18
        }

        cursor += 12
        drawTotals(project: project, y: &cursor, margin: margin, width: width, font: bodyFont, headingFont: headingFont, color: textColor)
        cursor += 24

        drawSectionTitle("Terms", y: cursor, margin: margin, width: width, font: headingFont, color: green)
        cursor += 18
        drawText("Quote is valid for 14 days. Final price may change if site conditions, access, or requested scope changes after inspection.", at: CGPoint(x: margin, y: cursor), width: width, font: bodyFont, color: textColor)
        cursor += 36
        drawText("Signature: ________________________________", at: CGPoint(x: margin, y: cursor), width: width, font: bodyFont, color: textColor)
    }

    private func drawSectionTitle(_ text: String, y: CGFloat, margin: CGFloat, width: CGFloat, font: UIFont, color: UIColor) {
        drawText(text.uppercased(), at: CGPoint(x: margin, y: y), width: width, font: font, color: color)
        UIColor(red: 0.78, green: 0.84, blue: 0.76, alpha: 1).setStroke()
        UIBezierPath(rect: CGRect(x: margin, y: y + 16, width: width, height: 1)).fill()
    }

    private func drawTableHeader(y: CGFloat, margin: CGFloat, width: CGFloat, font: UIFont) {
        let color = UIColor.darkGray
        drawText("Item", at: CGPoint(x: margin, y: y), width: 215, font: font, color: color)
        drawText("Qty", at: CGPoint(x: margin + 225, y: y), width: 55, font: font, color: color)
        drawText("Unit", at: CGPoint(x: margin + 285, y: y), width: 70, font: font, color: color)
        drawText("Labour", at: CGPoint(x: margin + 360, y: y), width: 70, font: font, color: color)
        drawText("Total", at: CGPoint(x: margin + 440, y: y), width: 75, font: font, color: color)
    }

    private func drawTotals(project: QuoteProject, y: inout CGFloat, margin: CGFloat, width: CGFloat, font: UIFont, headingFont: UIFont, color: UIColor) {
        let labelX = margin + width - 205
        let amountX = margin + width - 95

        drawText("Subtotal", at: CGPoint(x: labelX, y: y), width: 90, font: font, color: color)
        drawText(formatCurrency(project.subtotal, code: project.currencyCode), at: CGPoint(x: amountX, y: y), width: 95, font: font, color: color)
        y += 16

        if project.discount > 0 {
            drawText("Discount", at: CGPoint(x: labelX, y: y), width: 90, font: font, color: color)
            drawText("-\(formatCurrency(project.discountAmount, code: project.currencyCode))", at: CGPoint(x: amountX, y: y), width: 95, font: font, color: color)
            y += 16
        }

        if project.taxEnabled {
            drawText("VAT/tax", at: CGPoint(x: labelX, y: y), width: 90, font: font, color: color)
            drawText(formatCurrency(project.taxAmount, code: project.currencyCode), at: CGPoint(x: amountX, y: y), width: 95, font: font, color: color)
            y += 16
        }

        drawText("Total", at: CGPoint(x: labelX, y: y), width: 90, font: headingFont, color: color)
        drawText(formatCurrency(project.totalPrice, code: project.currencyCode), at: CGPoint(x: amountX, y: y), width: 95, font: headingFont, color: color)
        y += 20
    }

    private func drawText(_ text: String, at point: CGPoint, width: CGFloat, font: UIFont, color: UIColor) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        text.draw(with: CGRect(x: point.x, y: point.y, width: width, height: 48), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
    }

    private func formatCurrency(_ value: Double, code: String) -> String {
        value.formatted(.currency(code: code))
    }

    private func sanitizedFileName(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        return name.components(separatedBy: invalid).joined(separator: "-")
    }
}
