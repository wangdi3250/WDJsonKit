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
#import "WDStatus.h"
#import "WDStatusResult.h"
#import "WDAd.h"
#import "WDUser.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

void keyValues2object();
void keyValues2object2();
void keyValues2object3();
void keyValues2object4();
void keyValuesArray2objectArray();
void object2keyValues();

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //简单字典转模型
//        keyValues2object();
    //字典里面嵌套模型
//        keyValues2object2();
    //复杂的字典 -> 模型
//        keyValues2object3();
    //简单的字典 -> 模型（key替换，比如ID和id。多级映射，比如 oldName 和 name.oldName）
//        keyValues2object4();
    //字典数组 -> 模型数组
//        keyValuesArray2objectArray()
    //模型 -> 字典
//        object2keyValues();
    
    
    //数据库操作
    
    //插入一条记录
//    [self saveModel];
    //查询
//    [self queryModel];
    //更新
//    [self updateModel];
    //删除
//      [self deleteModel];
}

- (void)saveModel
{
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
    UIImage *image = [UIImage imageNamed:@"image_01"];
    NSData *data = UIImagePNGRepresentation(image);
    stu.data = data;
    NSDictionary *statusDict = @{
                                 @"staID" : @"234",
                           @"text" : @"是啊，今天天气确实不错！",
                           
                           @"user" : @{
                                         @"uID" : @"333",
                                   @"name" : @"Jack",
                                   @"icon" : @"lufy.png"
                                   },
                           
                           @"retweetedStatus" : @{
                                         @"staID" : @"345",
                                   @"text" : @"今天天气真不错！",
                                   
                                   @"user" : @{
                                                 @"uID" : @"222",
                                           @"name" : @"Rose",
                                           @"icon" : @"nami.png"
                                           }
                                   }
                           };
    
    // 2.将字典转为Status模型
    WDStatus *status = [WDStatus wd_modelWithJson:statusDict];
    stu.status = status;
    [WDStudent wd_insertWithModel:stu async:NO resultBlock:^(BOOL success) {
        NSLog(@"%d",success);
    }];
    
    
}

- (void)queryModel
{
    [WDStudent wd_queryWithWhere:@"sID = 20" groupBy:nil orderBy:nil limit:nil async:NO resultBlock:^(NSArray *result) {
        for(WDStudent *stu in result) {
            NSLog(@"sID= %zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@ date = %@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime,stu.date);
            NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
            for(WDBook *book in stu.books) {
                NSLog(@"bookName=%@,bookPulisher=%@,publishedTime=%@",book.name,book.publisher,book.publishedTime);
            }
            WDStatus *status = stu.status;
            NSLog(@"staID = %zd statusText = %@",status.staID,status.text);
            WDUser *user = status.user;
            NSLog(@"uID = %zd userName = %@,userIcon = %@,userAge = %d,userHeight = %@,userMoney = %@,userSex = %d,userGay = %d",user.uID,user.name,user.icon,user.age,user.height,user.money,user.sex,user.gay);
            WDStatus *retweetStatus = status.retweetedStatus;
            NSLog(@"retweetID = %zd retweetText = %@",retweetStatus.staID,retweetStatus.text);
            NSLog(@"retweetUserName = %@",retweetStatus.user.name);
        }
    }];
    
//    NSMutableDictionary *param = [NSMutableDictionary dictionary];
//    param[@"wd_id"] = @(20);
//    param[@"desciption"] = @"好孩子";
//    [WDStudent wd_queryWithParam:param groupBy:nil orderBy:nil limit:nil async:NO resultBlock:^(NSArray *result) {
//        
//        for(WDStudent *stu in result) {
//            NSLog(@"ID= %zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@ date = %@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime,stu.date);
//            NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
//            for(WDBook *book in stu.books)
//                NSLog(@"bookName=%@,bookPulisher=%@,publishedTime=%@",book.name,book.publisher,book.publishedTime);
//            
//        }
//    }];
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
    NSDictionary *statusDict = @{
                                 @"staID" : @"234",
                                 @"text" : @"是啊，今天天气确实不错！",
                                 
                                 @"user" : @{
                                         @"uID" : @"333",
                                         @"name" : @"Jack",
                                         @"icon" : @"lufy.png"
                                         },
                                 
                                 @"retweetedStatus" : @{
                                         @"staID" : @"345",
                                         @"text" : @"今天天气真糟糕！",
                                         
                                         @"user" : @{
                                                 @"uID" : @"222",
                                                 @"name" : @"二笔",
                                                 @"icon" : @"nami.png"
                                                 }
                                         }
                                 };
    
    // 2.将字典转为Status模型
    WDStatus *status = [WDStatus wd_modelWithJson:statusDict];
    stu.status = status;

    [WDStudent wd_updateWithModel:stu async:NO resultBlock:^(BOOL success) {
        [self queryModel];
    }];
}
- (void)deleteModel
{
    [self queryModel];
     [WDStudent wd_deleteWithWhere:@"sID = 20" async:NO resultBlock:^(BOOL success) {
         [self queryModel];
    }];
}


void keyValues2object()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"name" : @"Jack",
                           @"icon" : @"lufy.png",
                           @"age" : @"20",
                           @"height" : @1.55,
                           @"money" : @"100.9",
                           @"sex" : @(SexFemale),
                           @"gay" : @"1"
//                             @"gay" : @"NO"
//                             @"gay" : @"true"
                           };
    
    
    
    // 2.将字典转为WDUser模型
    WDUser *user = [WDUser wd_modelWithJson:dict];
    
    // 3.打印WDUser模型的属性
    NSLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
}


/**
 *  字典里面嵌套模型
 */
void keyValues2object2()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"text" : @"是啊，今天天气确实不错！",
                           
                           @"user" : @{
                                   @"name" : @"Jack",
                                   @"icon" : @"lufy.png"
                                   },
                           
                           @"retweetedStatus" : @{
                                   @"text" : @"今天天气真不错！",
                                   
                                   @"user" : @{
                                           @"name" : @"Rose",
                                           @"icon" : @"nami.png"
                                           }
                                   }
                           };
    
    // 2.将字典转为Status模型
    WDStatus *status = [WDStatus wd_modelWithJson:dict];
    
    // 3.打印status的属性
    NSString *text = status.text;
    NSString *name = status.user.name;
    NSString *icon = status.user.icon;
    NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    
    // 4.打印status.retweetedStatus的属性
    NSString *text2 = status.retweetedStatus.text;
    NSString *name2 = status.retweetedStatus.user.name;
    NSString *icon2 = status.retweetedStatus.user.icon;
    NSLog(@"text2=%@, name2=%@, icon2=%@", text2, name2, icon2);
}

/**
 *  复杂的字典 -> 模型 (模型的数组属性里面又装着模型)
 */
void keyValues2object3()
{
    // 1.定义一个字典
    NSDictionary *dict = @{
                           @"statuses" : @[
                                   @{
                                       @"text" : @"今天天气真不错！",
                                       
                                       @"user" : @{
                                               @"name" : @"Rose",
                                               @"icon" : @"nami.png"
                                               }
                                       },
                                   
                                   @{
                                       @"text" : @"明天去旅游了",
                                       
                                       @"user" : @{
                                               @"name" : @"Jack",
                                               @"icon" : @"lufy.png"
                                               }
                                       }
                                   
                                   ],
                           
                           @"ads" : @[
                                   @{
                                       @"image" : @"ad01.png",
                                       @"url" : @"http://www.小码哥ad01.com"
                                       },
                                   @{
                                       @"image" : @"ad02.png",
                                       @"url" : @"http://www.小码哥ad02.com"
                                       }
                                   ],
                           
                           @"totalNumber" : @"2014",
                           @"previousCursor" : @"13476589",
                           @"nextCursor" : @"13476599"
                           };
    
    // 2.将字典转为WDStatusResult模型
    WDStatusResult *result = [WDStatusResult wd_modelWithJson:dict];
    
    // 3.打印WDStatusResult模型的简单属性
    NSLog(@"totalNumber=%@, previousCursor=%lld, nextCursor=%lld", result.totalNumber, result.previousCursor, result.nextCursor);
    
    // 4.打印statuses数组中的模型属性
    for (WDStatus *status in result.statuses) {
        NSString *text = status.text;
        NSString *name = status.user.name;
        NSString *icon = status.user.icon;
        NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
    }
    
    // 5.打印ads数组中的模型属性
    for (WDAd *ad in result.ads) {
        NSLog(@"image=%@, url=%@", ad.image, ad.url);
    }
}

/**
 * 简单的字典 -> 模型（key替换，比如ID和id。多级映射，比如 oldName 和 name.oldName）
 */
void keyValues2object4()
{
    //    // 1.定义一个字典
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
                                           @"name" : @"小书包",
                                           @"price" : @100.7
                                           }
                                   }
                           };
    // 2.将字典转为WDStudent模型
        WDStudent *stu = [WDStudent wd_modelWithJson:dict];
     //3.打印WDStudent模型的属性
        NSLog(@"sID=%zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime);
        NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
}

/**
 *  字典数组 -> 模型数组
 */
void keyValuesArray2objectArray()
{
    // 1.定义一个字典数组
    NSArray *dictArray = @[
                           @{
                               @"name" : @"Jack",
                               @"icon" : @"lufy.png",
                               },
                           
                           @{
                               @"name" : @"Rose",
                               @"icon" : @"nami.png",
                               }
                           ];
    
    // 2.将字典数组转为WDUser模型数组
    NSArray *userArray = [WDUser wd_modelArrayWithJsonArray:dictArray];
    
    // 3.打印userArray数组中的WDUser模型属性
    for (WDUser *user in userArray) {
        NSLog(@"name=%@, icon=%@", user.name, user.icon);
    }
}

/**
 *  模型 -> 字典
 */
void object2keyValues()
{
    // 1.新建模型
    WDUser *user = [[WDUser alloc] init];
    user.name = @"Jack";
    user.icon = @"lufy.png";
    
    WDStatus *status = [[WDStatus alloc] init];
    status.user = user;
    status.text = @"今天的心情不错！";
    
    // 2.将模型转为字典
    NSDictionary *statusDict = [status wd_jsonWithModel];
    NSLog(@"%@", statusDict);
    
    //    NSLog(@"%@", [status WD_keyValuesWithKeys:@[@"text"]]);
    
    // 3.新建多级映射的模型
    WDStudent *stu = [[WDStudent alloc] init];
    stu.sID = 123;
    stu.oldName = @"rose";
    stu.nowName = @"jack";
    stu.desc = @"handsome";
    stu.nameChangedTime = @"2018-09-08";
    stu.books = @[@"Good book", @"Red book"];
    
    WDBag *bag = [[WDBag alloc] init];
    bag.name = @"小书包";
    bag.price = 205;
    stu.bag = bag;
    
    NSDictionary *stuDict = [stu wd_jsonWithModel];
    NSLog(@"%@", stuDict);
    
}

@end
