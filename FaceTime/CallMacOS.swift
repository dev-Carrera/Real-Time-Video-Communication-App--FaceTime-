//
//  Call.swift
//  FaceTime
//
//  Created by Raul Carrera on 6/10/26.
//

import SwiftUI
import LiveKit
import Combine

#if os(macOS)

final class CallDelegate: NSObject, ObservableObject, RoomDelegate {
    @Published var remoteVideoTrack: VideoTrack?
    
    func room(_ room: Room, participant: RemoteParticipant, didSubscribeTrack publication: RemoteTrackPublication) {
        guard let track = publication.track as? VideoTrack else { return }
        DispatchQueue.main.async {
            self.remoteVideoTrack = track
        }
    }
    
    func room(_ room: Room, participant: RemoteParticipant, didUnsubscribeTrack publication: RemoteTrackPublication) {
        DispatchQueue.main.async {
            self.remoteVideoTrack = nil
        }
    }
}

struct CallMacOS: View {
    
    
    @StateObject private var room = Room()
    @StateObject private var callDelegate = CallDelegate()
    
    private let url = "wss://LivekitServerLink.livekit.cloud"
    private let token : String
    
    init(code: String) {
        self.token = code
    }
    
    var body: some View {
        
        let myCameraViewSize: Double = 20
        let myCameraViewWidth: Double = myCameraViewSize * 6.0
        let myCameraViewHeight: Double = myCameraViewSize * 3.5
        
        VStack {
            if let remoteTrack = callDelegate.remoteVideoTrack {
                SwiftUIVideoView(remoteTrack)
                    .overlay(
                        VStack {
                            HStack {
                                VStack {
                                    Text("Friend's Name")
                                        .foregroundStyle(.black)
                                }
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                                
                                Spacer()
                                
                                VStack {
                                    if let localTrack = room.localParticipant.firstCameraPublication?.track as? VideoTrack {
                                        SwiftUIVideoView(localTrack)
                                            .frame(width: myCameraViewWidth, height: myCameraViewHeight, alignment: .top)
                                            .foregroundStyle(.black)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                .frame(maxHeight: .infinity, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding()
                            
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, maxHeight: 25, alignment: .center)
                                .padding(.leading, 10).padding(.trailing, 10)
                                .padding(.bottom, 10)
                        }
                    )
                    .foregroundStyle(.green)
            } else {
                Text("Loading...")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            room.add(delegate: callDelegate)
            do {
                try await room.connect(url: url, token: token)
                try await room.localParticipant.setCamera(enabled: true)
                try await room.localParticipant.setMicrophone(enabled: true)
            } catch {
                print("Failed to connect: \(error)")
            }
        }
        .onDisappear {
            Task {
                try await room.localParticipant.setCamera(enabled: false)
                try await room.localParticipant.setMicrophone(enabled: false)
                await room.disconnect()
            }
        }
    }
}

struct MacCameraView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> MacCameraViewController {
        return MacCameraViewController()
    }

    func updateNSViewController(_ nsViewController: MacCameraViewController, context: Context) {
    }
}

#Preview {
    CallMacOS(code: "")
}

#endif
