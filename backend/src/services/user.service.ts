/**
 * Service Utilisateur - Logique metier pour l'authentification par mot de passe hache (scrypt) et profils
 */

import { db } from "@/lib/db";
import { IUser, CreateUserDTO, UserRole } from "@/types";
import {
  NotFoundError,
  UnauthorizedError,
  hashPassword,
  logger,
  verifyPassword,
} from "@/utils";

function mapDbUser(user: {
  id: string;
  email: string;
  name: string | null;
  role: string;
  createdAt: Date;
}): IUser {
  const validRole: UserRole =
    user.role === "DRIVER" || user.role === "ADMIN" ? user.role : "USER";
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: validRole,
    createdAt: user.createdAt,
  };
}

export class UserService {
  /**
   * Authentifie un utilisateur existant (verification scrypt en temps constant) ou cree un nouveau compte.
   */
  async findOrCreateUser(data: CreateUserDTO): Promise<IUser> {
    const normalizedEmail = data.email.trim().toLowerCase();
    const fallbackName =
      data.name && data.name.trim().length > 0
        ? data.name.trim()
        : normalizedEmail.split("@")[0];

    let user = await db.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user) {
      const passwordHash = data.password ? hashPassword(data.password) : null;
      user = await db.user.create({
        data: {
          email: normalizedEmail,
          name: fallbackName,
          passwordHash,
          role: data.role,
        },
      });
      logger.info("Nouvel utilisateur cree", {
        userId: user.id,
        role: user.role,
      });
      return mapDbUser(user);
    }

    if (user.passwordHash) {
      if (!data.password || !verifyPassword(data.password, user.passwordHash)) {
        throw new UnauthorizedError(
          "Mot de passe incorrect pour ce compte existant."
        );
      }
    } else if (data.password) {
      user = await db.user.update({
        where: { email: normalizedEmail },
        data: { passwordHash: hashPassword(data.password) },
      });
    }

    if (
      user.role !== data.role ||
      (data.name && user.name !== data.name.trim())
    ) {
      user = await db.user.update({
        where: { email: normalizedEmail },
        data: {
          role: data.role,
          name: data.name ? data.name.trim() : user.name,
        },
      });
    }

    return mapDbUser(user);
  }

  /**
   * Obtient un utilisateur par son identifiant unique.
   */
  async getUserById(userId: string): Promise<IUser> {
    const user = await db.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundError("Utilisateur");
    }

    return mapDbUser(user);
  }
}

export const userService = new UserService();
