//
//  DirectionsViewController.m
//  HandOnEastWind
//
//  Created by 杨超 on 14-3-22.
//  Copyright (c) 2014年 lidi. All rights reserved.
//

#import "DirectionsViewController.h"

@interface DirectionsViewController ()

@end

@implementation DirectionsViewController

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
    self.label_Title.text  = self.key;
    
    if ([self.key isEqualToString:@"关于"]) {
        self.textView_Content.text = @"湖北东风报业传媒有限公司，是东风汽车公司全资子公司.\n\n旗下有: \n 《东风汽车报》     （CN42-063）、\n 《汽车科技》         （CN42-1323/U）、\n 《装备维修技术》  （CN42-1335/U）、\n 《汽车之旅》         （CN42-1323/U）、\n 《东风传媒网》     （www.dfcm.cc）、\n 《百姓车行网》     （www.china-4s.cn）\n\n是集报纸、杂志、网络（电子报刊）于一体较具规模和影响力的综合性文化传媒公司。";
    }
    else
    {
        self.textView_Content.text = @"请您仔细阅读以下条款，如果您对本声明的任何条款表示异议，可以选择不使用掌上东风。用户使用掌上东风的行为将被视为对本声明全部内容的认可。\n1.掌上东风不对用户发表的内容或上传的文件进行验证，爱问不对内容的真实、完整、准确及合法性进行任何保证。\n2.用户在掌上东风发布的内容或文件仅表明其个人的立场和观点，并不代表掌上东风的立场或观点。发表者需自行对所发表内容负责，因所发表内容引发的一切纠纷，由该内容的发表者承担全部法律责任。掌上东风不承担任何法律及连带责任。\n3.对于使用掌上东风而引致的任何意外、疏忽、合约毁坏、诽谤、版权或知识产权侵犯及其所造成的损失（包括因下载而感染电脑病毒），掌上东风概不负责，亦不承担任何法律责任。\n4.尊重并保护所有使用用户的个人隐私权，用户注册的用户名、电子邮件等个人资料，非经用户亲自许可或根据相关法律的强制性规定，掌上东风不会主动地泄露给第三方。";
    }
    
}


-(IBAction)Directions_Btn:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
