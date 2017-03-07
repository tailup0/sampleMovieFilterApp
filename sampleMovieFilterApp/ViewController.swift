//
//  ViewController.swift
//  sampleMovieFilterApp
//
//  Created by Muneharu Onoue on 2017/03/07.
//  Copyright © 2017年 Muneharu Onoue. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {

    @IBOutlet weak var renderView: RenderView!
    var camera:Camera!
    var isRecording = false
    var movieOutput:MovieOutput? = nil
    var mvUrl:URL?
    var filterOperation: FilterOperationInterface?

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            camera = try Camera(sessionPreset:AVCaptureSessionPreset640x480)
            camera.runBenchmark = true
            let filterInList = filterOperations[0]
            self.filterOperation = filterInList
            if let currentFilterConfiguration = self.filterOperation {
                // Configure the filter chain, ending with the view
                if let view = self.renderView {
                    switch currentFilterConfiguration.filterOperationType {
                    case .singleInput:
                        camera.addTarget(currentFilterConfiguration.filter)
                        currentFilterConfiguration.filter.addTarget(view)
                    default :
                        break
                    }
                }
            }
            camera.startCapture()

        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func capture(_ sender: Any) {
        if (!isRecording) {
            do {
                self.isRecording = true
                let documentsDir = try FileManager.default.url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
                let fileURL = URL(string:"test.mp4", relativeTo:documentsDir)!
                mvUrl = fileURL
                do {
                    try FileManager.default.removeItem(at:fileURL)
                } catch {
                }
                
                movieOutput = try MovieOutput(URL:fileURL, size:Size(width:480, height:640), liveVideo:true)
                camera.audioEncodingTarget = movieOutput
                filterOperation!.filter --> movieOutput!
                movieOutput!.startRecording()
                DispatchQueue.main.async {
                    (sender as! UIButton).titleLabel!.text = "Stop"
                }
            } catch {
                fatalError("Couldn't initialize movie, error: \(error)")
            }
        } else {
            movieOutput?.finishRecording{
                self.isRecording = false
                DispatchQueue.main.async {
                    (sender as! UIButton).titleLabel!.text = "Record"
                }
                let assetsLib = ALAssetsLibrary()
                assetsLib.writeVideoAtPath(toSavedPhotosAlbum: self.mvUrl!, completionBlock: nil)
                self.camera.audioEncodingTarget = nil
                self.movieOutput = nil
            }
        }
    }

}

