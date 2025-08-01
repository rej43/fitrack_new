import { getModelForClass, prop, modelOptions, DocumentType } from "@typegoose/typegoose";
import { TimeStamps } from "@typegoose/typegoose/lib/defaultClasses";

export enum Gender {
  MALE = "male",
  FEMALE = "female",
}

export enum BodyType {
  SKINNY = "skinny",
  FAT = "fat",
  NORMAL = "normal",
  ATHLETE = "athlete",
  BULKY = "bulky",
  MUSCULAR = "muscular",
  OBESE = "obese",
}

export enum HealthGoal {
  MUSCLE_GAIN = "muscle_gain",
  FAT_LOSS = "fat_loss",
  BUILDING_STRENGTH = "building_strength",
  BULKING = "bulking",
}

@modelOptions({ schemaOptions: { timestamps: true } })
export class UserHealthClass extends TimeStamps {
  @prop({ required: true, enum: Gender })
  public gender!: Gender;

  @prop({ required: true, min: 50, max: 250 })
  public heightInCM!: number;

  @prop({ required: true, min: 10, max: 300 })
  public weightInKG!: number;

  @prop({ required: true, enum: BodyType })
  public bodyType!: BodyType;

  @prop({ required: true, enum: HealthGoal })
  public healthGoal!: HealthGoal;

  public calculateBMI(): number {
    const heightInMeters = this.heightInCM / 100;
    const bmi = this.weightInKG / (heightInMeters * heightInMeters);
    return Math.round(bmi * 10) / 10;
  }
}

export const UserHealthDetails = getModelForClass(UserHealthClass);
export type HealthDocument = DocumentType<UserHealthClass>
