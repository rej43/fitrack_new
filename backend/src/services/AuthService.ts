import { APIError } from "../utils/APIutil";
import { signUpSchema, loginSchema } from "../zod/Auth.Schema";
import { User } from "../models/UserModel";
import { generateToken } from "../utils/TokenGeneration";
import { SignUpInput, LoginInput } from "../zod/Auth.Schema";
import { validateSchema } from "../utils/Validate.Util";
import { formatUserResponse } from "../utils/format.util";
import { AuthResponse } from "../types/User.Respnse";

export class AuthService {
  public async userSignUp(input: SignUpInput): Promise<AuthResponse> {
      const validatedData: SignUpInput = validateSchema(signUpSchema, input);
      const existingUser = await User.findOne({
        $or: [
            {email: validatedData.email},
        ]
      })

      if(existingUser){
        throw new APIError(400, "User Already Exist");
      }
      const user = await User.create(validatedData);
      const token = generateToken(user._id.toString());

      return {
        token,
        user: formatUserResponse(user)
      }
  }

  public async userSignIn(input: LoginInput): Promise<AuthResponse> {
    const validatedData: LoginInput = validateSchema(loginSchema, input);
    const existingUser = await User.findOne({
        $or: [{email: validatedData.email}]
    })

    if(!existingUser){
        throw new APIError(404, "User with this email does not exist")
    }

    const validatePassword = await existingUser.comparePassword(validatedData.password);
    
    if(!validatePassword){
        throw new APIError(400, "Incorrect Password");
    }

    const token = generateToken(existingUser._id.toString());

    return {
        token,
        user: formatUserResponse(existingUser)
    }
  }

  public async updateUserProfile(input: any, userId: string): Promise<AuthResponse> {
    if (!userId) {
      throw new APIError(401, "User not authenticated");
    }

    const user = await User.findById(userId);
    if (!user) {
      throw new APIError(404, "User not found");
    }

    // Update allowed fields
    if (input.firstName) user.firstName = input.firstName;
    if (input.lastName) user.lastName = input.lastName;
    if (input.email) {
      // Check if email is already taken by another user
      const existingUser = await User.findOne({ email: input.email, _id: { $ne: userId } });
      if (existingUser) {
        throw new APIError(400, "Email already taken");
      }
      user.email = input.email;
    }

    await user.save();
    const token = generateToken(user._id.toString());

    return {
      token,
      user: formatUserResponse(user)
    };
  }

  public async googleSign(){
    
  }
}
