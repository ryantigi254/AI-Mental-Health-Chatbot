//
//  DisclaimerPageView.swift
//  OLMoE.swift
//
//  Created by Thomas Jones on 11/13/24.
//


import SwiftUI

struct DisclaimerHandlers {
    /// A closure to set the active disclaimer.
    var setActiveDisclaimer: (Disclaimer?) -> Void

    /// A closure to set whether outside tap dismiss is allowed.
    var setAllowOutsideTapDismiss: (Bool) -> Void

    /// A closure to set the cancel action.
    var setCancelAction: ((() -> Void)?) -> Void

    /// A closure to set the confirm action.
    var setConfirmAction: (@escaping () -> Void) -> Void

    /// A closure to set whether to show the disclaimer page.
    var setShowDisclaimerPage: (Bool) -> Void
}

class DisclaimerState: ObservableObject {
#if DEBUG
    @Published private var hasSeenDisclaimer: Bool = false
#else
    @AppStorage("hasSeenDisclaimer") private var hasSeenDisclaimer : Bool = false
#endif
    /// A published property indicating whether to show the disclaimer page.
    @Published var showDisclaimerPage: Bool = false

    /// A published property holding the active disclaimer.
    @Published var activeDisclaimer: Disclaimer? = nil

    /// A published property indicating whether outside tap dismiss is allowed.
    @Published var allowOutsideTapDismiss: Bool = false

    /// A closure for the confirmation action.
    var onConfirm: (() -> Void)?

    /// A closure for the cancellation action.
    var onCancel: (() -> Void)?

    /// The index of the current disclaimer page.
    private var disclaimerPageIndex: Int = 0

    /// An array of disclaimers.
    let disclaimers: [Disclaimer] = [
        Disclaimers.FullDisclaimer()
    ]

    /// Displays the initial disclaimer if it hasn't been seen yet.
    func showInitialDisclaimer() {
        if !hasSeenDisclaimer {
            activeDisclaimer = disclaimers[disclaimerPageIndex]
            allowOutsideTapDismiss = false
            onCancel = nil
            onConfirm = nextDisclaimerPage
            showDisclaimerPage = true
        }
    }

    /// Advances to the next disclaimer page or dismisses the disclaimer if all have been seen.
    private func nextDisclaimerPage() {
        disclaimerPageIndex += 1
        if disclaimerPageIndex >= disclaimers.count {
            activeDisclaimer = nil
            disclaimerPageIndex = 0
            onConfirm = nil
            showDisclaimerPage = false
            hasSeenDisclaimer = true
        } else {
            activeDisclaimer = disclaimers[disclaimerPageIndex]
            onConfirm = nextDisclaimerPage
            onCancel = nil
            showDisclaimerPage = true
        }
    }
}

struct DisclaimerPageData {
    /// The title of the disclaimer page.
    let title: String

    /// The text content of the disclaimer.
    let text: String

    /// The text for the confirmation button.
    let buttonText: String
}

struct DisclaimerPage: View {
    /// A typealias for a button configuration.
    typealias PageButton = (text: String, onTap: () -> Void)

    /// A flag indicating whether outside tap dismiss is allowed.
    let allowOutsideTapDismiss: Bool

    /// A binding that indicates whether the disclaimer page is presented.
    @Binding var isPresented: Bool

    /// The message content of the disclaimer.
    let message: String

    /// The title of the disclaimer.
    let title: String

    /// An array of header-text pairs for additional information.
    let titleText: [HeaderTextPair]

    /// The configuration for the confirmation button.
    let confirm: PageButton

    /// The configuration for the optional cancel button.
    let cancel: PageButton?
    
    // Track scroll position to enable the confirm button only when scrolled to bottom
    @State private var hasScrolledToBottom = false
    @State private var scrollViewHeight: CGFloat = 0
    @State private var scrollContentHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    public var body: some View {
        VStack(spacing: 0) {
            // Welcome header (always visible)
            VStack(spacing: 16) {
                Image("Ai2Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
                
                Text("Welcome to OLMoE")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Please accept the terms to continue")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 8)
                
                Divider()
            }
            .padding([.horizontal, .top], 24)
            
            // Scrollable disclaimer content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        if !title.isEmpty {
                            Text(title)
                                .font(.title())
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.top, 24)
                        }

                        if !message.isEmpty {
                            Text(.init(message))
                                .font(.body())
                                .multilineTextAlignment(.leading)
                        }

                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(titleText) { t in
                                HeaderTextPairView(header: t.header, text: t.text)
                            }
                        }
                        
                        // Invisible marker at the bottom
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding([.horizontal], 24)
                    .padding(.bottom, 100) // Add space at bottom for buttons
                    .background(GeometryReader { geo in
                        Color.clear.preference(
                            key: ViewHeightKey.self, 
                            value: geo.frame(in: .named("scrollView")).size.height
                        )
                    })
                }
                .background(GeometryReader { geo in
                    Color.clear.onAppear {
                        scrollViewHeight = geo.size.height
                    }
                })
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(ViewHeightKey.self) { contentHeight in
                    scrollContentHeight = contentHeight
                }
                .onScrollPositionChange { offset in
                    scrollOffset = offset.y
                    // Check if scrolled to bottom (with a small margin)
                    hasScrolledToBottom = (scrollOffset + scrollViewHeight) >= (scrollContentHeight - 50)
                }
            }
            
            // Fixed buttons at bottom
            VStack {
                HStack(spacing: 12) {
                    if let cancel = cancel {
                        Button(cancel.text) {
                            cancel.onTap()
                        }
                        .buttonStyle(.SecondaryButton)
                    }

                    Button(confirm.text) {
                        confirm.onTap()
                    }
                    .buttonStyle(.PrimaryButton)
                    .opacity(hasScrolledToBottom ? 1.0 : 0.5)
                    .disabled(!hasScrolledToBottom)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                if !hasScrolledToBottom {
                    Text("Please scroll to read the full terms")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(Color(.systemBackground))
                    .shadow(radius: 2, y: -2)
            )
        }
    }
}

// Helper to track scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

extension View {
    func onScrollPositionChange(perform action: @escaping (CGPoint) -> Void) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geo.frame(in: .named("scrollView")).origin
                )
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
    }
}

struct DisclaimerPageView: View {
    let disclaimer: Disclaimer
    let allowOutsideTapDismiss: Bool
    let onCancel: (() -> Void)?
    let onConfirm: (() -> Void)?
    
    @State private var isPresented = true
    
    var body: some View {
        DisclaimerPage(
            allowOutsideTapDismiss: allowOutsideTapDismiss,
            isPresented: $isPresented,
            message: disclaimer.text,
            title: disclaimer.title,
            titleText: disclaimer.headerTextContent,
            confirm: (text: disclaimer.buttonText, onTap: {
                if let onConfirm = onConfirm {
                    onConfirm()
                }
            }),
            cancel: onCancel != nil ? (text: "Cancel", onTap: {
                if let onCancel = onCancel {
                    onCancel()
                }
            }) : nil
        )
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview("DisclaimerPage") {
    DisclaimerPage(
        allowOutsideTapDismiss: false,
        isPresented: .constant(true),
        message: "Message",
        title: "Title",
        titleText: [HeaderTextPair](),
        confirm: (text: "Confirm", onTap: { print("Confirmed") }),
        cancel: (text: "Cancel", onTap: { print("Cancelled") })
    )
}
