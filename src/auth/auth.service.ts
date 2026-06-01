import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User, AuthMethod, UserRole } from '../entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async validateStellarUser(walletAddress: string) {
    // Validate Stellar public key format (starts with G, 56 chars base-32)
    if (!walletAddress.startsWith('G') || walletAddress.length !== 56) {
      throw new UnauthorizedException('Invalid Stellar wallet address');
    }

    let user = await this.usersRepository.findOne({
      where: { walletAddress },
    });

    if (!user) {
      // Generate a unique username from wallet address
      const username = `stellar_${walletAddress.slice(-8).toLowerCase()}`;

      user = this.usersRepository.create({
        walletAddress,
        username,
        displayName: `Stellar User ${walletAddress.slice(-4)}`,
        authMethod: AuthMethod.STELLAR,
        isActive: true,
      });
      await this.usersRepository.save(user);
    }

    return user;
  }

  async login(user: User) {
    const payload = {
      sub: user.id,
      role: user.role,
      authMethod: user.authMethod,
    };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        walletAddress: user.walletAddress,
        authMethod: user.authMethod,
        role: user.role,
      },
    };
  }

  async signup(email: string, password: string, username: string, displayName?: string) {
    const existingEmail = await this.usersRepository.findOne({ where: { email } });
    if (existingEmail) {
      throw new ConflictException('Email already in use');
    }

    const existingUsername = await this.usersRepository.findOne({ where: { username } });
    if (existingUsername) {
      throw new ConflictException('Username already taken');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = this.usersRepository.create({
      email,
      password: hashedPassword,
      username,
      displayName: displayName || username,
      authMethod: AuthMethod.EMAIL,
      role: UserRole.USER,
      isActive: true,
    });

    await this.usersRepository.save(user);

    const payload = { sub: user.id, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        email: user.email,
        role: user.role,
      },
    };
  }

  async loginWithEmail(email: string, password: string) {
    const user = await this.usersRepository.findOne({
      where: { email },
      select: ['id', 'email', 'password', 'username', 'displayName', 'role', 'authMethod', 'isActive'],
    });

    if (!user || !user.password) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.isActive) {
      throw new UnauthorizedException('Account is deactivated');
    }

    const payload = { sub: user.id, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        email: user.email,
        role: user.role,
      },
    };
  }

  async getNonce(walletAddress: string) {
    const nonce = Math.floor(Math.random() * 1000000).toString();
    const message = `StellarTip Authentication\n\nWallet: ${walletAddress}\nNonce: ${nonce}\n\nSign this message to authenticate with StellarTip.`;

    return { nonce, message };
  }
}
