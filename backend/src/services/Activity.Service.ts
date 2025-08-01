import { ActivityModel } from "../models/Activity.Model";
import { User } from "../models/UserModel";
import { APIError } from "../utils/APIutil";
import { formatActivityResponse } from "../utils/format.util";
import { validateSchema } from "../utils/Validate.Util";
import { ActivityInput, ActivitySchema } from "../zod/Activity.Schema";

export class ActivityService {
    public async createActivityLog(input:ActivityInput, userId: string){
        const validatedData: ActivityInput = validateSchema(ActivitySchema, input);
        
        const logUserAcitivity = await ActivityModel.create({
            ...validatedData,
            userId
        })

        if(!logUserAcitivity){
            throw new APIError(500, "Failed to log user activity");
        }
        return formatActivityResponse(logUserAcitivity);
    }

    public async getActivityLog(userId: string){
        const user = await User.findById(userId);

        if(!user){
            throw new APIError(404, "User not found");
        }

        const activity = user.userActivity as any;

        return formatActivityResponse(activity)
    }

    public async updateActivityLog(input:ActivityInput, userId: string){
        const validatedData: ActivityInput = validateSchema(ActivitySchema, input)
    }
}