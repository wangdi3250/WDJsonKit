WDJsonKit
===
# <a id="Getting_Started"></a> Getting Started【开始使用】

## <a id="Features"></a> Features【能做什么】
- WDJsonKit 是一套字典和模型之间互相转换超轻量级框架
- WDJsonKit 还是一套实现模型与数据库之间ORM映射的框架
* `JSON` --> `Model`
* `JSONString` --> `Model`
* `Model` --> `JSON`
* `JSON Array` --> `Model Array`
* `JSONString` --> `Model Array`
* `Model Array`--> `JSON Array`
* `Model` ORM      `数据库表`

## <a id="dependent"></a> 框架依赖
框架依赖于FMDB框架，所以需导入sqlite3动态库。框架中中已经有FMDB框架，如果你的项目中已经存在FMDB框架，请删除一个。


# <a id="firstFunction"></a> 第一大功能【JSON-->Model || Model-->JSON】

### <a id="JSON_Model"></a> The most simple JSON -> Model【最简单的字典转模型】
```objc
typedef enum {
    SexMale,
    SexFemale
} Sex;

@interface User : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;
@property (assign, nonatomic) unsigned int age;
@property (copy, nonatomic) NSString *height;
@property (strong, nonatomic) NSNumber *money;
@property (assign, nonatomic) Sex sex;
@property (assign, nonatomic, getter=isGay) BOOL gay;
@end

/***********************************************/

NSDictionary *dict = @{
    @"name" : @"Jack",
    @"icon" : @"lufy.png",
    @"age" : @20,
    @"height" : @"1.55",
    @"money" : @100.9,
    @"sex" : @(SexFemale),
    @"gay" : @"true"
//   @"gay" : @"1"
//   @"gay" : @"NO"
};

// JSON -> User
User *user = [User wd_modelWithJson:dict];

NSLog(@"name=%@, icon=%@, age=%zd, height=%@, money=%@, sex=%d, gay=%d", user.name, user.icon, user.age, user.height, user.money, user.sex, user.gay);
// name=Jack, icon=lufy.png, age=20, height=1.550000, money=100.9, sex=1
```

### <a id="JSONString_Model"></a> JSONString -> Model【JSON字符串转模型】

```objc
// 1.Define a JSONString
NSString *jsonString = @"{\"name\":\"Jack\", \"icon\":\"lufy.png\", \"age\":20}";

// 2.JSONString -> User
User *user = [User wd_modelWithJson:jsonString];

// 3.Print user's properties
NSLog(@"name=%@, icon=%@, age=%d", user.name, user.icon, user.age);
// name=Jack, icon=lufy.png, age=20
```

### <a id="Model_contains_model"></a> Model contains model【模型中嵌套模型】

```objc
@interface Status : NSObject
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Status *retweetedStatus;
@end

/***********************************************/

NSDictionary *dict = @{
    @"text" : @"Agree!Nice weather!",
    @"user" : @{
        @"name" : @"Jack",
        @"icon" : @"lufy.png"
    },
    @"retweetedStatus" : @{
        @"text" : @"Nice weather!",
        @"user" : @{
            @"name" : @"Rose",
            @"icon" : @"nami.png"
        }
    }
};

// JSON -> Status
Status *status = [Status wd_modelWithJson:dict];

NSString *text = status.text;
NSString *name = status.user.name;
NSString *icon = status.user.icon;
NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
// text=Agree!Nice weather!, name=Jack, icon=lufy.png

NSString *text2 = status.retweetedStatus.text;
NSString *name2 = status.retweetedStatus.user.name;
NSString *icon2 = status.retweetedStatus.user.icon;
NSLog(@"text2=%@, name2=%@, icon2=%@", text2, name2, icon2);
// text2=Nice weather!, name2=Rose, icon2=nami.png
```

### <a id="Model_contains_model_array"></a> Model contains model-array【模型中有个数组属性，数组里面又要装着其他模型】

```objc
@interface Ad : NSObject
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *url;
@end

@interface StatusResult : NSObject
/** Contatins status model */
@property (strong, nonatomic) NSMutableArray *statuses;
/** Contatins ad model */
@property (strong, nonatomic) NSArray *ads;
@property (strong, nonatomic) NSNumber *totalNumber;
@end

/***********************************************/

// 实现这个方法,返回数组里面所装的模型对象的类或者类的字符串
+ (NSDictionary *)wd_classInArray
 {
   return @{
               @"statuses" : @"Status",
               // @"statuses" : [Status class],
               @"ads" : @"Ad"
               // @"ads" : [Ad class]
           };
 }

NSDictionary *dict = @{
    @"statuses" : @[
                      @{
                          @"text" : @"Nice weather!",
                          @"user" : @{
                              @"name" : @"Rose",
                              @"icon" : @"nami.png"
                          }
                      },
                      @{
                          @"text" : @"Go camping tomorrow!",
                          @"user" : @{
                              @"name" : @"Jack",
                              @"icon" : @"lufy.png"
                          }
                      }
                  ],
    @"ads" : @[
                 @{
                     @"image" : @"ad01.png",
                     @"url" : @"http://www.ad01.com"
                 },
                 @{
                     @"image" : @"ad02.png",
                     @"url" : @"http://www.ad02.com"
                 }
             ],
    @"totalNumber" : @"2014"
};

// JSON -> StatusResult
StatusResult *result = [StatusResult wd_modelWithJson:dict];

NSLog(@"totalNumber=%@", result.totalNumber);
// totalNumber=2014

// Printing
for (Status *status in result.statuses) {
    NSString *text = status.text;
    NSString *name = status.user.name;
    NSString *icon = status.user.icon;
    NSLog(@"text=%@, name=%@, icon=%@", text, name, icon);
}
// text=Nice weather!, name=Rose, icon=nami.png
// text=Go camping tomorrow!, name=Jack, icon=lufy.png

// Printing
for (Ad *ad in result.ads) {
    NSLog(@"image=%@, url=%@", ad.image, ad.url);
}
// image=ad01.png, url=http://www.ad01.com
// image=ad02.png, url=http://www.ad02.com
```

### <a id="Model_name_JSON_key_mapping"></a> Model name - JSON key mapping【模型中的属性名和字典中的key不相同(或者需要多级映射)】

```objc
@interface Bag : NSObject
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) double price;
@end

@interface Student : NSObject
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *nowName;
@property (copy, nonatomic) NSString *oldName;
@property (copy, nonatomic) NSString *nameChangedTime;
@property (strong, nonatomic) Bag *bag;
@end

/***********************************************/
实现这个方法并返回映射关系的字典
+ (NSDictionary *)wd_replaceKeysFromOriginKeys
 {
 return @{
               @"ID" : @"id",
               @"desc" : @"desciption",
               @"oldName" : @"name.oldName",
               @"nowName" : @"name.newName",
               @"nameChangedTime" : @"name.info[1].nameChangedTime",
               @"bag" : @"other.bag"
           };
 }

NSDictionary *dict = @{
    @"id" : @"20",
    @"desciption" : @"kids",
    @"name" : @{
        @"newName" : @"lufy",
        @"oldName" : @"kitty",
        @"info" : @[
        		 @"test-data",
        		 @{
            	             @"nameChangedTime" : @"2013-08"
                         }
                  ]
    },
    @"other" : @{
        @"bag" : @{
            @"name" : @"a red bag",
            @"price" : @100.7
        }
    }
};

// JSON -> Student
Student *stu = [Student wd_modelWithJson:dict];

// Printing
NSLog(@"ID=%@, desc=%@, oldName=%@, nowName=%@, nameChangedTime=%@",
      stu.ID, stu.desc, stu.oldName, stu.nowName, stu.nameChangedTime);
// ID=20, desc=kids, oldName=kitty, nowName=lufy, nameChangedTime=2013-08
NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
// bagName=a red bag, bagPrice=100.700000
```

### <a id="JSON_array_model_array"></a> JSON array -> model array【将一个字典数组转成模型数组】
```objc
NSArray *dictArray = @[
                         @{
                             @"name" : @"Jack",
                             @"icon" : @"lufy.png"
                         },
                         @{
                             @"name" : @"Rose",
                             @"icon" : @"nami.png"
                         }
                     ];

// JSON array -> User array
NSArray *userArray = [User wd_modelArrayWithJsonArray:dictArray];

// Printing
for (User *user in userArray) {
    NSLog(@"name=%@, icon=%@", user.name, user.icon);
}
// name=Jack, icon=lufy.png
// name=Rose, icon=nami.png
```


### <a id="Model_JSON"></a> Model -> JSON【将一个模型转成字典】
```objc
// New model
User *user = [[User alloc] init];
user.name = @"Jack";
user.icon = @"lufy.png";

Status *status = [[Status alloc] init];
status.user = user;
status.text = @"Nice mood!";

// Status -> JSON
NSDictionary *statusDict = [status wd_jsonWithModel];
NSLog(@"%@", statusDict);
/*
 {
 text = "Nice mood!";
 user =     {
 icon = "lufy.png";
 name = Jack;
 };
 }
 */
 
 Student *stu = [[Student alloc] init];
stu.ID = @"123";
stu.oldName = @"rose";
stu.nowName = @"jack";
stu.desc = @"handsome";
stu.nameChangedTime = @"2018-09-08";

Bag *bag = [[Bag alloc] init];
bag.name = @"a red bag";
bag.price = 205;
stu.bag = bag;

NSDictionary *stuDict = [stu wd_jsonWithModel];
NSLog(@"%@", stuDict);
/*
{
    ID = 123;
    bag =     {
        name = "\U5c0f\U4e66\U5305";
        price = 205;
    };
    desc = handsome;
    nameChangedTime = "2018-09-08";
    nowName = jack;
    oldName = rose;
}
 */
```

### <a id="Model_array_JSON_array"></a> Model array -> JSON array【将一个模型数组转成字典数组】

```objc
// New model array
User *user1 = [[User alloc] init];
user1.name = @"Jack";
user1.icon = @"lufy.png";

User *user2 = [[User alloc] init];
user2.name = @"Rose";
user2.icon = @"nami.png";

NSArray *userArray = @[user1, user2];

// Model array -> JSON array
NSArray *dictArray = [User wd_jsonArrayWithModelArray:userArray];
NSLog(@"%@", dictArray);
/*
 (
 {
 icon = "lufy.png";
 name = Jack;
 },
 {
 icon = "nami.png";
 name = Rose;
 }
 )
 */
```

### <a id="NSString_NSDate"></a> NSString -> NSDate, nil -> @""【过滤字典的值（比如字符串日期处理为NSDate、字符串nil处理为@""）】
```objc
// Book
#import "WDJsonKit.h"

@implementation Book
+ (id)wd_newValueFromOldValue:(id)oldValue propertyInfo:(WDPropertyInfo *)propertyInfo
{
    if ([propertyInfo.name isEqualToString:@"publisher"]) {
        if (oldValue == nil) return @"";
    } else if (propertyInfo.type.typeClass == [NSDate class]) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd";
        return [fmt dateFromString:oldValue];
    }

    return oldValue;
}
@end

// NSDictionary
NSDictionary *dict = @{
                       @"name" : @"5分钟突破iOS开发",
                       @"publishedTime" : @"2011-09-10"
                       };
// NSDictionary -> Book
Book *book = [Book wd_modelWithJson:dict];

// printing
NSLog(@"name=%@, publisher=%@, publishedTime=%@", book.name, book.publisher, book.publishedTime);

### <a id="Coding"></a> Coding

```objc
#import "WDJsonKit.h"

@implementation Bag
// NSCoding Implementation
   WDCoding
@end

/***********************************************/

// 实现这个方法，返回归档属性黑名单或者白名单
+ (NSArray *)wd_encodingPropertyBlackList
{
  return @[@"name"]
}
// Create model
Bag *bag = [[Bag alloc] init];
bag.name = @"Red bag";
bag.price = 200.8;

NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/bag.data"];
// Encoding
[NSKeyedArchiver archiveRootObject:bag toFile:file];

// Decoding
Bag *decodedBag = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
NSLog(@"name=%@, price=%f", decodedBag.name, decodedBag.price);
// name=(null), price=200.800000
```
# <a id="json_more"></a> 更多用法请参考NSObject+WDJsonKit.h


# <a id="secondFunction"></a> 第二大功能【Model的本地持久化】

####Model本地持久化使用须知:
* `确保Model中实现wd_sqlRowIdentifyPropertyName方法返回Model的主键属性的名字，否者程序会走断言进而Crash，这个字段的通常是服务器返回的ID`
* `确保这个值是 > 0的，否者将操作失败`
* `目前这个字段的类型只支持 NSNumber、NSString 和 基本数据类型`
* `对于数据库中的表名，如果实现+ (NSString *)wd_sqlTableName方法返回表明，会以这个表名为主，否者表名即为类的名字`
* `跟上面一样，如果实现wd_sqlReplaceKeysFromOriginKeys方法返回模型属性与数据库表的字段的映射关系，如果不实现，数据库默认表的字段名字即为模型的属性名`
* `增删改查的接口中有一个async的Bool值，注意，如果传YES，那么讲开启线程进行操作，并且回调的操作也是在子线程中进行`

# <a id="auto_add_column"></a> 模型字段检查，全自动增加字段

有时候你可能有这样的需求，开发到一定阶段或者版本，需要增加模型字段。WDJsonKit已经完全为您考虑了这种情况，当你为模型增加一个字段的时候，数据库表会自动增加一个字段

# <a id="insert"></a> 插入一条记录

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
    [WDStudent wd_insertWithModel:stu async:NO resultBlock:^(BOOL success) {
        NSLog(@"%d",success);
    }];
    
    
    
# <a id="update"></a> 修改一条记录

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
    
    
# <a id="delete"></a> 条件删除
####注意：当条件所对应的类型为字符串的时候，一定要加 ''，如：name = '好人'

     [WDStudent wd_deleteWithWhere:@"sID = 20" async:NO resultBlock:^(BOOL success) {
         
         NSLog(@"%d",success);
    }];

# <a id="query"></a> 条件查询
####注意：当条件所对应的类型为字符串的时候，一定要加 ''，如：name = '好人'

    [WDStudent wd_queryWithWhere:@"sID = 20 AND desciption = '好孩子'" groupBy:nil orderBy:nil limit:nil async:NO resultBlock:^(NSArray *result) {
        for(WDStudent *stu in result) {
            NSLog(@"ID= %zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@ date = %@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime,stu.date);
            NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
            for(WDBook *book in stu.books)
                NSLog(@"bookName=%@,bookPulisher=%@,publishedTime=%@",book.name,book.publisher,book.publishedTime);
            
        }
    }];
    
    也可以使用这种方式
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
    当然，也可以通过模型的主键主键来查询：
    [WDStudent wd_queryWithRowIdentify:@(20) async:NO resultBlock:^(NSArray *result) {
        for(WDStudent *stu in result) {
            NSLog(@"ID= %zd, desc=%@, otherName=%@, oldName=%@, nowName=%@, nameChangedTime=%@", stu.sID, stu.desc, stu.otherName, stu.oldName, stu.nowName, stu.nameChangedTime);
            NSLog(@"bagName=%@, bagPrice=%f", stu.bag.name, stu.bag.price);
            for(WDBook *book in stu.books)
                NSLog(@"bookName=%@,bookPulisher=%@,publishedTime=%@",book.name,book.publisher,book.publishedTime);
            
        }
    }];
# <a id="sql_more"></a> 更多用法请参考NSObject+WDJsonKit.h