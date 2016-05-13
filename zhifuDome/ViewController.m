//
//  ViewController.m
//  zhifuDome
//
//  Created by mac on 16/4/23.
//  Copyright © 2016年 lzc. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
- (IBAction)pra:(id)sender {
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088801142678498";//合作商户账号
    NSString *seller = @"lisa@newv.com.cn";//支付宝收款账号
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKADO4HcskWfaWCSLSdCqPMWymC2m3paALX6jVjpz/eIFajO/hbOec1IZB8yLImClKTyke9kGy2IwVSt1QNugxx/u6lUEoE6LeO2LKR37YnopdgKxXVITX5Ymn0yJdI3WWFiqfcFXzAHq3D5Il9zfTVRyOTHfRTC05EML7F1hV/1AgMBAAECgYBeUKlxqQk3OngdYOvWeVcmOae+C8RnAMfse6t23hIkAAVsQ93GyZtHocTKEoPn5Z0CAKx+I05Vr4btB61H4YrLga89mbXjP+YoYejNRVoZBjEpkf7NgMh7ScQIhx3hHk2IuCO6syz/cR5zNWpK47gMSWtS3/xoWjX9aicKcsTNgQJBANQd3qZZeo1XTi4qugp8AAvCwsy4IGM1LztahKIll+XMTLHxF6e5WTEQTuRe6fQzfbP7emNX3aAwqLRhgez+hmECQQDBHdOGsuqGQkes1VO9C9zEOegjEgv+Dzxq3Wj8AeVzO4idUJ2Gl6IV4EWflev9kZGX6CXFjJ3RngM6dsoejpoVAkEAj36Rc7mOhXVtZx/ycUtHgK1FuNZK2rJM/HsUxNhntMaLj8kIdqeVpfJhXG61GEWJISvbtL7pKAgi6LwZ9+iLoQJAWO5HTqxt284B+9FxcolX7PVNtXjGFQUnKX80rXiiFWLBEtDg+e4yMijJZyg/ONIkXfQGEOckdjdx/SZfBZtd0QJAPL0+YBO5Bvbb4/VRIeoww+4pAd46f9Ews0a0gYjOrTL+tNomvVet92HgJJQIEIoLbqh4NTDJDFgC8rmh7UBeSg==";//私钥,
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.productName =@"82年的茅台"; //商品标题
    order.productDescription = @"口感香醇"; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",0.01]; //商品价格
    order.notifyURL =  @"http://www.xxx.com"; //回调URL,支付宝把支付信息回调给服务器的
    //===========以下信息尽量不改
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"zhifuDome";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
        
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
