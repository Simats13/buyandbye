import { useRoutes } from 'react-router-dom';

// routes
import MainRoutes from './MainRoutes';
import LoginRoutes from './LoginRoutes';
import LandingRoutes from './LandingRoutes';
import Error from 'views/maintenance/Error';

// ==============================|| ROUTING RENDER ||============================== //

export default function ThemeRoutes() {
    return useRoutes([LandingRoutes, LoginRoutes, MainRoutes, { path: '*', element: <Error /> }]);
}
