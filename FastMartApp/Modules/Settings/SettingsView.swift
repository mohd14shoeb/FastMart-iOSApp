//
//  SettingsView.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//
import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section("Preferences") {
                Toggle(
                    "Notifications",
                    isOn: $viewModel.notificationsEnabled
                )
                
                Picker(
                    "Appearance",
                    selection: $viewModel.selectedAppearance
                ) {
                    ForEach(Appearance.allCases) { appearance in
                        Text(appearance.rawValue)
                            .tag(appearance)
                    }
                }
            }
            
            Section("Account") {
                Button("Change Password") {
                    viewModel.changePasswordTapped()
                }
            }
            
            Section("Information") {
                Button("Privacy Policy") {
                    viewModel.privacyPolicyTapped()
                }
                
                Button("About") {
                    viewModel.aboutTapped()
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
