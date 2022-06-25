import { lazy } from 'react';

// project imports
import Loadable from 'ui-component/Loadable';

// sample page routing
// const SamplePage = Loadable(lazy(() => import('views/sample-page')));
const ContactUs = Loadable(lazy(() => import('views/landing/contact-us/')));
const PagesLanding = Loadable(lazy(() => import('views/landing')));
const PricePage = Loadable(lazy(() => import('views/landing/price')));
// ==============================|| MAIN ROUTING ||============================== //

const LandingRoutes = {
    path: '/',
    children: [
        {
            path: '/',
            element: <PagesLanding />
        },
        {
            path: '/contact',
            element: <ContactUs />
        },
        {
            path: '/abonnements',
            element: <PricePage />
        }
    ]
};

export default LandingRoutes;
