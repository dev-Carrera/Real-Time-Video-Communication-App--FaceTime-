//
//  Call_iOS.swift
//  FaceTime
//
//  Created by Raul Carrera on 6/13/26.
//

import SwiftUI
import LiveKit
import Combine

#if os(iOS)

final class CallDelegateIOS: NSObject, ObservableObject, RoomDelegate {
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

struct Call_iOS: View {
    
    private let cameraViewSize: Double = 35
    
    @StateObject private var room = Room()
    @StateObject private var callDelegate = CallDelegateIOS()
    
    private let url = "wss://LivekitServerLink.livekit"
    private let token : String

    init(code: String) {
        self.token = code
    }
    
    var body: some View {
        VStack {
            
            if let remoteTrack = callDelegate.remoteVideoTrack {
                SwiftUIVideoView(remoteTrack)
                    .overlay(
                        HStack {
                            Text("Username")
                                .foregroundStyle(.black)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding(.top, 45)
                            Spacer()
                            
                            if let localTrack = room.localParticipant.firstCameraPublication?.track as? VideoTrack {
                                SwiftUIVideoView(localTrack)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .frame(width: cameraViewSize * 4, height: cameraViewSize * 3)
                                    .frame(maxHeight: .infinity, alignment: .top)
                                    .padding(.top, 45)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding()
                    )
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                Text("Loading...")
                    .padding(.top, 120)
            }
            
        }
        .ignoresSafeArea()
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


#Preview {
    Call_iOS(code: "")
}


#endif
