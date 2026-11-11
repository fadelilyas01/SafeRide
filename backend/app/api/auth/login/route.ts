import { NextResponse } from "next/server";
import { createUserSchema } from "@/schemas";
import { userService } from "@/services";
import { AppError, createSignedSessionToken, logger, verifyRateLimit } from "@/utils";

export async function POST(request: Request) {
  try {
    const clientIp =
      request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ||
      "local-client";
    const rateCheck = verifyRateLimit(`auth_login:${clientIp}`, 15, 60 * 1000);

    if (!rateCheck.allowed) {
      return NextResponse.json(
        {
          error: `Trop de tentatives de connexion. Veuillez patienter ${rateCheck.retryAfterSeconds} secondes.`,
        },
        { status: 429 }
      );
    }

    const rawBody: unknown = await request.json();
    const parsed = createUserSchema.safeParse(rawBody);

    if (!parsed.success) {
      const firstIssue =
        parsed.error.issues[0]?.message || "Donnees de connexion invalides.";
      return NextResponse.json({ error: firstIssue }, { status: 400 });
    }

    const user = await userService.findOrCreateUser(parsed.data);
    const sessionToken = createSignedSessionToken({
      userId: user.id,
      role: user.role,
    });

    const response = NextResponse.json(
      {
        success: true,
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
        },
      },
      { status: 200 }
    );

    response.cookies.set("saferide_session", sessionToken, {
      httpOnly: true,
      sameSite: "strict",
      secure: process.env.NODE_ENV === "production",
      maxAge: 15 * 60,
      path: "/",
    });

    return response;
  } catch (error: unknown) {
    logger.error("Erreur lors de l'authentification", error);
    if (error instanceof AppError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }
    return NextResponse.json(
      { error: "Une erreur interne est survenue lors de la connexion." },
      { status: 500 }
    );
  }
}
