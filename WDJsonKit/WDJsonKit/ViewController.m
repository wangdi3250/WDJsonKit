//
//  ViewController.m
//  WDJsonKit
//
//  Created by 王迪 on 16/2/9.
//  Copyright © 2016年 wd. All rights reserved.
//

#import "ViewController.h"
#import "WDAd.h"
#import "WDStudent.h"
#import "WDJsonKit.h"
#import "WDBag.h"
#import "WDBook.h"
#import "WDDog.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self saveModel];
//    [self queryModel];
//    [self queryModelWithID];
//    [self deleteModel];
//    [self updateModel];
    WDDog *dog = [[WDDog alloc] init];
    dog.nickName = @"旺财";
    dog.runSpeed = 250.1;
    dog.salePrice = 123.4;
    NSString *fileName = @"archive.data";
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:dog toFile:path];
    WDDog *dog1 = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    NSLog(@"nickName = %@ saleProce = %f runSpeed = %f",dog1.nickName,dog1.salePrice,dog1.runSpeed);
}

- (void)saveModel
{
    //    // 1.定义一个字典
    /**
     *  @property (copy, nonatomic) NSString *name;
     @property (copy, nonatomic) NSString *publisher;
     @property (strong, nonatomic) NSString *publishedTime;
     @property (strong, nonatomic) WDBox *box;
     */
    NSDictionary *dict = @{
                           @"id" : @"20",
                           @"desciption" : @"好孩子",
                           @"name" : @{
                                   @"newName" : @"lufy",
                                   @"oldName" : @"kitty",
                                   @"info" : @[
                                           @"test-data",
                                           @{@"nameChangedTime" : @"2013-08-07"}
                                           ]
                                   },
                           @"other" : @{
                                   @"bag" : @{
                                           @"gID" : @"100",
                                           @"name" : @"小书包",
                                           @"price" : @100.7
                                           }
                                   },
                           @"books" : @[
                                       @{
                                           @"bID" : @"123",
                                         @"name" : @"生长",
                                         @"publisher" : @"北京人民日报",
                                         @"publishedTime" : @"2014-07-04"
                                         },
                                       @{
                                           @"bID" : @"456",
                                         @"name" : @"生长",
                                         @"publisher" : @"北京人民日报",
                                         @"publishedTime" : @"2014-07-04"
                                         }
                               ]
                           };
    WDStudent *stu = [WDStudent wd_modelWithJson:dict];
    stu.date = [NSDate date];
    NSLog(@"ID=%zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime);
    NSLog(@"bagID = %zd ,bagName=%@, bagPrice=%f", stu.bag.gID ,stu.bag.name, stu.bag.price);
    for(WDBook *book in stu.books)
        NSLog(@"bookID = %zd, bookName=%@,bookPulisher=%@,publishedTime=%@",book.bID,book.name,book.publisher,book.publishedTime);
    [stu wd_save];
    
    
}

- (void)queryModel
{
//    NSArray *students = [WDStudent wd_query];
//    for(WDStudent *stu in students) {
//        NSLog(@"ID= %zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@ date = %@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime,stu.date);
//        NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
//        for(WDBook *book in stu.books)
//            NSLog(@"bookName=%@,bookPulisher=%@,publishedTime=%@",book.name,book.publisher,book.publishedTime);
//
//    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"wd_id"] = @(20);
    param[@"desciption"] = @"好孩子";
    [WDStudent wd_queryWithParam:param groupBy:nil orderBy:nil limit:nil async:NO resultBlock:^(NSArray *result) {
        
        for(WDStudent *stu in result) {
            NSLog(@"ID= %zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@ date = %@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime,stu.date);
            NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
            for(WDBook *book in stu.books)
                NSLog(@"bookName=%@,bookPulisher=%@,publishedTime=%@",book.name,book.publisher,book.publishedTime);
            
        }
    }];
}

- (void)queryModelWithID
{
    [WDStudent wd_queryWithRowIdentify:@(20) async:NO resultBlock:^(NSArray *result) {
        
        
//        for(WDStudent *stu in result) {
//            NSLog(@"ID= %zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime);
//            NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
//            for(WDBook *book in stu.books)
//                NSLog(@"bookName=%@,bookPulisher=%@,publishedTime=%@",book.name,book.publisher,book.publishedTime);
//            
//        }
    }];
}

- (void)updateModel
{
    NSDictionary *dict = @{
                           @"id" : @"20",
                           @"desciption" : @"坏孩子",
                           @"name" : @{
                                   @"newName" : @"lufy",
                                   @"oldName" : @"kitty",
                                   @"info" : @[
                                           @"test-data",
                                           @{@"nameChangedTime" : @"2013-08-07"}
                                           ]
                                   },
                           @"other" : @{
                                   @"bag" : @{
                                            @"gID" : @"100",
                                           @"name" : @"傻逼",
                                           @"price" : @2.7
                                           }
                                   },
                           @"books" : @[
                                   @{
                                       @"bID" : @"123",
                                       @"name" : @"爱你",
                                       @"publisher" : @"北京人民日报",
                                       @"publishedTime" : @"2014-07-04"
                                       },
                                   @{
                                       @"bID" : @"456",
                                       @"name" : @"爱你",
                                       @"publisher" : @"北京人民日报",
                                       @"publishedTime" : @"2014-07-04"
                                       }
                                   ]
                           };
    WDStudent *stu = [WDStudent wd_modelWithJson:dict];
    [WDStudent wd_updateWithModel:stu async:NO resultBlock:^(BOOL success) {
    }];
//    [WDStudent wd_updateWithModel:stu where:@"id = 1" async:NO resultBlock:^(BOOL success) {
//        NSLog(@"%d",success);
//    }];
}
- (void)deleteModel
{
     [WDStudent wd_deleteWithWhere:@"id = 3" async:NO resultBlock:^(BOOL success) {
         
         NSLog(@"%d",success);
    }];
}

@end
