# 说明
IPSelector是应用在APP里，启动时做IP选择，便于测试的的API。
# CocoaPod 支持
pod 'HMXIpSelector', '~> 1.0.0'
# 使用前提
对于获取的IP列表格式的限制，必须为
```objective-c
//product、test分别为生产和测试环境的IP，serversOne里有3个domain可供选择。
NSDictionary *defaultIpList = @{@"product":@{@"serverOne":@[@"10.10.10.1:8080",@"10.10.10.2:8080",@"10.10.10.3:8080"],@"serverTwo":@[@"10.10.10.4:8080"]},@"test":@{@"serverOne":@[@"10.10.10.1:8080",@"10.10.10.2:8080",@"10.10.10.3:8080"],@"serverTwo":@[@"10.10.10.4:8080"]}};
```
# 使用范例
```objective-c
//只有获取到IP后才能允许加载页面，所以此处采用同步获取数据
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:@"[此处为获取IP列表的URLString]"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    NSData *ipData =[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//viewController用作推出IP列表页面
    [IPSelector defaultSelector].viewController = self.window.rootViewController;
//ipData可能为nil
    [IPSelector defaultSelector].ipData = ipData;
//ipData为nil时使用默认IPdefaultIpList
    [IPSelector defaultSelector].defaultIpList = [NSMutableDictionary dictionaryWithDictionary:defaultIpList];
//是否是测试版本，如果是，则弹出IP选择页面
    [IPSelector defaultSelector].isTest = YES;
    [IPSelector defaultSelector].delegate = self;
//服务器键值，根据键值，解析ipData数据
    [IPSelector defaultSelector].ipKeys = @[@"serverOne",@"serverTwo"];
//服务器中文名字
    [IPSelector defaultSelector].ipNames = @[@"服务器1",@"服务器2"];
//解析数据
    [[IPSelector defaultSelector] parseIpData];
```
```objective-c
//IP选择后，这样使用选择的IP
    NSString *ipDomain = [[IPSelector defaultSelector] getIpForKey:@"serverOne"];
	NSString *urlString = [NSString stringWithFormat:@"http://%@/***/central.do",ipDomain];
//当urlString访问不通时
//注意getNextIpForKey方法只是迭代获取下个IP，查看是否有值，不要多次调用，如果有的话则再次调用getIpForKey方法会自动获取下一个可用的IP，否则说明已经遍历了所有的IP
if([[IPSelector defaultSelector]getNextIpForKey:@"serverOne"])
    {
        NSString *nextIpDomain = [[IPSelector defaultSelector] getIpForKey:@"serverOne"];
        NSString *nextUrlString = [NSString stringWithFormat:@"http://%@/***/central.do",nextIpDomain];
    }
```
