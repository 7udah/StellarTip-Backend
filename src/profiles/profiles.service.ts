import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { CreateProfileDto } from './dto/create-profile.dto';
import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';

@Injectable()
export class ProfilesService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async getProfile(username: string) {
    const user = await this.usersRepository.findOne({
      where: { username, isActive: true },
      select: [
        'id',
        'username',
        'displayName',
        'bio',
        'avatarUrl',
        'walletAddress',
        'createdAt',
      ],
    });

    if (!user) {
      throw new NotFoundException('Profile not found');
    }

    return user;
  }

  async getProfileById(id: string) {
    const user = await this.usersRepository.findOne({
      where: { id, isActive: true },
      select: [
        'id',
        'username',
        'displayName',
        'bio',
        'avatarUrl',
        'walletAddress',
        'createdAt',
      ],
    });

    if (!user) {
      throw new NotFoundException('Profile not found');
    }

    return user;
  }

  async updateProfile(userId: string, updateDto: CreateProfileDto) {
    const user = await this.usersRepository.findOne({ where: { id: userId } });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (updateDto.displayName) {
      user.displayName = updateDto.displayName;
    }
    if (updateDto.bio !== undefined) {
      user.bio = updateDto.bio;
    }
    if (updateDto.avatarUrl !== undefined) {
      user.avatarUrl = updateDto.avatarUrl;
    }

    return this.usersRepository.save(user);
  }

  async updateWalletAddress(userId: string, walletAddress: string) {
    const existing = await this.usersRepository.findOne({
      where: { walletAddress },
    });
    if (existing && existing.id !== userId) {
      throw new ConflictException('Wallet address already linked to another account');
    }

    const user = await this.usersRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    user.walletAddress = walletAddress;
    return this.usersRepository.save(user);
  }

  async uploadAvatar(userId: string, file: any): Promise<string> {
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedMimeTypes.includes(file.mimetype)) {
      throw new BadRequestException(
        `Unsupported file type: ${file.mimetype}. Allowed types: JPEG, PNG, WEBP`,
      );
    }

    if (file.size > 5 * 1024 * 1024) {
      throw new BadRequestException('File size exceeds 5MB limit');
    }

    const user = await this.usersRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Delete old avatar if it exists
    if (user.avatarUrl) {
      const oldPath = path.join(__dirname, '..', '..', '..', 'uploads', 'avatars', path.basename(user.avatarUrl));
      try {
        fs.unlinkSync(oldPath);
      } catch {
        // File may not exist, ignore
      }
    }

    // Save new avatar
    const ext = file.originalname.split('.').pop() || 'png';
    const filename = `${crypto.randomUUID()}.${ext}`;
    const uploadDir = path.join(__dirname, '..', '..', '..', 'uploads', 'avatars');

    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    fs.writeFileSync(path.join(uploadDir, filename), file.buffer);

    const avatarUrl = `/uploads/avatars/${filename}`;
    user.avatarUrl = avatarUrl;
    await this.usersRepository.save(user);

    return avatarUrl;
  }

  async searchProfiles(query: string) {
    return this.usersRepository
      .createQueryBuilder('user')
      .where('user.isActive = :active', { active: true })
      .andWhere(
        '(user.username ILIKE :query OR user.displayName ILIKE :query)',
        { query: `%${query}%` },
      )
      .select([
        'user.id',
        'user.username',
        'user.displayName',
        'user.bio',
        'user.avatarUrl',
      ])
      .take(20)
      .getMany();
  }
}
