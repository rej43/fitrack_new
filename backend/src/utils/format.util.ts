import { UserDocument } from "../models/UserModel";
import { UserResponse } from "../types/User.Respnse";
import { HealthDocument } from "../models/HealthInputDetails.Model";
import { HealthResponse } from "../types/Health.Response";
import { AcitivityDocument } from "../models/Activity.Model";

export const formatUserResponse = (user: UserDocument): UserResponse => {
  return {
    id: user._id.toString(),
    email: user.email!,
    firstName: user.firstName,
    lastName: user.lastName,
    createdAt: user.createdAt!,
  };
};

export const formatHealthResponse = (
  health: HealthDocument
): HealthResponse => {
  const bmi = health.calculateBMI();

  return {
    gender: health.gender,
    heightInCM: health.heightInCM,
    weightInKG: health.weightInKG,
    bodyType: health.bodyType,
    healthGoal: health.healthGoal,
    bmi,
    createdAt: health.createdAt!,
    updatedAt: health.updatedAt!,
  };
};

export const formatActivityResponse = (activity: AcitivityDocument) => {
    return {
        sleepHours: activity.sleepHours,
        steps: activity.steps,
        waterIntake: activity.waterIntake,
        foodCalories: activity.foodCalories,
    }
}
