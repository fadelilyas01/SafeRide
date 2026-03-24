import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { PrismaService } from './prisma.service';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class EventsGateway {
  constructor(private prisma: PrismaService) {}

  @WebSocketServer()
  server: Server;

  @SubscribeMessage('join')
  handleJoin(
    @MessageBody() data: { room: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(data.room);
    console.log(`Client ${client.id} joined room ${data.room}`);
  }

  @SubscribeMessage('updateLocation')
  handleLocationUpdate(
    @MessageBody() data: { userId: string; lat: number; lng: number },
  ) {
    // Diffuser la position aux abonnés de la zone ou de la plateforme admin
    this.server.emit('driverLocation', data);
  }

  @SubscribeMessage('rideStatus')
  handleRideStatus(@MessageBody() data: { rideId: string; status: string }) {
    this.server.to(`ride_${data.rideId}`).emit('statusUpdate', data);
  }

  // Méthode utilitaire pour envoyer des alertes depuis les services
  sendToAdmin(event: string, data: any) {
    this.server.emit(`admin_${event}`, data);
  }

  @SubscribeMessage('joinRideChat')
  handleJoinRideChat(
    @MessageBody() data: { rideId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`ride_chat_${data.rideId}`);
    console.log(
      `Client ${client.id} joined chat room ride_chat_${data.rideId}`,
    );
  }

  @SubscribeMessage('sendMessage')
  async handleSendMessage(
    @MessageBody()
    data: {
      rideId: string;
      senderId: string;
      text: string;
    },
  ) {
    const message = await this.prisma.chatMessage.create({
      data: {
        rideId: data.rideId,
        senderId: data.senderId,
        text: data.text,
      },
      include: { sender: true },
    });

    this.server
      .to(`ride_chat_${data.rideId}`)
      .emit('newMessage', message);

    return message;
  }
}
