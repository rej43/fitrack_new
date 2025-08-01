export interface UserResponse {
  id: string;
  email: string;
  firstName?: string;
  lastName?: string;
  createdAt: Date;
}

  
export interface AuthResponse {
  token: string;
  user: UserResponse;
}

export interface signIn {
  email: string;
  password: string;
}