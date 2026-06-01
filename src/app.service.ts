import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'StellarTip API — Decentralized micro-tipping on Stellar';
  }
}
