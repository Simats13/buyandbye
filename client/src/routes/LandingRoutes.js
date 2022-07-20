import { lazy } from 'react';

// project imports
import Loadable from 'ui-component/Loadable';

// sample page routing
// const SamplePage = Loadable(lazy(() => import('views/sample-page')));
const ContactUs = Loadable(lazy(() => import('views/landing/contact-us/')));
const PagesLanding = Loadable(lazy(() => import('views/landing')));
const PricePage = Loadable(lazy(() => import('views/landing/price')));
const PrivacyPolicy = Loadable(lazy(() => import('views/landing/PrivacyPolicy')));
const CGU = Loadable(lazy(() => import('views/landing/CGU')));
const FAQ = Loadable(lazy(() => import('views/landing/Faqs')));
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
        },
        {
            path: '/cgu',
            element: <CGU />
        },
        {
            path: '/privacy-policy',
            element: <PrivacyPolicy />
        },
        {
            path: '/faq',
            element: <FAQ />
        }
    ]
};

export default LandingRoutes;
