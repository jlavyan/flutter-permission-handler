//
// Created by Razvan Lung(long1eu) on 2019-02-15.
// Copyright (c) 2019 The Chromium Authors. All rights reserved.
//

#import "PhotoPermissionStrategy.h"

#if PERMISSION_PHOTOS

@implementation PhotoPermissionStrategy
- (PermissionStatus)checkPermissionStatus:(PermissionGroup)permission {
    return [PhotoPermissionStrategy permissionStatus];
}

- (ServiceStatus)checkServiceStatus:(PermissionGroup)permission {
    return ServiceStatusNotApplicable;
}

- (void)requestPermission:(PermissionGroup)permission completionHandler:(PermissionStatusHandler)completionHandler {
    PermissionStatus status = [self checkPermissionStatus:permission];

    if (status != PermissionStatusNotDetermined) {
        completionHandler(status);
        return;
    }

    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
        if (@available(iOS 14, *)) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
            
            completionHandler([PhotoPermissionStrategy determinePermissionStatus:status]);
        } else {
            completionHandler([PhotoPermissionStrategy determinePermissionStatus:authorizationStatus]);
        }
    }];
}

+ (PermissionStatus)permissionStatus {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];

    if (@available(iOS 14, *)) {
        PHAuthorizationStatus s = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        
        return [PhotoPermissionStrategy determinePermissionStatus:s];
    } else {
        return [PhotoPermissionStrategy determinePermissionStatus:status];
    }

}

+ (PermissionStatus)determinePermissionStatus:(PHAuthorizationStatus)authorizationStatus {
    switch (authorizationStatus) {
        case PHAuthorizationStatusNotDetermined:
            return PermissionStatusNotDetermined;
        case PHAuthorizationStatusRestricted:
            return PermissionStatusRestricted;
        case PHAuthorizationStatusDenied:
            return PermissionStatusDenied;
        case PHAuthorizationStatusAuthorized:
            return PermissionStatusGranted;
        case PHAuthorizationStatusLimited:
            return PermissionStatusLimited;
            
    }

    return PermissionStatusNotDetermined;
}

@end

#else

@implementation PhotoPermissionStrategy
@end

#endif
