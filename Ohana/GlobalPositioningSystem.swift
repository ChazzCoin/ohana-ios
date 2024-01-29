//
//  GlobalPositioningSystem.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import Foundation
import SwiftUI
import Combine

class OrientationInfo: ObservableObject {
    @Published var orientation: UIDeviceOrientation = .unknown

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func orientationChanged() {
        orientation = UIDevice.current.orientation
    }
}

class GlobalPositioningSystem: ObservableObject {
    // Properties to store screen size and safe area insets
    @State var screenPaddingX: CGFloat = 50
    @State var screenPaddingY: CGFloat = 25
    @Published var screenSize: CGSize = UIScreen.main.bounds.size
    @Published var safeAreaInsets: EdgeInsets = EdgeInsets()
    @Published var orientation: UIDeviceOrientation = .unknown

    // Initialization
    init() {
        updateScreenSizeAndInsets()
        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenSizeAndInsets), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc private func updateScreenSizeAndInsets() {
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        if let temp = scene as? UIWindowScene {
            if let w = temp.windows.first {
                DispatchQueue.main.async {
                    self.screenSize = w.frame.size
                    let uiInsets = w.safeAreaInsets
                    self.safeAreaInsets = EdgeInsets(top: uiInsets.top, leading: uiInsets.left, bottom: uiInsets.bottom, trailing: uiInsets.right)
                }
            }
        }
    }
    
    @objc func orientationChanged() {
        orientation = UIDevice.current.orientation
    }

    // Function to get coordinates for specified area
    func getCoordinate(for area: ScreenArea) -> CGPoint {
        switch area {
            case .center:
                return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
            case .topRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX, y: safeAreaInsets.top + screenPaddingY)
            case .topLeft:
                return CGPoint(x: safeAreaInsets.leading, y: safeAreaInsets.top + screenPaddingY)
            case .bottomRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX, y: screenSize.height - safeAreaInsets.bottom - screenPaddingY)
            case .bottomLeft:
                return CGPoint(x: safeAreaInsets.leading, y: screenSize.height - safeAreaInsets.bottom)
            case .bottomCenter:
                return CGPoint(x: screenSize.width / 2, y: screenSize.height - safeAreaInsets.bottom)
            case .topCenter:
                return CGPoint(x: screenSize.width / 2, y: safeAreaInsets.top + screenPaddingY)
        }
    }
    
    // Function to get coordinates for specified area with an optional offset
    func getCoordinate(for area: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> CGPoint {
        switch area {
            case .center:
                return CGPoint(x: (screenSize.width / 2) + offsetX, y: (screenSize.height / 2) + offsetY)
            case .topRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX - offsetX, y: safeAreaInsets.top + screenPaddingY + offsetY)
            case .topLeft:
                return CGPoint(x: safeAreaInsets.leading + offsetX, y: safeAreaInsets.top + screenPaddingY + offsetY)
            case .bottomRight:
                return CGPoint(x: screenSize.width - safeAreaInsets.trailing - screenPaddingX - offsetX, y: screenSize.height - safeAreaInsets.bottom - screenPaddingY - offsetY)
            case .bottomLeft:
                return CGPoint(x: safeAreaInsets.leading + offsetX, y: screenSize.height - safeAreaInsets.bottom - offsetY)
            case .bottomCenter:
                return CGPoint(x: (screenSize.width / 2) + offsetX, y: screenSize.height - safeAreaInsets.bottom - offsetY)
            case .topCenter:
                return CGPoint(x: (screenSize.width / 2) + offsetX, y: safeAreaInsets.top + screenPaddingY + offsetY)
        }
    }

    
    // Function to get offsets for specified area as CGSize
    func getOffset(for area: ScreenArea) -> CGSize {
        switch area {
        case .center:
            return CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
        case .topRight:
            return CGSize(width: screenSize.width - safeAreaInsets.trailing, height: safeAreaInsets.top)
        case .topLeft:
            return CGSize(width: safeAreaInsets.leading, height: safeAreaInsets.top)
        case .bottomRight:
            return CGSize(width: screenSize.width - safeAreaInsets.trailing, height: screenSize.height - safeAreaInsets.bottom)
        case .bottomLeft:
            return CGSize(width: safeAreaInsets.leading, height: screenSize.height - safeAreaInsets.bottom)
        case .bottomCenter:
            return CGSize(width: screenSize.width / 2, height: screenSize.height - safeAreaInsets.bottom)
        case .topCenter:
            return CGSize(width: screenSize.width / 2, height: safeAreaInsets.top)
        }
    }
}

enum ScreenArea {
    case center, topRight, topLeft, bottomRight, bottomLeft, bottomCenter, topCenter
}



struct GlobalPositioningZStack<Content: View>: View {
    let content: (GeometryProxy, GlobalPositioningSystem) -> Content

    init(@ViewBuilder content: @escaping (GeometryProxy, GlobalPositioningSystem) -> Content) {
        self.content = content
    }

    
    @State var gps = GlobalPositioningSystem()
    
    @State var resetFlag = false
    func resetView() {
        resetFlag = true
        resetFlag = false
    }
    
    var body: some View {
        
        if !resetFlag {
            GeometryReader { geometry in
                content(geometry, gps)
            }
            .frame(maxWidth: gps.screenSize.width, maxHeight: gps.screenSize.height)
            .ignoresSafeArea(.all)
            .background(Color.clear)
            .onChange(of: self.gps.orientation, perform: { value in
                resetView()
            })
        }
        
    }
}
