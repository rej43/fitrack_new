import { Router } from "express";
import { AuthController } from "../controllers/Auth.controller";
import { isAuthenticated } from "../middlewares/Auth.middleware";

const authRouter = Router();
const authController = new AuthController();

// Regular authentication routes
authRouter.post("/signup", authController.signUp);
authRouter.post("/signin", authController.signIn);

// Profile management routes (protected)
authRouter.put("/profile", isAuthenticated, authController.updateProfile);

// Google OAuth routes
authRouter.get("/google", authController.googleAuth);
authRouter.get("/google/callback", authController.googleCallBack);
authRouter.get("/google/failure", authController.googleFailure);

// Mobile OAuth routes
authRouter.post("/google/initiate", authController.initiateGoogleOAuth);
authRouter.get("/google/status/:sessionId", authController.checkOAuthStatus);

authRouter.get("/logout", authController.logOut);

// Protected route for testing
authRouter.get("/protected", authController.protectedRoute);

export default authRouter;