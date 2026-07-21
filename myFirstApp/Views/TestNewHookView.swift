//
//  TestNewHookView.swift
//  myFirstApp
//
//  "Test New" flow: submit an untested hook idea — text (75 char limit)
//  or video (upload/record, 6-second max) for community feedback.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct TestNewHookView: View {
    init() {
        let green = UIColor(red: 0.13, green: 0.55, blue: 0.40, alpha: 1)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: green], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: green.withAlphaComponent(0.6)], for: .normal)
    }
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var bookmarks: BookmarkStore

    @State private var kind: HookKind = .text
    @State private var selectedTopics: Set<String> = []
    @State private var textContent: String = ""
    @State private var videoURL: URL?
    @State private var videoDuration: Double = 0
    @State private var videoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showSavedConfirmation = false
    @State private var showAddedPopup = false
    @State private var videoError: String?

    private let textCharacterLimit = 75
    private let maxVideoDuration: Double = 6.0

    var body: some View {
        if session.isSignedIn {
            signedInBody
        } else {
            // Signing in here swaps this view to the form in place, so the
            // user lands on Test My Hook rather than bouncing to the menu.
            AuthGateScreen()
        }
    }

    private var signedInBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Hook type", selection: $kind) {
                    Text("Text").tag(HookKind.text)
                    Text("Video").tag(HookKind.video)
                }
                .pickerStyle(.segmented)

                Text(kind == .video
                     ? "Use multiple clips in the first few seconds or a stop-motion frame to grab attention instantly."
                     : "Instagram recommends keeping hooks under 75 characters.")
                    .font(HPFont.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                contentField

                VStack(alignment: .leading, spacing: 8) {
                    Text("What topic(s) does this fit?")
                        .font(HPFont.body).foregroundColor(.white)
                    Text("Pick at least one — it's how the right creators find your hook to rate.")
                        .font(HPFont.caption).foregroundColor(.white.opacity(0.7))
                    TopicSelectGrid(selected: $selectedTopics)
                }

                Button("TEST") { save() }
                    .buttonStyle(HPSecondaryButtonStyle())
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
            }
            .padding()
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .overlay {
            if showAddedPopup {
                ZStack {
                    Color.black.opacity(0.45).ignoresSafeArea()
                    VStack(spacing: 18) {
                        Text("Added to the community!")
                            .font(HPFont.heading)
                            .foregroundColor(HPColor.backgroundDark)
                            .multilineTextAlignment(.center)
                        Text("While you wait for results...")
                            .font(HPFont.body)
                            .foregroundColor(HPColor.backgroundDark.opacity(0.8))
                            .multilineTextAlignment(.center)
                        VStack(spacing: 12) {
                            NavigationLink {
                                ResearchGridView()
                            } label: {
                                Text("EXPLORE MORE HOOKS")
                            }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelPink, fullWidth: true))

                            NavigationLink {
                                SavedHooksView()
                            } label: {
                                Text("SEE SAVED HOOKS")
                            }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue, fullWidth: true))
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(32)
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            VideoCaptureView(videoURL: $videoURL, maxDuration: maxVideoDuration)
        }
        .onChange(of: videoURL) { _, url in
            if let url { checkVideoDuration(url) }
        }
    }

    // MARK: - Content fields

    @ViewBuilder
    private var contentField: some View {
        switch kind {
        case .text:
            VStack(alignment: .leading, spacing: 4) {
                TextEditor(text: $textContent)
                    .font(HPFont.body)
                    .multilineTextAlignment(.leading)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("\(textContent.count)/\(textCharacterLimit)")
                    .font(HPFont.caption)
                    .foregroundColor(textContent.count > textCharacterLimit ? .red : HPColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                if textContent.count > textCharacterLimit {
                    Text("Hook exceeds \(textCharacterLimit) characters — keep it short and punchy!")
                        .font(HPFont.caption)
                        .foregroundColor(.red)
                }
            }
        case .video:
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    PhotosPicker(selection: $videoItem, matching: .videos) {
                        Label("Upload", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(HPSecondaryButtonStyle())
                    .onChange(of: videoItem) { _, newItem in
                        Task {
                            if let url = try? await newItem?.loadTransferable(type: VideoTransferable.self) {
                                videoURL = url.url
                            }
                        }
                    }

                    Button {
                        showCamera = true
                    } label: {
                        Label("Record", systemImage: "video.fill")
                    }
                    .buttonStyle(HPSecondaryButtonStyle())
                }

                if let error = videoError {
                    Text(error)
                        .font(HPFont.caption)
                        .foregroundColor(.red)
                }

                if let url = videoURL, videoDuration <= maxVideoDuration {
                    VideoPreviewView(url: url)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Text(String(format: "%.1fs / %.0fs", videoDuration, maxVideoDuration))
                        .font(HPFont.caption)
                        .foregroundColor(HPColor.textSecondary)
                }
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Validation & Save

    private var isValid: Bool {
        guard !selectedTopics.isEmpty else { return false }
        switch kind {
        case .text:
            let trimmed = textContent.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && trimmed.count <= textCharacterLimit
        case .video:
            return videoURL != nil && videoDuration <= maxVideoDuration && videoDuration > 0
        default: return false
        }
    }

    private func checkVideoDuration(_ url: URL) {
        let asset = AVURLAsset(url: url)
        Task {
            let duration = try? await asset.load(.duration)
            let seconds = duration.map { CMTimeGetSeconds($0) } ?? 0
            await MainActor.run {
                videoDuration = seconds
                if seconds > maxVideoDuration {
                    videoError = "Video is \(String(format: "%.1f", seconds))s — must be \(Int(maxVideoDuration))s or less."
                } else {
                    videoError = nil
                }
            }
        }
    }

    private func save() {
        var videoFile: String?
        if kind == .video, let url = videoURL {
            videoFile = store.saveVideo(url)
        }

        let hook = Hook(
            id: UUID(),
            source: .testNew,
            kind: kind,
            linkURL: nil,
            textContent: kind == .text ? textContent : nil,
            imageFileName: nil,
            videoFileName: videoFile,
            metrics: nil,
            createdAt: Date(),
            datePosted: nil,
            authorDisplayName: session.displayName,
            aiSummary: nil, skipRate: nil, claimedBy: nil,
            topics: Array(selectedTopics)
        )
        store.add(hook)
        // Hooks sent to Test automatically land in the Saved list.
        bookmarks.add(hook.id)
        showAddedPopup = true
    }
}
