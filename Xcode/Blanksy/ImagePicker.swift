//
//  ImagePicker.swift
//  Blanksy
//
//  Created by Vishal Moorjani on 3/1/25.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
         let picker = UIImagePickerController()
         picker.delegate = context.coordinator
         picker.sourceType = .photoLibrary
         return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed.
    }
    
    func makeCoordinator() -> Coordinator {
         Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
         let parent: ImagePicker
         
         init(_ parent: ImagePicker) {
             self.parent = parent
         }
         
         func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
             if let uiImage = info[.originalImage] as? UIImage {
                 parent.image = uiImage
             }
             parent.presentationMode.wrappedValue.dismiss()
         }
    }
}
