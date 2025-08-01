import authRouter from "./Auth.route";
import healthRouter from "./Health.route";
import { activityRouter } from "./Activity.route";
import { isAuthenticated } from "../middlewares/Auth.middleware";
import { Router } from "express";

const router = Router();

router.use("/auth", authRouter);
router.use("/health",isAuthenticated,healthRouter);
router.use("/activity",isAuthenticated,activityRouter);

export default router;