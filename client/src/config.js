export const JWT_API = {
    secret: 'SECRET-KEY',
    timeout: '1 days'
};

export const FIREBASE_API = {
    apiKey: process.env.REACT_APP_API_KEY,
    authDomain: process.env.REACT_APP_AUTH_DOMAIN,
    databaseURL: process.env.REACT_APP_DATABASE_URL,
    projectId: process.env.REACT_APP_PROJECT_ID,
    storageBucket: process.env.REACT_APP_STORAGE_BUCKET,
    messagingSenderId: process.env.REACT_APP_MESSASING_SENDER_ID,
    appId: process.env.REACT_APP_APPID,
    measurementId: process.env.REACT_APP_MEASUREMENT_ID
};

export const AUTH0_API = {
    client_id: '7T4IlWis4DKHSbG8JAye4Ipk0rvXkH9V',
    domain: 'dev-w0-vxep3.us.auth0.com'
};

export const AWS_API = {
    poolId: 'us-east-1_AOfOTXLvD',
    appClientId: '3eau2osduslvb7vks3vsh9t7b0'
};

// basename: only at build time to set, and Don't add '/' at end off BASENAME for breadcrumbs, also Don't put only '/' use blank('') instead,
// like '/berry-material-react/react/default'
export const BASE_PATH = '';

export const DASHBOARD_PATH = '/';

const config = {
    fontFamily: `'Roboto', sans-serif`,
    borderRadius: 8,
    outlinedFilled: true,
    navType: 'light', // light, dark
    presetColor: 'theme3', // default, theme1, theme2, theme3, theme4, theme5, theme6
    locale: 'fr', // 'en' - English, 'fr' - French, 'ro' - Romanian, 'zh' - Chinese
    rtlLayout: false,
    container: false
};

export default config;
