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
                // Set session state to failed
                req.session.oauthState = 'failed';
                return res.status(500).json({
                    success: false,
                    message: "Google authentication failed",
                    error: err.message
                });
            }

            if (!user) {
                // Set session state to failed
                req.session.oauthState = 'failed';
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

                // Store user and token in session for mobile OAuth
                req.session.user = {
                    id: user._id,
                    name: user.firstName + ' ' + user.lastName,
                    email: user.email,
                    googleId: user.googleId
                };
                req.session.token = token;
                req.session.oauthState = 'completed';

                // Return success with token
                res.status(200).json({
                    success: true,
                    message: "Google authentication successful",
                    user: {
                        id: user._id,
                        name: user.firstName + ' ' + user.lastName,
                        email: user.email,
                        googleId: user.googleId
                    },
                    token
                });
            } catch (error) {
                req.session.oauthState = 'failed';
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

    // Mobile OAuth methods
    public initiateGoogleOAuth = asyncHandler(async (req: Request, res: Response) => {
        // Generate a unique session ID for this OAuth attempt
        const sessionId = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
        
        // Store the session ID in the session
        req.session.oauthSessionId = sessionId;
        req.session.oauthState = 'pending';
        
        // Return the OAuth URL and session ID
        const oauthUrl = `${env.CLIENT_URL}/api/v1/auth/google?sessionId=${sessionId}`;
        
        return res.status(200).json({
            success: true,
            sessionId: sessionId,
            oauthUrl: oauthUrl,
            message: "OAuth session initiated"
        });
    });

    public checkOAuthStatus = asyncHandler(async (req: Request, res: Response) => {
        const { sessionId } = req.params;
        
        // Check if the session exists and has completed OAuth
        if (req.session.oauthSessionId === sessionId && req.session.oauthState === 'completed') {
            // OAuth completed successfully
            const user = req.session.user;
            const token = req.session.token;
            
            // Clear the OAuth session data
            delete req.session.oauthSessionId;
            delete req.session.oauthState;
            delete req.session.user;
            delete req.session.token;
            
            return res.status(200).json({
                success: true,
                message: "OAuth completed successfully",
                user: user,
                token: token
            });
        } else if (req.session.oauthSessionId === sessionId && req.session.oauthState === 'failed') {
            // OAuth failed
            delete req.session.oauthSessionId;
            delete req.session.oauthState;
            
            return res.status(401).json({
                success: false,
                message: "OAuth authentication failed"
            });
        } else {
            // OAuth still pending
            return res.status(200).json({
                success: false,
                message: "OAuth still pending",
                status: 'pending'
            });
        }
    });

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