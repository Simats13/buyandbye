import { lazy } from 'react';

// project imports
import MainLayout from 'layout/MainLayout';
import Loadable from 'ui-component/Loadable';
import AuthGuard from 'utils/route-guard/AuthGuard';

// sample page routing
const SamplePage = Loadable(lazy(() => import('views/sample-page')));
const Enterprise = Loadable(lazy(() => import('views/enterprise')));
const Products = Loadable(lazy(() => import('views/products')));
const Commands = Loadable(lazy(() => import('views/commands')));
const Chat = Loadable(lazy(() => import('views/chat')));
const Users = Loadable(lazy(() => import('views/users')));

// ==============================|| MAIN ROUTING ||============================== //

const MainRoutes = {
    path: '/',
    element: (
        <AuthGuard>
            <MainLayout />
        </AuthGuard>
    ),
    children: [
        {
            path: '/',
            element: <SamplePage />
        },
        {
            path: '/sample-page',
            element: <SamplePage />
        },
        {
            path: '/entreprise',
            element: <Enterprise />
        },
        {
            path: '/produits',
            element: <Products />
        },
        {
            path: '/commandes',
            element: <Commands />
        },
        {
            path: '/messagerie',
            element: <Chat />
        },
        {
            path: '/users',
            element: <Users />
        }
    ]
};

export default MainRoutes;
