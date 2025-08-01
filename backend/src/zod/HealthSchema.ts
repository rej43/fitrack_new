import z from "zod";

export const userHealth = z.object({
  heightInCM: z.number().min(50).max(250),
  weightInKG: z.number().min(10).max(300),
  gender: z.enum(["male", "female"]),
  bodyType: z.enum([
    "skinny",
    "fat",
    "normal",
    "athlete",
    "bulky",
    "muscular",
    "obese",
  ]),
  healthGoal: z.enum([
    "muscle_gain",
    "fat_loss",
    "building_strength",
    "bulking",
  ]),
});

export type userHealthInput = z.infer<typeof userHealth>