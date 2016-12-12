//
//  ViewController.m
//  RunLoop
//
//  Created by Yuhui Huang on 12/6/16.
//  Copyright © 2016 Yuhui Huang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

///-----------------------------------------------------------------------------
/// NSRunLoop简介 http://www.jianshu.com/p/8cd7a5dffc09
///-----------------------------------------------------------------------------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 1. 获取当前线程对应的RunLoop对象
    NSRunLoop *curRunLoop = [NSRunLoop currentRunLoop];
    NSLog(@"%p", curRunLoop);
    // 2. 获取主线程对应的RunLoop对象
    NSRunLoop *mainRunLoop = [NSRunLoop mainRunLoop];
    NSLog(@"%p", mainRunLoop);
    
    /* Core Foundation */
    // 1. 获得当前线程的RunLoop对象
    CFRunLoopRef cfCurRunLoop = CFRunLoopGetCurrent();
    NSLog(@"%p", cfCurRunLoop);
    // 2. 获得主线程的RunLoop对象
    CFRunLoopRef cfMainRunLoop = CFRunLoopGetMain();
    NSLog(@"%p", cfMainRunLoop);
    
    // 从这里可以看出这两种运行循环是完全不同的对象
    // NSRunLoop --> CFRunLoopRef
    NSLog(@"%p----%p", cfMainRunLoop, mainRunLoop.getCFRunLoop);
    
    // 开启子线程，执行task方法
    [NSThread detachNewThreadSelector:@selector(task) toTarget:self withObject:nil];
}

- (void)task {
    
    /* 子线程和RunLoop
     1. 每一个子线程，都对应一个自己的RunLoop
     2. 主线程的RunLoop在程序运行的时候就已经创建了，而子线程的RunLoop则需要手动开启
     3. [NSRunLoop currentRunLoop]，此方法会开启一个新的RunLoop
     4. RunLoop需要执行run方法，来开启，但如果RunLoop中没有任何任务，就会关闭
     */
    
    // 1. 当前RunLoop
    NSLog(@"%p----%p", [NSRunLoop currentRunLoop], [NSRunLoop mainRunLoop]);
    
    // 2. 开启一个新的RunLoop
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"task----%@", [NSThread currentThread]);
}

/** 监听RunLoop的状态 */
- (void)addRunLoopObserver {
    /**
     1. 创建监听者
     CFAllocatorRef allocator 分配存储空间
     CFOptionFlags activities 要监听哪个状态，kCFRunLoopAllActivities监听所有状态
     Boolean repeats 是否持续监听RunLoop的状态
     CFIndex order 优先级，默认为0
     Block activity RunLoop当前的状态
     */
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        
        /**
         kCFRunLoopEntry = (1UL << 0),          进入工作
         kCFRunLoopBeforeTimers = (1UL << 1),   即将处理Timers事件
         kCFRunLoopBeforeSources = (1UL << 2),  即将处理Source事件
         kCFRunLoopBeforeWaiting = (1UL << 5),  即将休眠
         kCFRunLoopAfterWaiting = (1UL << 6),   被唤醒
         kCFRunLoopExit = (1UL << 7),           退出RunLoop
         kCFRunLoopAllActivities = 0x0FFFFFFFU  监听所有事件
         */
        // 当activity处于什么状态的时候，调用一次
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"进入");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将处理Timer事件");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理Source事件");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将休眠");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"被唤醒");
                break;
            case kCFRunLoopExit:
                NSLog(@"退出RunLoop");
                break;
            default:
                break;
        }
    });
    
    /**
     2. 给对应的RunLoop添加一个监听者，并确定监听的是哪种运行模式
     CFRunLoopRef rl  要添加监听者的RunLoop
     CFRunLoopObserverRef observer,  要添加的监听者
     CFStringRef mode  RunLoop的运行模式
     */
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
}

@end
