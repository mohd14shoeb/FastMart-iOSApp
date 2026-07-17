import Foundation
import Combine

@MainActor
// @Observable
final class HomeViewModel: ObservableObject {
@Published private(set) var dashboardData: DashboardPrefetcher.DashboardData?
@Published private(set) var isRefreshing = false

    init(initialData: DashboardPrefetcher.DashboardData?) {
        dashboardData = initialData
    }

    func apply(dashboardData: DashboardPrefetcher.DashboardData) {
        self.dashboardData = dashboardData
    }
}
