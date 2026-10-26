//
//  ContentView.swift
//  FaceTime
//
//  Created by Raul Carrera on 6/10/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var  username : String = ""
    @State private var  code : String = ""
    
    @State private var currentScreen : AppScreen = .home
    
    var body: some View {
        NavigationStack{
            if currentScreen == .home{
                VStack {
                    
                    // MARK: Title and subtitle
                    HStack{
                        Text("Start a FaceTime")
                            .font(.system(.title))
                        Image(systemName: "camera")
                            .imageScale(.large)
                            .foregroundStyle(.primary)
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 15)
                    Text("To start, enter a username and code below.")
                        .font(.system(.subheadline))
                        .padding(.bottom, 150)
                    
                    
                    
                    // MARK: Textfields
                    TextField("Enter a Username ",
                              text: $username,
                              prompt: Text("Enter a Username") .foregroundStyle(.purple .opacity(0.5)) .font(.system(size: 16))
                    )
                    .textFieldStyle(.plain)
                    .foregroundStyle(.purple . opacity(0.5))
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.purple,  lineWidth: 1)
                            .foregroundStyle(.clear)
                    )
                    
                    TextField("Enter a Friend ",
                              text: $code,
                              prompt: Text("Enter a Friend") .foregroundStyle(.purple .opacity(0.5)) .font(.system(size: 16))
                    )
                    .textFieldStyle(.plain)
                    .foregroundStyle(.purple . opacity(0.5))
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.purple,  lineWidth: 1)
                            .foregroundStyle(.clear)
                    )
                    
                    Spacer()
                    
                    // MARK: Join Button
                    Button(action:{
                        self.currentScreen = .call
                    }){
                        RoundedRectangle(cornerRadius: 8) .overlay(
                            Text("Connect")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .font(.system(size: 20))
                        )
                        .frame(width: .infinity, height: 50, alignment: .center)
                        .foregroundStyle(.purple)
                    }
                    .buttonStyle(.plain)
                    
                    
                    
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .top)
                .padding()
                .padding(.top, 10)
            }
            else if currentScreen == .call{
                #if os(macOS)
                CallMacOS(code: code)
                #elseif os(iOS)
                Call_iOS(code: code)
                #endif
            }
        }
    }
}

#Preview {
    ContentView()
}
