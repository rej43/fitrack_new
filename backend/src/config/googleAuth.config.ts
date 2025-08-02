import passport from 'passport';
import { Strategy as GoogleStrategy, Profile } from 'passport-google-oauth20';
import type { Request } from 'express';
import { VerifyCallback } from 'passport-oauth2';
import { env } from '../zod/env.schema';
import { User } from '../models/UserModel';

passport.use(
  new GoogleStrategy(
    {
      clientID: env.GOOGLE_CLIENT_ID,
      clientSecret: env.GOOGLE_CLIENT_SECRET,
      callbackURL: env.GOOGLE_CLIENT_REDIRECT,
      passReqToCallback: true,
    },
    async (
      req: Request,
      accessToken: string,
      refreshToken: string,
      profile: Profile,
      done: VerifyCallback
    ) => {
      try {
        // Check if user already exists with this Google ID
        let user = await User.findOne({ googleId: profile.id });

        if (!user) {
          // Check if user exists with the same email
          const email = profile.emails?.[0]?.value;
          if (email) {
            user = await User.findOne({ email });
          }

          if (!user) {
            // Create new user with Google data
            const displayName = profile.displayName || '';
            const nameParts = displayName.split(' ');
            const firstName = nameParts[0] || 'User';
            const lastName = nameParts.slice(1).join(' ') || '';

            user = await User.create({
              googleId: profile.id,
              firstName,
              lastName,
              email: email,
              password: Math.random().toString(36).slice(-10), // Generate random password for Google users
            });
          } else {
            // Update existing user with Google ID
            user.googleId = profile.id;
            await user.save();
          }
        }

        return done(null, user);
      } catch (error) {
        console.error('Google OAuth error:', error);
        return done(error as Error, undefined);
      }
    }
  )
);

passport.serializeUser((user: Express.User, done) => {
  done(null, user);
});

passport.deserializeUser(async (id: string, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (error) {
    done(error as Error, null);
  }
});
