#import "AudiocutterPlugin.h"
#import <audiocutter/audiocutter-Swift.h>

@implementation AudiocutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAudiocutterPlugin registerWithRegistrar:registrar];
}
@end
