import { Tip } from './tip.entity';
export declare enum AuthMethod {
    EMAIL = "email",
    STELLAR = "stellar"
}
export declare enum UserRole {
    USER = "user",
    ADMIN = "admin"
}
export declare class User {
    id: string;
    username: string;
    displayName: string;
    bio: string;
    avatarUrl: string;
    email: string;
    password: string;
    walletAddress: string;
    authMethod: AuthMethod;
    role: UserRole;
    isActive: boolean;
    receivedTips: Tip[];
    sentTips: Tip[];
    createdAt: Date;
    updatedAt: Date;
    validateAuthMethod(): void;
}
