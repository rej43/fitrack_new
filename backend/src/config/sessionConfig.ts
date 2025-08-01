import { env } from "../zod/env.schema";

const sessionConfigs = {
    secret: env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false
}

export default sessionConfigs;