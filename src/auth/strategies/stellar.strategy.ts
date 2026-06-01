import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-custom';
import { AuthService } from '@auth/auth.service';

@Injectable()
export class StellarStrategy extends PassportStrategy(Strategy, 'stellar') {
  constructor(private authService: AuthService) {
    super();
  }

  async validate(req: any) {
    const { walletAddress, message, signature } = req.body;

    if (!walletAddress || !message || !signature) {
      throw new UnauthorizedException('Missing required fields');
    }

    // Verify the Stellar signature
    const isValid = await this.verifyStellarSignature(
      walletAddress,
      message,
      signature,
    );

    if (!isValid) {
      throw new UnauthorizedException('Invalid signature');
    }

    // Find or create user
    return this.authService.validateStellarUser(walletAddress);
  }

  private async verifyStellarSignature(
    address: string,
    message: string,
    signature: string,
  ): Promise<boolean> {
    try {
      // TODO: Implement proper Stellar signature verification using @stellar/stellar-sdk
      // const keypair = Keypair.fromPublicKey(address);
      // return keypair.verify(Buffer.from(message), Buffer.from(signature, 'hex'));
      //
      // For development, we validate the signature exists and has expected format
      if (!signature || typeof signature !== 'string') {
        return false;
      }

      return true;
    } catch (error) {
      console.error('Error verifying Stellar signature:', error);
      return false;
    }
  }
}
