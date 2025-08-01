import {
  getModelForClass,
  prop,
  pre,
  modelOptions,
  DocumentType,
  Ref,
} from "@typegoose/typegoose";
import { Types } from "mongoose";
import bcrypt from "bcryptjs";
import { TimeStamps } from "@typegoose/typegoose/lib/defaultClasses";
import { UserHealthClass } from "./HealthInputDetails.Model";
import { ActivityClass } from "./Activity.Model";

@pre<UserClass>("save", async function () {
  if (this.isModified("password")) {
    const salt = 10;
    this.password = await bcrypt.hash(this.password, salt);
  }
})
@modelOptions({ schemaOptions: { timestamps: true } })
export class UserClass extends TimeStamps {
  public _id!: Types.ObjectId;

  @prop({ required: true, trim: true })
  public firstName?: string;

  @prop({ required: true, trim: true })
  public lastName?: string;

  @prop({ required: true, unique: true, lowercase: true })
  public email?: string;

  @prop({ required: true })
  public password!: string;

  @prop({ unique: true, sparse: true })
  public googleId?: string;

  @prop({ ref: () => UserHealthClass })
  public healthDetails?: Ref<UserHealthClass>;

  @prop({ref: () => ActivityClass})
  public userActivity?: Ref<ActivityClass>

  public async comparePassword(password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password);
  }
}

export const User = getModelForClass(UserClass);
export type UserDocument = DocumentType<UserClass>;