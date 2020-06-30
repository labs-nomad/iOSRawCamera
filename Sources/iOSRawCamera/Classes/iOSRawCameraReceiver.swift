//
//  iOSRawCameraReceiver.swift
//  
//
//  Created by Nomad Company on 6/5/20.
//

import Combine
import AVFoundation

/// Class that will serve as the receiver for
public class iOSRawCameraReceiver {
    
    let cameraAuthorizationController = CameraAuthorizationController.init()
    
    typealias BoolResult = Result<Bool, CameraAuthorizationController.CameraAuthorizationError>
    
    var subscriptions: Set<AnyCancellable> = []
    
    public init() {
        self.startSubscriptions()
    }
    
    
    //MARK: Functions
    
    func cancelCombineSubscriptions() {
        for item in self.subscriptions {
            item.cancel()
        }
        self.subscriptions.removeAll()
    }
    
    deinit {
        self.cancelCombineSubscriptions()
    }
}

extension iOSRawCameraReceiver {
    func startSubscriptions() {
        
        let requestCameraAuthorizationSubscription = iOSRawCameraPublishers.requestCameraAuthorization.flatMap({ (request) -> AnyPublisher<BoolResult, Never> in
            return self.cameraAuthorizationController.requestCameraPermission().map { (didComplete) -> BoolResult in
                return BoolResult.success(didComplete)
            }.catch { (error) -> AnyPublisher<BoolResult, Never> in
                return Just<BoolResult>(BoolResult.failure(error)).eraseToAnyPublisher()
            }.eraseToAnyPublisher()
        }).sink { (result) in
            switch result {
            case .failure(let error):
                iOSRawCameraPublishers.cameraAuthorizationError.send(error)
            case .success(_):
                iOSRawCameraPublishers.cameraAuthorization.send(self.cameraAuthorizationController.authorizationStatus())
            }
        }
        
        
        self.subscriptions.insert(requestCameraAuthorizationSubscription)
    }
}
