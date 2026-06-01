import { IsString, IsOptional, IsUrl, MaxLength } from 'class-validator';

export class CreateProfileDto {
  @IsString()
  @IsOptional()
  @MaxLength(500)
  bio?: string;

  @IsString()
  @IsOptional()
  displayName?: string;

  @IsUrl()
  @IsOptional()
  avatarUrl?: string;
}
