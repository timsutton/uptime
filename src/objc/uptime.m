#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSTimeInterval uptime = [[NSProcessInfo processInfo] systemUptime];
        int uptimeInSeconds = (int)uptime;
        printf("%i\n", uptimeInSeconds);
    }
    return 0;
}
