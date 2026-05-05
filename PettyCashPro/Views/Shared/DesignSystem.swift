import SwiftUI


extension Color {
    static let primaryBlue   = Color(hex: "#1A6BFF")
    static let lightBlue     = Color(hex: "#EBF2FF")
    static let darkBlue      = Color(hex: "#0F4FCC")
    static let accentGreen   = Color(hex: "#00C48C")
    static let accentOrange  = Color(hex: "#FF8C42")
    static let accentRed     = Color(hex: "#FF3B30")
    static let pendingColor  = Color(hex: "#FF9500")
    static let approvedColor = Color(hex: "#34C759")
    static let rejectedColor = Color(hex: "#FF3B30")


    static var bgPrimary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#1C1C1E")
                : UIColor(hex: "#F5F7FA")
        })
    }

    static var bgCard: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#2C2C2E")
                : UIColor.white
        })
    }

    static var textPrimary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#F2F2F7")
                : UIColor(hex: "#1A1F36")
        })
    }

    static var textSecondary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#AEAEB2")
                : UIColor(hex: "#6B7280")
        })
    }

    static var borderColor: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: "#3A3A3C")
                : UIColor(hex: "#E5E7EB")
        })
    }


    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        self.init(red: CGFloat(r) / 255,
                  green: CGFloat(g) / 255,
                  blue: CGFloat(b) / 255,
                  alpha: 1)
    }
}


struct AppDesign {
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
    static let cardPadding: CGFloat = 20
    static let screenPadding: CGFloat = 20
    static let shadowRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.08
}


struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.bgCard)
            .cornerRadius(AppDesign.cornerRadius)
            .shadow(color: Color.black.opacity(AppDesign.shadowOpacity),
                    radius: AppDesign.shadowRadius, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}



struct StatusBadge: View {
    let status: RequestStatus

    var body: some View {
        Text(status.displayText)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.color)
            .cornerRadius(8)
    }
}



struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.85)
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(colors: [Color.primaryBlue, Color.darkBlue],
                               startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(14)
        }
    }
}


struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primaryBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.lightBlue)
                .cornerRadius(14)
        }
    }
}


struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    @State private var isPasswordVisible = false

    var body: some View {
        HStack {
            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .keyboardType(keyboardType)
            }

            if isSecure {
                Button(action: { isPasswordVisible.toggle() }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(Color.bgPrimary)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.borderColor, lineWidth: 1)
        )
    }
}



struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)
            Spacer()
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryBlue)
            }
        }
    }
}
