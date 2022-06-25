// material-ui
import { styled } from '@mui/material/styles';

// project imports
import Header from './Header';
import Feature from './Feature';
import Layouts from './Layouts';
import KeyFeature from './KeyFeature';
import Subscribe from './Subscribe';
import Footer from './Footer';
import Customization from 'layout/Customization';
import AppBar from 'ui-component/extended/AppBar';
import Price1 from './price/Price1';

const HeaderWrapper = styled('div')(({ theme }) => ({
    paddingTop: 30,
    overflowX: 'hidden',
    overflowY: 'clip',
    [theme.breakpoints.down('md')]: {
        paddingTop: 42
    }
}));

const SecondWrapper = styled('div')(({ theme }) => ({
    paddingTop: 160,
    [theme.breakpoints.down('md')]: {
        paddingTop: 60
    }
}));

// =============================|| LANDING MAIN ||============================= //

const Landing = () => (
    <>
        <HeaderWrapper id="home">
            <AppBar />
            <Header />
        </HeaderWrapper>
        <SecondWrapper>
            <Feature />
        </SecondWrapper>
        {/* <SecondWrapper>
            <Demos />
        </SecondWrapper> */}
        <SecondWrapper>
            <Layouts />
        </SecondWrapper>
        {/* <SecondWrapper>
            <KeyFeature />
        </SecondWrapper> */}
        <SecondWrapper>
            <Price1 />
        </SecondWrapper>
        <SecondWrapper>
            <Subscribe />
        </SecondWrapper>
        <Footer />
    </>
);

export default Landing;
