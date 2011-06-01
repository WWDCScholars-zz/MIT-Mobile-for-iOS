#import "FacilitiesCategory.h"

@implementation FacilitiesCategory
@dynamic uid;
@dynamic name;
@dynamic lastUpdated;
@dynamic subcategories;
@dynamic locations;
@dynamic parent;

- (void)addSubcategoriesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subcategories"] addObject:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSubcategoriesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subcategories"] removeObject:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSubcategories:(NSSet *)value {    
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subcategories"] unionSet:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSubcategories:(NSSet *)value {
    [self willChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"subcategories"] minusSet:value];
    [self didChangeValueForKey:@"subcategories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addLocationsObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"locations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"locations"] addObject:value];
    [self didChangeValueForKey:@"locations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeLocationsObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"locations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"locations"] removeObject:value];
    [self didChangeValueForKey:@"locations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addLocations:(NSSet *)value {    
    [self willChangeValueForKey:@"locations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"locations"] unionSet:value];
    [self didChangeValueForKey:@"locations" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeLocations:(NSSet *)value {
    [self willChangeValueForKey:@"locations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"locations"] minusSet:value];
    [self didChangeValueForKey:@"locations" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}



@end