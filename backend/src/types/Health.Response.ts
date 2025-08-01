export interface HealthResponse {
  gender: "male" | "female";
  heightInCM: number;
  weightInKG: number;
  bodyType: 
    | "skinny"
    | "fat"
    | "normal"
    | "athlete"
    | "bulky"
    | "muscular"
    | "obese";
  healthGoal:
    | "muscle_gain"
    | "fat_loss"
    | "building_strength"
    | "bulking";
  bmi: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface ActivityResponse {
  date: Date; 
  sleepHours?: number;
  steps?: number;
  waterIntake?: number;
  foodCalories?: number;
}