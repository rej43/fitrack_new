import { Router } from "express";
import { HealthController } from "../controllers/Health.Controllers";

const healthRouter = Router();
const healthController = new HealthController();

healthRouter.post("/createHealthData",healthController.createHealthDetails);
healthRouter.get("/getHealthDetauls",healthController.updateHealthDetails);
healthRouter.put("/updateHealthRecord",healthController.updateHealthDetails);

export default healthRouter;