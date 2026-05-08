import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isAuthenticated, let user = authVM.currentUser {
                if user.role == .staff {
                    StaffTabView()
                        .environmentObject(StaffViewModel())
                } else {
                    ManagerTabView()
                        .environmentObject(ManagerViewModel())
                }
            } else {
                RoleSelectionView()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: authVM.isAuthenticated)
    }
}
