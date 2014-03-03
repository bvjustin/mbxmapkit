//
//  MBXRasterTileOverlay.h
//  MBXMapKit
//
//  Created by Will Snook on 3/2/14.
//  Copyright (c) 2014 MapBox. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MBXCacheManagerProtocol.h"
#import "MBXCacheManager.h"

@interface MBXRasterTileOverlay : MKTileOverlay

@property (assign) MBXRasterImageQuality imageQuality;

@property (nonatomic) NSString *mapID;

// Note how gets set to a default in init, but after that it can be changed to
// anything that implements MBXCacheManagerProtocol
//
@property (nonatomic) id<MBXCacheManagerProtocol> cacheManager;

@property (assign) BOOL inhibitTileJSON;
@property (assign) BOOL inhibitSimplestyle;
@property (assign) BOOL useTileJSONBoundsInsteadOfMapRectWorld;

@property (nonatomic) NSDictionary *tileJSONDictionary;

@property (atomic, assign) NSInteger centerZoom;
@property (atomic, assign) CLLocationCoordinate2D center;

@end
