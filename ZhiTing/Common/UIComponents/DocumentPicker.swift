//
//  Document.swift
//  ZhiTing
//
//  Created by iMac on 2021/2/26.
//

import UIKit
import MobileCoreServices

protocol DocumentDelegate: class {
    func didPickDocument(document: Document?)
}

class Document: UIDocument {
    var data: Data?
    override func contents(forType typeName: String) throws -> Any {
        guard let data = data else { return Data() }
        return try NSKeyedArchiver.archivedData(withRootObject:data,
                                                requiringSecureCoding: true)
    }
    override func load(fromContents contents: Any, ofType typeName:
                        String?) throws {
        guard let data = contents as? Data else { return }
        self.data = data
    }
}

open class DocumentPicker: NSObject {
    private var pickerController: UIDocumentPickerViewController?
    private weak var presentationController: UIViewController?
    private weak var delegate: DocumentDelegate?
    
    private var pickedDocument: Document?
    
    init(presentationController: UIViewController, delegate: DocumentDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }
    
    public func displayPicker() {
        
        /// pick movies and images
        self.pickerController = UIDocumentPickerViewController(documentTypes: [
            kUTTypeZipArchive as String,
            kUTTypeBzip2Archive as String,
            kUTTypeGNUZipArchive as String
        ], in: .import)
        self.pickerController!.delegate = self
        self.presentationController?.present(self.pickerController!, animated: true)
    }
}

extension DocumentPicker: UIDocumentPickerDelegate {
    
    /// delegate method, when the user selects a file
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        documentFromURL(pickedURL: url)
        delegate?.didPickDocument(document: pickedDocument)
    }
    
    /// delegate method, when the user cancels
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        delegate?.didPickDocument(document: nil)
    }
    
    private func documentFromURL(pickedURL: URL) {
        
        /// start accessing the resource
        let shouldStopAccessing = pickedURL.startAccessingSecurityScopedResource()
        
        defer {
            if shouldStopAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
            }
        }
        NSFileCoordinator().coordinate(readingItemAt: pickedURL, error: NSErrorPointer.none) { (readURL) in
            let document = Document(fileURL: readURL)
            pickedDocument = document
        }
    }
}

// MARK: - Usage:

//      class ViewController: UIViewController, DocumentDelegate {
//          override func viewDidLoad() {
//              super.viewDidLoad()
//
//              /// set up the document picker
//              documentPicker = DocumentPicker(presentationController: self, delegate: self)
//          }
//
//          /// callback from the document picker
//          func didPickDocument(document: Document?) {
//              if let pickedDoc = document {
//                  let fileURL = pickedDoc.fileURL
//
//                  /// do what you want with the file URL
//              }
//          }
//      }
