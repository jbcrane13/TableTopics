// SettingsSheet.swift
// Settings — API config, area lock, demo toggle

import SwiftUI
import B2BCore

struct SettingsSheet: View {
    @Bindable var viewModel: LeadsViewModel
    @Binding var isPresented: Bool
    @State private var showingAPIKeyEntry = false
    @State private var apiKey = ""
    @State private var lockState = ""
    @State private var lockCity = ""

    var body: some View {
        NavigationStack {
            Form {
                // API Configuration
                Section {
                    HStack {
                        Text("API Status")
                        Spacer()
                        if viewModel.isAPIConfigured {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.brandGreen)
                        } else {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.orange)
                        }
                    }
                    .accessibilityIdentifier("settings_row_api_status")

                    if viewModel.isAPIConfigured {
                        HStack {
                            Text("Credits Remaining")
                            Spacer()
                            Text("\(viewModel.creditsRemaining)")
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                        .accessibilityIdentifier("settings_row_credits")
                    }

                    if showingAPIKeyEntry {
                        SecureField("Shovels API Key", text: $apiKey)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            #endif
                            .accessibilityIdentifier("settings_textfield_api_key")

                        Button("Save Key") {
                            viewModel.setAPIKey(apiKey)
                            showingAPIKeyEntry = false
                            apiKey = ""
                        }
                        .disabled(apiKey.isEmpty)
                        .accessibilityIdentifier("settings_button_save_key")
                    } else {
                        Button("Configure API Key") {
                            showingAPIKeyEntry = true
                        }
                        .accessibilityIdentifier("settings_button_configure_key")
                    }

                    if viewModel.isAPIConfigured {
                        Button("Clear API Key", role: .destructive) {
                            viewModel.clearAPIKey()
                        }
                        .accessibilityIdentifier("settings_button_clear_key")
                    }
                } header: {
                    Text("Shovels API")
                } footer: {
                    Text("Searches commercial construction permits. ~1 credit per result.")
                }

                // Area Lock
                Section {
                    if viewModel.areaLocked {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.brandBlue)
                            Text("Locked to \(viewModel.lockedArea)")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .accessibilityIdentifier("settings_row_area_locked")

                        Button("Unlock Area", role: .destructive) {
                            viewModel.unlockArea()
                        }
                        .accessibilityIdentifier("settings_button_unlock_area")
                    } else {
                        TextField("State (e.g., TX)", text: $lockState)
                            #if os(iOS)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            #endif
                            .accessibilityIdentifier("settings_textfield_lock_state")

                        TextField("City (optional)", text: $lockCity)
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                            .accessibilityIdentifier("settings_textfield_lock_city")

                        Button("Lock Area") {
                            viewModel.lockArea(
                                state: lockState.uppercased(),
                                city: lockCity.isEmpty ? nil : lockCity
                            )
                        }
                        .disabled(lockState.count != 2)
                        .accessibilityIdentifier("settings_button_lock_area")
                    }
                } header: {
                    Text("Area Lock")
                } footer: {
                    Text("Lock searches to a specific state and city.")
                }

                // Data Source
                Section {
                    Toggle("Use Demo Data", isOn: $viewModel.useMockData)
                        .toggleStyle(.switch)
                        .accessibilityIdentifier("settings_toggle_demo_data")

                    Text("Demo data doesn't use API credits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Data Source")
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                    .accessibilityIdentifier("settings_button_done")
                }
            }
        }
        .accessibilityIdentifier("screen_settings")
    }
}

#Preview {
    SettingsSheet(
        viewModel: LeadsViewModel(),
        isPresented: .constant(true)
    )
}
