//
//  ContentView.swift
//  reedcam
//
//  Created by Mugurel Moscaliuc on 11/03/2022.
//

import SwiftUI
import MobileCoreServices

struct ContentView: View {
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var value: String = ""
    @State private var status: String = ""
    @State private var showScanner = false
    
    var body: some View {
        VStack {
            Text(value)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 10)
            Text(status)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding()
            Button {
                value = ""
                showScanner.toggle()
            } label: {
                Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .frame(width: 70, height: 70, alignment: .center)
                    .foregroundColor(Color(UIColor(named: "TheGreen")!))
            }
        }
        .sheet(isPresented: $showScanner) {
            
        } content: {
            ScannerView(value: $value)
                .onChange(of: value) { newValue in
                    if !newValue.isEmpty {
                        UIPasteboard.general.string = value
                        status = "Copied to clipboard"
                        showScanner.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                            status = ""
                        }
                    }
                }
        }
        
    }
}
