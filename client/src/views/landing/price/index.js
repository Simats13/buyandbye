// material-ui
import { styled } from '@mui/material/styles';

// project imports
import Price1 from './Price1';
import AppBar from 'ui-component/extended/AppBar';

// assets
import headerBackground from 'assets/images/landing/header-bg.jpg';

const HeaderWrapper = styled('div')(({ theme }) => ({
    backgroundImage: `url(${headerBackground})`,
    backgroundSize: '100% 600px',
    backgroundAttachment: 'fixed',
    backgroundRepeat: 'no-repeat',
    textAlign: 'center',
    paddingTop: 30,
    [theme.breakpoints.down('md')]: {
        paddingTop: 0
    }
}));

// ============================|| CONTACT US MAIN ||============================ //

const PricePage = () => (
    <HeaderWrapper>
        <AppBar />
        <Price1 />
    </HeaderWrapper>
);

export default PricePage;
