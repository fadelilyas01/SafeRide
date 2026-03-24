import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private isInitialized = false;

  constructor(private configService: ConfigService) {
    const serviceAccount = this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT_JSON');
    
    if (serviceAccount) {
      try {
        const parsedAccount = JSON.parse(serviceAccount);
        admin.initializeApp({
          credential: admin.credential.cert(parsedAccount),
        });
        this.isInitialized = true;
        this.logger.log('Firebase Admin initialized successfully');
      } catch (error) {
        this.logger.error('Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON:', error.message);
      }
    } else {
      this.logger.warn('FIREBASE_SERVICE_ACCOUNT_JSON is missing. Push notifications are disabled.');
    }
  }

  async sendPushNotification(token: string, title: string, body: string, data?: any) {
    if (!this.isInitialized || !token) return false;

    try {
      const message: admin.messaging.Message = {
        token,
        notification: { title, body },
        data: data || {},
        android: {
          priority: 'high',
          notification: { sound: 'default', channelId: 'saferide_channel' }
        },
        apns: {
          payload: {
            aps: { sound: 'default', badge: 1 }
          }
        }
      };

      const response = await admin.messaging().send(message);
      this.logger.log(`Successfully sent message: ${response}`);
      return true;
    } catch (error) {
      this.logger.error('Error sending message:', error);
      return false;
    }
  }
}
