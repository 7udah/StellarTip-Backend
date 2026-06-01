import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { CreateProfileDto } from './dto/create-profile.dto';

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
