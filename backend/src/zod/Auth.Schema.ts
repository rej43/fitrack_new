import z from "zod";

export const passwordSchema = z
  .string()
  .min(8, "Password must be at least 8 characters long")
  .max(64, "Password must not exceed 64 characters")
  .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
  .regex(/[a-z]/, "Password must contain at least one lowercase letter")
  .regex(/[0-9]/, "Password must contain at least one number")
  .regex(
    /[@$!%*?&]/,
    "Password must contain at least one special character (@$!%*?&)"
  );

export const signUpSchema = z.object({
  email: z.string().email("Invalid email format"),
  password: passwordSchema,
  firstName: z.string().min(3, "Name must not be less than 3 characters").max(40,"Name must not be more than 40 characters"),
  lastName: z.string().min(2,"At least 2 letters").max(40,"Can't be more than 40 letters")
});

export const loginSchema = z.object({
  email: z.string().email("Invalid email format"),
  password: z.string(),
});

export type SignUpInput = z.infer<typeof signUpSchema>
export type LoginInput = z.infer<typeof loginSchema>