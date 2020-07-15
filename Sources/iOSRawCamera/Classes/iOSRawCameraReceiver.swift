//
//  iOSRawCameraReceiver.swift
//  
//
//  Created by Nomad Company on 6/5/20.
//

import Combine
import AVFoundation

/// Class that will serve as the receiver for `iOSRawCameraAuthorizationPublishers` sent from the implementing UI
public class iOSRawCameraAuthenticationReceiver {
    
    //The internal representation of the reults of an authorization request.
    private typealias CameraAuthorizationRequestResults = Result<AVAuthorizationAction, CameraAuthorizationController.CameraAuthorizationError>
    
    //The set of combine subscriptions this class subscribes to
    var subscriptions: Set<AnyCancellable> = []
    
    //Public initalizer. Once initalized the Combine subscriptions are set up.
    public init() {
        self.startSubscriptions()
    }
    
    
    //MARK: Functions
    func startSubscriptions() {
        
        //Subscribe to the `iOSRawCameraAuthorizationPublishers.requestCameraAuthorization` publisher. This will allow us to take action when the user asks for permission to access the camera.
        let requestCameraAuthorizationSubscription = iOSRawCameraAuthorizationPublishers.requestCameraAuthorization.flatMap({ (request) -> AnyPublisher<CameraAuthorizationRequestResults, Never> in
            //Get an instance of the `CameraAuthorizationController`
            let cameraAuthorizationController = CameraAuthorizationController.init()
            //Call the request camera permission function which will return a future with the action that was completed or an error
            return cameraAuthorizationController.requestCameraPermission().map { (action) -> CameraAuthorizationRequestResults in
                //If we sucessfully authorized then pass the action back up the request
                return CameraAuthorizationRequestResults.success(action)
            }.catch { (error) -> AnyPublisher<CameraAuthorizationRequestResults, Never> in
                //If we had an error then publish the RequestResults with the error.
                return Just<CameraAuthorizationRequestResults>(CameraAuthorizationRequestResults.failure(error)).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
        }).sink { (result) in
            switch result {
            case .failure(let error):
                //If we had a faileur then pass the error through the appropriate publisher.
                iOSRawCameraAuthorizationPublishers.cameraAuthorizationError.send(error)
            case .success(_):
                //Get an instance of the `CameraAuthorizationController`
                let cameraAuthorizationController = CameraAuthorizationController.init()
                //Pass the value of the AVAuthorizationStatus through this publisher.
                iOSRawCameraAuthorizationPublishers.cameraAuthorization.send(cameraAuthorizationController.authorizationStatus())
            }
        }
        
        //Add the subscription to the set of subscriptions.
        self.subscriptions.insert(requestCameraAuthorizationSubscription)
    }
    
    /// Loops though the Combine subscriptions and cancells them
    func cancelCombineSubscriptions() {
        for item in self.subscriptions {
            item.cancel()
        }
        self.subscriptions.removeAll()
    }
    
    //The de-init will remove the combine subscriptions.
    deinit {
        self.cancelCombineSubscriptions()
    }
}
