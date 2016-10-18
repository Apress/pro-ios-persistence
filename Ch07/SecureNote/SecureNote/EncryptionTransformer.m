//
//  EncryptionTransformer.m
//  SecureNote
//
//  Created by Rob Warner on 10/13/14.
//  Copyright (c) 2014 Michael Privat and Rob Warner. All rights reserved.
//

@import SystemConfiguration;

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "EncryptionTransformer.h"
#import "AppDelegate.h"

#define kSaltLength 8

@implementation EncryptionTransformer

+ (Class)transformedValueClass {
  return [NSData class];
}

- (id)transformedValue:(id)value {
  // We're passed in a string (NSString) that we're going to encrypt.
  // The format of the bytes we return is:
  // salt (16 bytes) | IV (16 bytes) | encrypted string
  NSData *salt = [self randomDataOfLength:kSaltLength];
  NSData *iv = [self randomDataOfLength:kCCBlockSizeAES128];
  NSData *data = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
  
  // Do the actual encryption
  NSData *result = [self transform:data
                          password:[self password]
                              salt:salt
                                iv:iv
                         operation:kCCEncrypt];
  
  // Build the response data
  NSMutableData *response = [[NSMutableData alloc] init];
  [response appendData:salt];
  [response appendData:iv];
  [response appendData:result];
  return response;
}

- (id)reverseTransformedValue:(id)value {
  // We're passed in bytes (NSData) from Core Data that we're going to transform
  // into a string (NSString) and return to the application.
  
  // The bytes are in the format:
  // salt (16 bytes) | IV (16 bytes) | encrypted data
  NSData *data = (NSData *)value;
  NSData *salt = [data subdataWithRange:NSMakeRange(0, kSaltLength)];
  NSData *iv = [data subdataWithRange:NSMakeRange(kSaltLength, kCCBlockSizeAES128)];
  NSData *text = [data subdataWithRange:NSMakeRange(kSaltLength + kCCBlockSizeAES128, [data length] - kSaltLength - kCCBlockSizeAES128)];
  
  // Get the decrypted data
  NSData *decrypted = [self transform:text password:[self password] salt:salt iv:iv operation:kCCDecrypt];
  
  // Return only the decrypted string
  return [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
}

- (NSData *)transform:(NSData *)value
             password:(NSString *)password
                 salt:(NSData *)salt
                   iv:(NSData *)iv
            operation:(CCOperation)operation {
  // Get the key by salting the password
  NSData *key = [self keyForPassword:password salt:salt];
  
  // Perform the operation (encryption or decryption)
  size_t outputSize = 0;
  NSMutableData *outputData = [NSMutableData dataWithLength:value.length + kCCBlockSizeAES128];
  CCCryptorStatus status = CCCrypt(operation,
                                   kCCAlgorithmAES128,
                                   kCCOptionPKCS7Padding,
                                   key.bytes,
                                   key.length,
                                   iv.bytes,
                                   value.bytes,
                                   value.length,
                                   outputData.mutableBytes,
                                   outputData.length,
                                   &outputSize);
  
  // On success, set the size and return the data
  // On failure, return nil
  if (status == kCCSuccess) {
    outputData.length = outputSize;
    return outputData;
  } else {
    return nil;
  }
}

- (NSData *)keyForPassword:(NSString *)password
                      salt:(NSData *)salt {
  // Append the salt to the password
  NSMutableData *passwordAndSalt = [[password dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
  [passwordAndSalt appendData:salt];
  
  // Hash it
  NSData *hash = [self sha1:passwordAndSalt];
  
  // Create the key by using the hashed password and salt, making
  // it the proper size for AES128 (0-padding if necessary)
  NSRange range = NSMakeRange(0, MIN(hash.length, kCCBlockSizeAES128));
  NSMutableData *key = [NSMutableData dataWithLength:kCCBlockSizeAES128];
  [key replaceBytesInRange:range withBytes:hash.bytes];
  return key;
}

- (NSData *)sha1:(NSData *)data {
  // Get the SHA1 into an array
  uint8_t digest[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(data.bytes, (CC_LONG) data.length, digest);
  
  // Create a formatted string with the SHA1
  NSMutableString* sha1 = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
    [sha1 appendFormat:@"%02x", digest[i]];
  }
  return [sha1 dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)password {
  return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).password;
}

- (NSData *)randomDataOfLength:(size_t)length {
  // SecRandomCopyBytes returns 0 on success, non-zero on failure
  // If the call fails, the buffer will be full of zeros left over
  // from NSMutableData dataWithLength:, which is less secure!
  // A shipping app may choose to fail if this step fails
  NSMutableData *randomData = [NSMutableData dataWithLength:length];
  SecRandomCopyBytes(kSecRandomDefault, length, randomData.mutableBytes);
  return randomData;
}

@end
