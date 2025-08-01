import { z } from 'zod';

export const ActivitySchema = z.object({
    sleepHours: z.number(),
    steps: z.number(),
    waterIntake: z.number(),
    foodCalories: z.number(),
})

export type ActivityInput = z.infer<typeof ActivitySchema>