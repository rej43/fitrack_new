import { ZodSchema, ZodError } from 'zod';
import { APIError } from './APIutil';

export const validateSchema = <T>(schema: ZodSchema, data: unknown): T => {
  const result = schema.safeParse(data);
  
  if (!result.success) {
    const errors = result.error.errors.map(error => ({
      field: error.path.join('.'),
      message: error.message
    }));
    
    throw new APIError(400, 'Validation failed');
  }
  
  return result.data;
};