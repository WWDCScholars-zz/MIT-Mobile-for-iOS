#import <CoreFoundation/CoreFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MGSRouteLayer.h"
#import "MGSLayer+Protected.h"
#import "MGSUtility.h"
#import "CoreLocation+MITAdditions.h"

@interface MGSRouteLayer ()
@property (nonatomic,strong) NSArray *pathCoordinates;
@property (nonatomic,strong) NSArray *stopAnnotations;
@property (nonatomic,weak) AGSMutablePolyline *polyline;
@property (nonatomic,weak) AGSGraphic *lineGraphic;
@end

@implementation MGSRouteLayer
- (id)initWithName:(NSString*)name withStops:(NSArray*)stopAnnotations pathCoordinates:(NSArray*)pathCoordinates
{
    self = [super initWithName:name];
    
    if (self)
    {
        self.stopAnnotations = stopAnnotations;
        self.pathCoordinates = pathCoordinates;
    }
    
    return self;
}


- (void)didReloadMapLayer
{
    [super didReloadMapLayer];
    
    AGSGraphicsLayer *layer = self.graphicsLayer;
    
    AGSMutablePolyline *polyline = self.polyline;
    if (self.polyline == nil)
    {
        polyline = [[AGSMutablePolyline alloc] initWithSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
    }
    
    if (polyline.numPaths > 0)
    {
        [polyline removePathAtIndex:0];
    }
    
    [polyline addPathToPolyline];
    
    for (NSValue *value in self.pathCoordinates)
    {
        CLLocationCoordinate2D coordinate = [value MKCoordinateValue];
        if (CLLocationCoordinate2DIsValid(coordinate))
        {
            [polyline addPointToPath:AGSPointFromCLLocationCoordinate(coordinate)];
        }
    }
    
    AGSGraphic *pathGraphic = [AGSGraphic graphicWithGeometry:polyline
                                                       symbol:[AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:16.0]
                                                   attributes:[NSMutableDictionary dictionary]
                                         infoTemplateDelegate:nil];
    
    [layer addGraphic:pathGraphic];
    [layer dataChanged];
}

@end
