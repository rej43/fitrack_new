import { asyncHandler } from "../middlewares/AsyncHandler.middleware";
import { HealthService } from "../services/HealthInput.service";
import type { Request, Response } from "express";

export class HealthController {
    private healthservice: HealthService;

    constructor() {
        this.healthservice = new HealthService();
    }

    public createHealthDetails = asyncHandler(async (req: Request, res: Response) => {
        const result = this.healthservice.createHealthDetails(req.body, (req.user as any)?._id?.toString());

        return res.status(201).json({
            ...result,
            message: "User Health Data given successfully"
        })
    })

    public getHealthDetails = asyncHandler(async (req: Request, res: Response) => {
        const result = this.healthservice.getHealthDetailsforUser(req.body);

        return res.status(201).json({
            ...result,
            message: "Fetched user health details successfully",
        })
    })

    public updateHealthDetails = asyncHandler(async (req: Request, res: Response) => {
        const result = this.healthservice.updateHealthDetails(req.body, (req.user as any)?._id?.toString());

        return res.status(201).json({
            ...result,
            message: "Health Records updated successfully"
        })
    })



}