import { asyncHandler } from "../middlewares/AsyncHandler.middleware";
import { AuthService } from "../services/AuthService";
import type { Request, Response, NextFunction } from "express";
import passport from "passport";
import jwt from "jsonwebtoken";
import { env } from "../zod/env.schema";

export class AuthController {
    private authService: AuthService

    constructor() {
        this.authService = new AuthService();
    }

    public signUp = asyncHandler(async (req: Request, res: Response) => {
        const result = await this.authService.userSignUp(req.body);

        return res.status(201).json({
            ...result,
            message: "User signed up successfully"
        })
    })

    public signIn = asyncHandler(async (req: Request, res: Response) => {
        const result = await this.authService.userSignIn(req.body);

        return res.status(201).json({
            ...result,
            message: "User Signed in successfully"
        })
    })

    public updateProfile = asyncHandler(async (req: Request, res: Response) => {
        const result = await this.authService.updateUserProfile(req.body, (req.user as any)?._id?.toString());

        return res.status(200).json({
            ...result,
            message: "Profile updated successfully"
        })
    })

    // Google OAuth Configuration
    public googleAuth = (req: Request, res: Response, next: NextFunction) => {
        passport.authenticate("google", {
            scope: ["email", "profile"]
        })(req, res, next);
    }

    public googleCallBack = (req: Request, res: Response, next: NextFunction) => {
        passport.authenticate("google", { session: false }, async (err: any, user: any) => {
            if (err) {
                return res.status(500).json({
                    success: false,
                    message: "Google authentication failed",
                    error: err.message
                });
            }

            if (!user) {
                return res.status(401).json({
                    success: false,
                    message: "Google authentication failed"
                });
            }

            try {
                // Generate JWT token
                const token = jwt.sign(
                    { userId: user._id, email: user.email },
                    env.JWT_SECRET,
                    { expiresIn: '7d' }
                );

                // Return success with token
                res.status(200).json({
                    success: true,
                    message: "Google authentication successful",
                    user: {
                        id: user._id,
                        name: user.name,
                        email: user.email,
                        googleId: user.googleId
                    },
                    token
                });
            } catch (error) {
                res.status(500).json({
                    success: false,
                    message: "Token generation failed",
                    error: error instanceof Error ? error.message : "Unknown error"
                });
            }
        })(req, res, next);
    }

    public googleFailure = (req: Request, res: Response) => {
        res.status(401).json({
            success: false,
            message: "Failed to authenticate with Google"
        });
    }

    public protectedRoute = (req: Request, res: Response) => {
        res.json({
            success: true,
            message: "You have successfully accessed the protected route",
            user: req.user
        });
    }

    public logOut = (req: Request, res: Response) => {
        req.logOut((error) => {
            if (error) {
                console.error("Error Logging Out", error);
                return res.status(500).json({
                    error: "Failed to log out"
                })
            }
            req.session.destroy(() => {
                res.json({
                    success: true,
                    message: "Logged out successfully"
                });
            })
        })
    }
}