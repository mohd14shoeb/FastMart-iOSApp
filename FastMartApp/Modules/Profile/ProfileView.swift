//
//  ProfileView.swift
//  FastMartApp
//
//  Created by Shoeb Khan on 16/07/26.
//

import SwiftUI

struct ProfileView: View {

    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading…")
            } else {
                profileContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadProfile()
        }
        .alert(
            "Error",
            isPresented: errorBinding
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .foregroundStyle(.secondary)

                Text(viewModel.name)
                    .font(.title2.bold())

                Text(viewModel.email)
                    .foregroundStyle(.secondary)

                Button("Edit Profile") {
                    viewModel.editProfileTapped()
                }
                .buttonStyle(.borderedProminent)

                Button("Settings") {
                    viewModel.settingsTapped()
                }
                .buttonStyle(.bordered)

                Button("Logout", role: .destructive) {
                    viewModel.logoutTapped()
                }
            }
            .padding(24)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}
