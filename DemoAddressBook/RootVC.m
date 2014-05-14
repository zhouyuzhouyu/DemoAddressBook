//
//  RootVC.m
//  DemoAddressBook
//
//  Created by 周玉 on 14-5-14.
//  Copyright (c) 2014年 huoli. All rights reserved.
//

#import "RootVC.h"
#import <AddressBook/AddressBook.h>
#import "Person.h"

@interface RootVC ()
<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) NSMutableArray *arrTitles;

@end

@implementation RootVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    
    ABAddressBookRef addressBooks = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);

        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    }
    else
    {
        addressBooks = ABAddressBookCreate();
    }

    NSMutableArray *arrM1 = [NSMutableArray array];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    for(int i = 0; i < CFArrayGetCount(allPeople); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        NSString *personName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if ([personName length]>0) {
            Person *per = [[Person alloc] init];
            per.name = personName;
            [arrM1 addObject:per];
        }
    }
    
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    
    for (Person *person in arrM1) {
        person.sectionNumber = [theCollation sectionForObject:person collationStringSelector:@selector(name)];
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    
    for (int i=0; i<highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (Person *person in arrM1) {
        [[sectionArrays objectAtIndex:person.sectionNumber] addObject:person];
    }
    
    NSMutableArray *list = [NSMutableArray array];
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(name)];
        [list addObject:sortedSection];
    }
    
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i< [list count]; i++) {
        NSArray *arr = [list objectAtIndex:i];
        if ([arr count]<=0) {
            [indexSet addIndex:i];
        }
    }
    NSMutableArray *arrTitles = [[theCollation sectionIndexTitles] mutableCopy];
    
    [list removeObjectsAtIndexes:indexSet];
    [arrTitles removeObjectsAtIndexes:indexSet];
    
    
    self.arr = list;
    self.arrTitles = arrTitles;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.arr objectAtIndex:section];
    return [arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
    }
    cell.textLabel.text = [[[self.arr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return [self.arrTitles objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.arrTitles;
}
//返回section index对应的section
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.arrTitles indexOfObject:title];
}


@end
