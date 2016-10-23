//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <AVFoundation/AVFoundation.h>

#import "GoogleSpeechController.h"


#define SAMPLE_RATE 16000.0f

@interface GoogleSpeechController () <AudioControllerDelegate>
@property (nonatomic, strong) NSMutableData *audioData;
@end

@implementation GoogleSpeechController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AudioController sharedInstance].delegate = self;
}

- (IBAction)recordAudio:(id)sender {
    if ([AudioController sharedInstance].delegate != self){
        [AudioController sharedInstance].delegate = self;
    }
    
    NSLog(@"STARTING GOOGLE AUDIO");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError* error;
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    if (error != nil) {
        NSLog(@"Error - %@",[error localizedDescription]);
    }
    _audioData = [[NSMutableData alloc] init];
    [[AudioController sharedInstance] prepareWithSampleRate:SAMPLE_RATE];
    [[SpeechRecognitionService sharedInstance] setSampleRate:SAMPLE_RATE];
    OSStatus osStatus =  [[AudioController sharedInstance] start];
    NSError *osError = [NSError errorWithDomain:NSOSStatusErrorDomain code:osStatus userInfo:nil];
//    if (osError != nil){
//        NSLog(@"ERROR - %ld",(long)[osError code]);
//    }
}

- (IBAction)stopAudio:(id)sender {
    [[AudioController sharedInstance] stop];
    [[SpeechRecognitionService sharedInstance] stopStreaming];
}

- (void) processSampleData:(NSData *)data
{
    NSLog(@"Processing Sample %lu", (unsigned long)[data length]);
    [self.audioData appendData:data];
    NSInteger frameCount = [data length] / 2;
    int16_t *samples = (int16_t *) [data bytes];
    int64_t sum = 0;
    for (int i = 0; i < frameCount; i++) {
        sum += abs(samples[i]);
    }
    NSLog(@"audio %d %d", (int) frameCount, (int) (sum * 1.0 / frameCount));
    
    // We recommend sending samples in 100ms chunks
    int chunk_size = 0.1 /* seconds/chunk */ * SAMPLE_RATE * 2 /* bytes/sample */ ; /* bytes/chunk */
    
    if ([self.audioData length] > chunk_size) {
        NSLog(@"SENDING");
        [[SpeechRecognitionService sharedInstance] streamAudioData:self.audioData
                                                    withCompletion:^(StreamingRecognizeResponse *response, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"ERROR: %@", error);
                                                            [self stopAudio:nil];
                                                            [self.delegate errorGoogleRecieved: [error localizedDescription]];
                                                        } else if (response) {
                                                            BOOL finished = NO;
                                                            NSLog(@"RESPONSE: %@", response);
                                                            for (StreamingRecognitionResult *result in response.resultsArray) {
                                                                if (result.isFinal) {
                                                                    finished = YES;
                                                                    [self stopAudio:nil];
                                                                }
                                                            }
                                                            
                                                            StreamingRecognitionResult * firstResult = [response.resultsArray firstObject];
                                                            if (firstResult != nil) {
                                                                NSString* transcript = [[[firstResult alternativesArray] firstObject]transcript];
                                                                if (firstResult.isFinal){
                                                                    [self.delegate finalGoogleRecognitionRecieved: transcript];
                                                                }else{
                                                                    [self.delegate partialGoogleRecognitionRecieved: transcript];
                                                                }
                                                            }
                                                            if (finished) {
                                                                //1 Minute Max
                                                            }
                                                        }
                                                    }
         ];
        self.audioData = [[NSMutableData alloc] init];
    }
}

@end

