//
//  PDFReportGenerator.swift
//  PettyCashPro
//
//  Created by Keshana Liyanaarachchi on 2026-05-07.
//



import PDFKit
import UIKit

struct PDFReportGenerator {


    static func generateReport(
        monthYear: String,
        monthlyLimit: Double,
        totalSpent: Double,
        approvedCount: Int,
        rejectedCount: Int,
        pendingCount: Int,
        categoryBreakdown: [(category: String, amount: Double)]
    ) -> Data {

        let pdfMetaData: [CFString: Any] = [
            kCGPDFContextCreator: "PettyCash Pro",
            kCGPDFContextAuthor:  "PettyCash Pro Manager",
            kCGPDFContextTitle:   "Monthly Report – \(monthYear)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth:  CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin:   CGFloat = 50

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        return renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = margin

            let purple = UIColor(red: 0.345, green: 0.337, blue: 0.839, alpha: 1)

            let headerRect = CGRect(x: 0, y: 0, width: pageWidth, height: 90)
            purple.setFill()
            UIBezierPath(rect: headerRect).fill()

            let appTitleAttr: [NSAttributedString.Key: Any] = [
                .font:            UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.white
            ]
            "PettyCash Pro".draw(at: CGPoint(x: margin, y: 20), withAttributes: appTitleAttr)

            let subAttr: [NSAttributedString.Key: Any] = [
                .font:            UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
            "Monthly Expense Report – \(monthYear)".draw(at: CGPoint(x: margin, y: 50), withAttributes: subAttr)

            y = 110

         
            y = drawSectionTitle("Budget Summary", y: y, margin: margin, color: purple)

            let remaining   = max(monthlyLimit - totalSpent, 0)
            let savingsRate = monthlyLimit > 0 ? (remaining / monthlyLimit) * 100 : 0

            let summaryRows: [(String, String, UIColor)] = [
                ("Monthly Budget Limit", "LKR \(fmt(monthlyLimit))", .black),
                ("Total Spent",          "LKR \(fmt(totalSpent))",   UIColor(red: 0.95, green: 0.47, blue: 0.14, alpha: 1)),
                ("Remaining Budget",     "LKR \(fmt(remaining))",    UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)),
                ("Savings Rate",         String(format: "%.1f%%", savingsRate), .darkGray)
            ]
            y = drawKeyValueRows(summaryRows, y: y, margin: margin, pageWidth: pageWidth)


            y += 8
            let barW = pageWidth - margin * 2
            let utilization = min(totalSpent / max(monthlyLimit, 1), 1.0)
            UIColor(white: 0.90, alpha: 1).setFill()
            UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: barW, height: 14), cornerRadius: 7).fill()
            let barColor = utilization >= 1.0
                ? UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1)
                : utilization >= 0.80
                    ? UIColor(red: 0.95, green: 0.47, blue: 0.14, alpha: 1)
                    : purple
            barColor.setFill()
            UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: barW * utilization, height: 14), cornerRadius: 7).fill()

            let pctAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]
            "\(Int(utilization * 100))% used".draw(at: CGPoint(x: margin, y: y + 18), withAttributes: pctAttr)
            y += 40

            y = drawSectionTitle("Request Summary", y: y, margin: margin, color: purple)

            let reqRows: [(String, String, UIColor)] = [
                ("✅  Approved Requests", "\(approvedCount)", UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1)),
                ("❌  Rejected Requests", "\(rejectedCount)", UIColor(red: 0.90, green: 0.25, blue: 0.25, alpha: 1)),
                ("⏳  Pending Requests",  "\(pendingCount)",  UIColor(red: 0.95, green: 0.47, blue: 0.14, alpha: 1))
            ]
            y = drawKeyValueRows(reqRows, y: y, margin: margin, pageWidth: pageWidth)
            y += 10

            y = drawSectionTitle("Spending by Category", y: y, margin: margin, color: purple)

            if categoryBreakdown.isEmpty {
                let noDataAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.lightGray
                ]
                "No approved expenses this month.".draw(at: CGPoint(x: margin, y: y), withAttributes: noDataAttr)
                y += 20
            } else {
                let labelAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.darkGray
                ]
                let valAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]
                let maxAmt = categoryBreakdown.first?.amount ?? 1

                for item in categoryBreakdown {
                    item.category.draw(at: CGPoint(x: margin, y: y), withAttributes: labelAttr)
                    let amtStr = "LKR \(fmt(item.amount))"
                    let amtW = (amtStr as NSString).size(withAttributes: valAttr).width
                    amtStr.draw(at: CGPoint(x: pageWidth - margin - amtW, y: y), withAttributes: valAttr)
                    y += 18

                    UIColor(white: 0.90, alpha: 1).setFill()
                    UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: barW, height: 9), cornerRadius: 4.5).fill()
                    purple.withAlphaComponent(0.75).setFill()
                    let fill = barW * CGFloat(min(item.amount / maxAmt, 1.0))
                    UIBezierPath(roundedRect: CGRect(x: margin, y: y, width: fill, height: 9), cornerRadius: 4.5).fill()
                    y += 20
                }
            }

            UIColor.lightGray.setStroke()
            let footerLine = UIBezierPath()
            footerLine.move(to: CGPoint(x: margin, y: pageHeight - 50))
            footerLine.addLine(to: CGPoint(x: pageWidth - margin, y: pageHeight - 50))
            footerLine.lineWidth = 0.5
            footerLine.stroke()

            let footerAttr: [NSAttributedString.Key: Any] = [
                .font:            UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor.lightGray
            ]
            "Generated by PettyCash Pro  •  \(formattedNow())  •  CONFIDENTIAL"
                .draw(at: CGPoint(x: margin, y: pageHeight - 38), withAttributes: footerAttr)
        }
    }

 
    private static func drawSectionTitle(
        _ title: String,
        y: CGFloat,
        margin: CGFloat,
        color: UIColor
    ) -> CGFloat {
        let attr: [NSAttributedString.Key: Any] = [
            .font:            UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: color
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: attr)

        color.withAlphaComponent(0.3).setStroke()
        let line = UIBezierPath()
        line.move(to: CGPoint(x: margin, y: y + 20))
        line.addLine(to: CGPoint(x: 595.2 - margin, y: y + 20))
        line.lineWidth = 0.8
        line.stroke()

        return y + 30
    }

    private static func drawKeyValueRows(
        _ rows: [(String, String, UIColor)],
        y: CGFloat,
        margin: CGFloat,
        pageWidth: CGFloat
    ) -> CGFloat {
        var yPos = y
        let labelAttr: [NSAttributedString.Key: Any] = [
            .font:            UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        for (label, value, valueColor) in rows {
            label.draw(at: CGPoint(x: margin, y: yPos), withAttributes: labelAttr)
            let valAttr: [NSAttributedString.Key: Any] = [
                .font:            UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: valueColor
            ]
            let valW = (value as NSString).size(withAttributes: valAttr).width
            value.draw(at: CGPoint(x: pageWidth - margin - valW, y: yPos), withAttributes: valAttr)
            yPos += 22
        }
        return yPos
    }


    private static func fmt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle      = .decimal
        f.groupingSeparator = ","
        return f.string(from: NSNumber(value: Int(value))) ?? "\(Int(value))"
    }

    private static func formattedNow() -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy, HH:mm"
        return df.string(from: Date())
    }
}
