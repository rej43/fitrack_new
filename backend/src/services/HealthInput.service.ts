import { UserHealthDetails } from "../models/HealthInputDetails.Model";
import { APIError } from "../utils/APIutil";
import { userHealth, userHealthInput } from "../zod/HealthSchema";
import { User } from "../models/UserModel";
import { HealthResponse } from "../types/Health.Response";
import { validateSchema } from "../utils/Validate.Util";
import { formatHealthResponse } from "../utils/format.util";

export class HealthService {

  public async createHealthDetails(input: userHealthInput, userId: string): Promise<HealthResponse>{
   const validatedData: userHealthInput = validateSchema(userHealth,input);
  
   const createHealthDetails = await UserHealthDetails.create({
    ...validatedData,
    user: userId
   });

   return formatHealthResponse(createHealthDetails);
  }
   
  public async getHealthDetailsforUser(userId: string): Promise<HealthResponse>{
    const user = await User.findById(userId);

    if(!user){
      throw new APIError(404, "User does not exits");
    }

    if(!user.healthDetails){
      throw new APIError(400, "User has no health inputs given yet")
    }

    const health = user.healthDetails as any;
    
    return formatHealthResponse(health);
  }

  public async updateHealthDetails(userId: string, input: userHealthInput): Promise<HealthResponse>{
    const validatedData = validateSchema(userHealth, input);

    const user = await User.findById(userId).populate("healthDetails");

    if (!user) {
      throw new APIError(404, "User not found");
    }

    if (!user.healthDetails) {
      throw new APIError(404, "User has no existing health data to update");
    }

    const healthRecordId = user.healthDetails._id;
    const updatedHealthRecord = await UserHealthDetails.findByIdAndUpdate(
      validatedData,
      healthRecordId,
      { new: true }
    );

    if(!updatedHealthRecord){
      throw new APIError(500, "Failed to update health records");
    }
    return formatHealthResponse(updatedHealthRecord)
  }
}

