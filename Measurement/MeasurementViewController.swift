//
//  MeasurementViewController.swift
//  Measurement
//
//  Created by Webappclouds on 22/08/24.
//


import UIKit
import ARKit


protocol MeasurementViewControllerDelegate:AnyObject {
    
    func getArea(area:Float)
}

class MeasurementViewController: UIViewController, ARSessionDelegate {
    
    
    @IBOutlet weak var sceneView:ARSCNView!
    
    weak var delegate:MeasurementViewControllerDelegate?
    
    
    var points:[SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = SCNDebugOptions.showFeaturePoints
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        
        let removeBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(removeTapped))
        
        navigationItem.rightBarButtonItems = [doneBtn,removeBtn]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesBackButton = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        configuration.environmentTexturing = .automatic
        
        sceneView.session.run(configuration)
       
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let location = gestureRecognize.location(in: sceneView)
            
        // Create a raycast query for a horizontal plane
        guard let raycastQuery = sceneView.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal) else {
            return
        }
        
        // Perform the raycast
        let results = sceneView.session.raycast(raycastQuery)
        
        if let result = results.first {
            let point = SCNNode(geometry: SCNCylinder(radius: 0.01, height: 0.1))
                point.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                // Convert the raycast result to a position in the 3D world
                point.position = SCNVector3(result.worldTransform.columns.3.x,
                                            result.worldTransform.columns.3.y,
                                            result.worldTransform.columns.3.z)
                
                sceneView.scene.rootNode.addChildNode(point)
            
            // for area calculation
            points.append(point)
            
        }
    }


    @objc
    func doneTapped() {
        let pointsMap = self.points.compactMap({ pt in
            return SIMD3(x: pt.position.x, y: pt.position.y, z: pt.position.z)
        })
        let area = calculateArea(of: pointsMap)
        navigationController?.popViewController(animated: true)
        delegate?.getArea(area: area)
        print("Area calculated using Mtk:- \(area)")
    }
    
    
    @objc
    func removeTapped() {
        if let lastPoint = points.last {
            
            lastPoint.removeFromParentNode()
            points.removeLast()
        }
    }
    

    func calculateArea(of points: [SIMD3<Float>]) -> Float {
        guard points.count > 2 else {
            print("Min 3 points are reqd for area calculation")
            return 0
        }
        
        var area: Float = 0
        let n = points.count
        
        for i in 0..<n {
            let point1 = points[i]
            let point2 = points[(i + 1) % n]
            
            // Using the Shoelace formula to calculate the area of the polygon
            area += (point1.x * point2.z) - (point1.z * point2.x)
        }
        
        return abs(area / 2.0)
    }
}

extension MeasurementViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print("Unable to find ARPlaneAnchor")
            return
        }
        
        print("plane detected")
        
        let width = CGFloat(planeAnchor.planeExtent.width)
        let height = CGFloat(planeAnchor.planeExtent.height)
        
        let plane = SCNPlane(width: width, height: height)
        
       let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        
        let gridMaterial = SCNMaterial()
        
        
        gridMaterial.diffuse.contents = UIImage(named: "grid")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        node.addChildNode(planeNode)
    }
    
    
    func renderer(_ renderer: any SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
            guard let planeAnchor = anchor as? ARPlaneAnchor,
                  let planeNode = node.childNodes.first,
                  let plane = planeNode.geometry as? SCNPlane else { return }
            
            // Update the plane's size
            plane.width = CGFloat(planeAnchor.planeExtent.width)
            plane.height = CGFloat(planeAnchor.planeExtent.height)
            
            // Update the plane's position
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
    }
}
