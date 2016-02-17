WDJsonKit
===
# <a id="Getting_Started"></a> Getting Started【开始使用】

## <a id="Features"></a> Features【能做什么】
- WDJsonKit是一套字典和模型之间互相转换,模型与数据库之间实现ORM映射的超轻量级框架
* `JSON` --> `Model`
* `JSONString` --> `Model`
* `Model` --> `JSON`
* `JSON Array` --> `Model Array`
* `JSONString` --> `Model Array`
* `Model Array`--> `JSON Array`

## <a id="appedent"></a> 框架依赖
框架依赖于FMDB框架，所以需导入sqlite3动态库。框架中中已经有FMDB框架，如果你的项目中已经存在FMDB框架，请删除一个。


# <a id="Examples"></a> Examples【示例】

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
#import "MJExtension.h"

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
