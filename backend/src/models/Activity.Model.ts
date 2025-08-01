import { prop, getModelForClass, Ref, DocumentType } from '@typegoose/typegoose';
import mongoose from 'mongoose';

export class ActivityClass {
  @prop({ required: true, ref: 'User' })
  public userId!: mongoose.Types.ObjectId;

  @prop({ required: true })
  public date!: Date;

  @prop()
  public sleepHours?: number; 

  @prop()
  public steps?: number;

  @prop()
  public waterIntake?: number; 

  @prop()
  public foodCalories?: number; 
}

export const ActivityModel = getModelForClass(ActivityClass);
export type AcitivityDocument = DocumentType<ActivityClass>;