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
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var store: HookStore

    @State private var kind: HookKind = .text
    @State private var textContent: String = ""
    @State private var videoURL: URL?
    @State private var videoDuration: Double = 0
    @State private var videoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showSavedConfirmation = false
    @State private var videoError: String?

    private let textCharacterLimit = 75
    private let maxVideoDuration: Double = 6.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Hook type", selection: $kind) {
                    Text("Text").tag(HookKind.text)
                    Text("Video").tag(HookKind.video)
                }
                .pickerStyle(.segmented)

                contentField

                Button("SAVE") { save() }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelPink, fullWidth: true))
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
            }
            .padding()
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 16) } }
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .sheet(isPresented: $showSavedConfirmation) {
            SavedConfirmationView()
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
            VStack(alignment: .trailing, spacing: 4) {
                TextEditor(text: $textContent)
                    .font(HPFont.body)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("\(textContent.count)/\(textCharacterLimit)")
                    .font(HPFont.caption)
                    .foregroundColor(textContent.count > textCharacterLimit ? .red : HPColor.textSecondary)
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
            authorDisplayName: session.displayName
        )
        store.add(hook)
        showSavedConfirmation = true
    }
}
