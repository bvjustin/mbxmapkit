//
//  MBXxViewController.m
//  MBXMapKit iOS Demo v030
//
//  Created by Will Snook on 3/2/14.
//  Copyright (c) 2014 MapBox. All rights reserved.
//

#import "MBXxViewController.h"
#import "MBXRasterTileOverlay.h"
#import "MBXCacheManager.h"

@interface MBXxViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) MBXRasterTileOverlay *rasterOverlay;
@property (nonatomic) MBXSimplestyle *simplestyle;
@property (nonatomic) UIActionSheet *actionSheet;

@end

@implementation MBXxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //[[MBXCacheManager sharedCacheManager] clearEntireCache];

    _rasterOverlay = [[MBXRasterTileOverlay alloc] init];
    _rasterOverlay.delegate = self;
    _rasterOverlay.mapID = @"examples.map-pgygbwdm";

    _simplestyle = [[MBXSimplestyle alloc] init];
    _simplestyle.delegate = self;
    _simplestyle.mapID = @"examples.map-pgygbwdm";

    [_mapView addOverlay:_rasterOverlay];
    _mapView.delegate = self;
}


- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
    // Schedule cache sweeps to occur each time a batch of tiles finishes rendering
    //
    [[MBXCacheManager sharedCacheManager] sweepCache];
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    // This is required boilerplate code to connect tile overlay layers with suitable renderers
    //
    if ([overlay isKindOfClass:[MBXRasterTileOverlay class]])
    {
        MKTileOverlayRenderer *renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
        return renderer;
    }
    return nil;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Required boilerplate code to connect annotations with suitable views
    //
    if ([annotation isKindOfClass:[MBXPointAnnotation class]])
    {
        static NSString *MBXSimpleStyleReuseIdentifier = @"MBXSimpleStyleReuseIdentifier";
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:MBXSimpleStyleReuseIdentifier];
        if (!view)
        {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MBXSimpleStyleReuseIdentifier];
        }
        view.image = ((MBXPointAnnotation *)annotation).image;
        view.canShowCallout = YES;
        return view;
    }
    return nil;
}


- (void)didLoadTileJSONForTileOverlay:(MBXRasterTileOverlay *)rasterOverlay
{
    // This required delegate callback is for centering the map once the TileJSON has been loaded
    //
    MKCoordinateRegion region = MKCoordinateRegionMake(rasterOverlay.center, MKCoordinateSpanMake(0, 360 / pow(2, rasterOverlay.centerZoom) * _mapView.frame.size.width / 256));
    [_mapView setRegion:region animated:NO];
}


- (void)didParseSimplestylePoint:(MBXPointAnnotation *)pointAnnotation
{
    // This required delegate callback is for adding points to an MKMapView when they are successfully parsed from the simplestyle
    //
    [_mapView addAnnotation:pointAnnotation];
}


- (void)didFailToLoadTileJSONForMapID:(NSString *)mapID withError:(NSError *)error
{
    // This optional delegate callback is for handling situations when something goes wrong with the TileJSON
    //
    NSLog(@"Delegate received notification of TileJSON loading failure - (%@)",error?error:@"");
}


- (void)didFailToLoadSimplestyleForMapID:(NSString *)mapID withError:(NSError *)error
{
    // This optional delegate callback is for handling situations when something goes wrong with the simplestyle
    //
    NSLog(@"Delegate received notification of Simplestyle loading failure - (%@)",error?error:@"");
}


- (UIActionSheet *)universalActionSheet
{
    // Demo app: This is the list of options for selecting which map should be shown by the demo app
    //
    return [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"OSM world map",@"OSM over Apple satellite",@"Terrain under Apple labels",@"Tilemill bounded region",@"Tilemill region over Apple",@"Tilemill transparent over Apple", nil];
}


- (IBAction)iPadInfoButtonAction:(id)sender {
    // Demo app: This responds to the info button from the iPad storyboard getting pressed
    //
    if(_actionSheet.visible) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
        _actionSheet = nil;
    } else {
        _actionSheet = [self universalActionSheet];
        [_actionSheet showFromRect:((UIButton *)sender).frame inView:self.view animated:YES];
    }
}


- (IBAction)iPhoneInfoButtonAction:(id)sender {
    // Demo app: This responds to the info button from the iPhone storyboard getting pressed
    //
    if(_actionSheet.visible) {
        [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:YES];
        _actionSheet = nil;
    } else {
        _actionSheet = [self universalActionSheet];
        [_actionSheet showFromRect:((UIButton *)sender).frame inView:self.view animated:YES];
    }
}


- (void)resetMapViewAndRasterOverlayDefaults
{
    // Demo app: This method prepares the MKMapView to switch overlays. Note that the specific order
    // in which things happen is quite important. One of the goals here is to fully disconnect old
    // tile overlays, annotations, and simplestyle prior to adding their new replacements. The
    // consequences of not doing that could potentially include stuff like EXEC_BAD_ACCESS, so it's
    // good to handle these things carefully.
    //
    _mapView.mapType = MKMapTypeStandard;

    // Set up a new tile overlay to account for the possibility that there are still tiles or TileJSON being downloaded
    //
    _rasterOverlay.delegate = nil;
    [_mapView removeOverlays:_mapView.overlays];
    _rasterOverlay = [[MBXRasterTileOverlay alloc] init];
    _rasterOverlay.delegate = self;

    // Set up a new simplestyle object to account for the possibility that there are still point icons being downloaded
    //
    _simplestyle.delegate = nil;
    [_mapView removeAnnotations:_mapView.annotations];
    _simplestyle = [[MBXSimplestyle alloc] init];
    _simplestyle.delegate = self;

    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    _rasterOverlay.canReplaceMapContent = YES;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Demo app: This switches between maps in response to action sheet selections
    //
    switch(buttonIndex) {
        case 0:
            // OSM world map
            [self resetMapViewAndRasterOverlayDefaults];
            _rasterOverlay.mapID = _simplestyle.mapID = @"examples.map-pgygbwdm";
            [_mapView addOverlay:_rasterOverlay];
            break;
        case 1:
            // OSM over Apple satellite
            [self resetMapViewAndRasterOverlayDefaults];
            _mapView.mapType = MKMapTypeSatellite;
            _rasterOverlay.canReplaceMapContent = NO;
            _rasterOverlay.mapID = @"justin.map-9tlo4knw";
            [_mapView addOverlay:_rasterOverlay];
            break;
        case 2:
            // Terrain under Apple labels
            [self resetMapViewAndRasterOverlayDefaults];
            _rasterOverlay.mapID = @"justin.map-mf07hryq";
            [_mapView insertOverlay:_rasterOverlay atIndex:0 level:MKOverlayLevelAboveRoads];
            break;
        case 3:
            // Tilemill bounded region (scroll & zoom limited to programmatic control only)
            [self resetMapViewAndRasterOverlayDefaults];
            _mapView.scrollEnabled = NO;
            _mapView.zoomEnabled = NO;
            _rasterOverlay.mapID = @"justin.NACIS2012";
            [_mapView addOverlay:_rasterOverlay];
            break;
        case 4:
            // Tilemill region over Apple
            [self resetMapViewAndRasterOverlayDefaults];
            _rasterOverlay.canReplaceMapContent = NO;
            _rasterOverlay.mapID = @"justin.clp-2011-11-03-1200";
            [_mapView addOverlay:_rasterOverlay];
            break;
        case 5:
            // Tilemill transparent over Apple
            [self resetMapViewAndRasterOverlayDefaults];
            _rasterOverlay.canReplaceMapContent = NO;
            _rasterOverlay.mapID = @"justin.pdx_meters";
            [_mapView addOverlay:_rasterOverlay];
            break;
    }
}

@end
