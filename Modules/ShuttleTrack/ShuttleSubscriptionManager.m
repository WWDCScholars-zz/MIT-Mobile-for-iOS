#import "ShuttleSubscriptionManager.h"
#import "ShuttleStop.h"
#import "ShuttleRoute.h"
#import "MITDeviceRegistration.h"
#import "MITTouchstoneRequestOperation+LegacyCompatibility.h"
#import "MITUIConstants.h"

@implementation ShuttleSubscriptionManager
	
+ (void) subscribeForRoute:(NSString *)routeID atStop:(NSString *)stopID scheduleTime: (NSDate *)time delegate: (id<ShuttleSubscriptionDelegate>)delegate object: (id)object {
	NSMutableDictionary *parameters = [[MITDeviceRegistration identity] mutableDictionary];
	[parameters setObject:routeID forKey:@"route"];
	[parameters setObject:stopID forKey:@"stop"];
	
	NSInteger unixtime_int = round([time timeIntervalSince1970]);
	NSString *unixtime_string = [NSString stringWithFormat:@"%i", unixtime_int];	
	[parameters setObject:unixtime_string forKey:@"time"];	

    NSURLRequest *request = [NSURLRequest requestForModule:@"shuttles" command:@"subscribe" parameters:parameters];
    MITTouchstoneRequestOperation *requestOperation = [[MITTouchstoneRequestOperation alloc] initWithRequest:request];
    requestOperation.completeBlock = ^(MITTouchstoneRequestOperation *operation, id jsonResult, NSString *contentType, NSError *error) {
        if (error || ![jsonResult isKindOfClass:[NSDictionary class]]) {
            [delegate subscriptionFailedWithObject:object passkeyError:NO];
            [UIAlertView alertViewForError:nil withTitle:@"Shuttles" alertViewDelegate:nil];

        } else if (!jsonResult[@"success"]) {
            [delegate subscriptionFailedWithObject:object passkeyError:YES];
        
        } else {
            NSNumber *startTimeNumber = jsonResult[@"start_time"];
            NSNumber *endTimeNumber = jsonResult[@"expire_time"];
            
            NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[startTimeNumber doubleValue]];
            NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[endTimeNumber doubleValue]];
            
            [ShuttleSubscriptionManager addSubscriptionForRouteID:routeID atStopID:stopID startTime:startTime endTime:endTime];
            [delegate subscriptionSucceededWithObject:object];
        }
    };
    
    [[NSOperationQueue mainQueue] addOperation:requestOperation];
}

+ (void) unsubscribeForRoute:(NSString *)routeID atStop:(NSString *)stopID delegate: (id<ShuttleSubscriptionDelegate>)delegate object: (id)object {
	NSMutableDictionary *parameters = [[MITDeviceRegistration identity] mutableDictionary];
	[parameters setObject:routeID forKey:@"route"];
	[parameters setObject:stopID forKey:@"stop"];

    NSURLRequest *request = [NSURLRequest requestForModule:@"shuttles" command:@"unsubscribe" parameters:parameters];
    MITTouchstoneRequestOperation *requestOperation = [[MITTouchstoneRequestOperation alloc] initWithRequest:request];
	requestOperation.completeBlock = ^(MITTouchstoneRequestOperation *operation, id jsonResult, NSString *contentType, NSError *error) {
        if (error) {
            [delegate subscriptionFailedWithObject:object passkeyError:NO];
            [UIAlertView alertViewForError:nil withTitle:@"Shuttles" alertViewDelegate:nil];
            
        } else {
            [ShuttleSubscriptionManager removeSubscriptionForRouteID:routeID atStopID:stopID];
            [delegate subscriptionSucceededWithObject:object];
        }
    };
    
    [[NSOperationQueue mainQueue] addOperation:requestOperation];
}
	
+ (BOOL) hasSubscription: (NSString *)routeID atStop: (NSString *)stopID scheduleTime: (NSDate *)time {
	[self pruneSubscriptions];
	
	NSDictionary *savedSubscriptions = [[NSUserDefaults standardUserDefaults] objectForKey:ShuttleSubscriptionsKey];
	
	NSArray *subscriptionTimeWindow = savedSubscriptions[routeID][stopID];
	if(subscriptionTimeWindow) {
		NSDate *startTime = subscriptionTimeWindow[0];
		NSDate *endTime = subscriptionTimeWindow[1];
		
		// check if time is within time interval
		return ([time timeIntervalSinceDate:startTime] > 0) && ([time timeIntervalSinceDate:endTime] < 0);
	}
	return NO;
}
			
+ (void) pruneSubscriptions {		
	NSDictionary *subscriptions = [[NSUserDefaults standardUserDefaults] objectForKey:ShuttleSubscriptionsKey];
	NSMutableDictionary *mutableSubscriptions = [NSMutableDictionary dictionaryWithDictionary:subscriptions];
	for(NSString *routeID in [mutableSubscriptions allKeys]) {
		NSMutableDictionary *mutableRouteStopsDictionary = [NSMutableDictionary dictionaryWithDictionary:mutableSubscriptions[routeID]];
		for(NSString *aStopKey in [mutableRouteStopsDictionary allKeys]) {
			NSDate *endTime = ((NSArray *)mutableRouteStopsDictionary[aStopKey])[1];
			if([endTime timeIntervalSinceNow] < 0) {
				// this subscription is in the past it needs to be cleared
				[mutableRouteStopsDictionary removeObjectForKey:aStopKey];
			}
		}
		
		// check if the subscriptions for route are now empty
		// if not empty, update main dictionary, otherwise delete this route dictionary
		if([[mutableRouteStopsDictionary allKeys] count]) {
			[mutableSubscriptions setObject:mutableRouteStopsDictionary forKey:routeID];
		} else {
			[mutableSubscriptions removeObjectForKey:routeID];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:mutableSubscriptions forKey:ShuttleSubscriptionsKey];
}
	

+ (void)addSubscriptionForRouteID:(NSString *)routeID atStopID:(NSString *)stopID startTime:(NSDate *)startTime endTime: (NSDate *)endTime {
	NSDictionary *subscriptions = [[NSUserDefaults standardUserDefaults] objectForKey:ShuttleSubscriptionsKey];
	
	NSMutableDictionary *mutableSubscriptions = [NSMutableDictionary dictionaryWithDictionary:subscriptions];
	NSMutableDictionary *routeSubscriptions = mutableSubscriptions[routeID];
	
	if(!routeSubscriptions) {
		routeSubscriptions = [NSMutableDictionary dictionary];
	} else {
		routeSubscriptions = [NSMutableDictionary dictionaryWithDictionary:routeSubscriptions];
	}
	[mutableSubscriptions setObject:routeSubscriptions forKey:routeID];
	
	[routeSubscriptions setObject:[NSArray arrayWithObjects:startTime, endTime, nil] forKey:stopID];
	
	[[NSUserDefaults standardUserDefaults] setObject:mutableSubscriptions forKey:ShuttleSubscriptionsKey];
}

+ (void)removeSubscriptionForRouteID:(NSString *)routeID atStopID: (NSString *)stopID {
	NSDictionary *subscriptions = [[NSUserDefaults standardUserDefaults] objectForKey:ShuttleSubscriptionsKey];

	NSMutableDictionary *mutableSubscriptions = [NSMutableDictionary dictionaryWithDictionary:subscriptions];
	NSMutableDictionary *routeSubscriptions = mutableSubscriptions[routeID];

	if(!routeSubscriptions) {
		// no subscription found
		return;
	}

	routeSubscriptions = [NSMutableDictionary dictionaryWithDictionary:routeSubscriptions];
	[mutableSubscriptions setObject:routeSubscriptions forKey:routeID];
	[routeSubscriptions removeObjectForKey:stopID];

	[[NSUserDefaults standardUserDefaults] setObject:mutableSubscriptions forKey:ShuttleSubscriptionsKey];
}
			
@end

