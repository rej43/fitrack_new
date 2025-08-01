import { Router } from "express";
import { ActivityController } from "../controllers/Activity.Controller";

export const activityRouter = Router();
const activityController = new ActivityController();

activityRouter.post("/logActivity",activityController.logActivity);
activityRouter.get("/getActivityLog", activityController.getActivity);
activityRouter.put("/updateActivityLog", activityController.updateActivity);