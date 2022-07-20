// material-ui
import { useTheme, styled } from '@mui/material/styles';
import { Container, Grid, Link, Typography } from '@mui/material';

// project imports
import { gridSpacing } from 'store/constant';

// assets
import FacebookIcon from '@mui/icons-material/Facebook';
import InstagramIcon from '@mui/icons-material/Instagram';

import logoDark from 'assets/images/logo.svg';

// styles
const FooterWrapper = styled('div')(({ theme }) => ({
    padding: '35px 0',
    color: '#fff',
    background: theme.palette.secondary.secondaryLight,
    [theme.breakpoints.down('md')]: {
        textAlign: 'center'
    }
}));

const FooterLink = styled(Link)({
    color: '#000',
    display: 'inline-flex',
    alignItems: 'center',
    textDecoration: 'none !important',
    opacity: '0.8',
    '& svg': {
        fontsize: '1.125rem',
        marginRight: 8
    },
    '&:hover': {
        opacity: '1'
    }
});

const FooterSubWrapper = styled('div')(({ theme }) => ({
    padding: '20px 0',
    color: '#000',
    background: theme.palette.secondary.secondaryLight,
    [theme.breakpoints.down('md')]: {
        textAlign: 'center'
    }
}));

// ==============================|| LANDING - FOOTER PAGE ||============================== //

const FooterPage = () => {
    const theme = useTheme();
    return (
        <>
            <FooterWrapper>
                <Container>
                    <Grid container alignItems="center" spacing={gridSpacing}>
                        <Grid item xs={12} sm={4}>
                            <img src={logoDark} alt="Buy&Bye" width="100" />
                        </Grid>
                        <Grid item xs={12} sm={8}>
                            <Grid
                                container
                                alignItems="center"
                                spacing={2}
                                sx={{ justifyContent: 'flex-end', [theme.breakpoints.down('md')]: { justifyContent: 'center' } }}
                            >
                                <Grid item>
                                    <FooterLink href="https://instagram.fr/" target="_blank" underline="hover">
                                        <InstagramIcon />
                                        Instagram
                                    </FooterLink>
                                </Grid>
                                <Grid item>
                                    <FooterLink href="https://www.facebook.com/" target="_blank" underline="hover">
                                        <FacebookIcon />
                                        Facebook
                                    </FooterLink>
                                </Grid>
                            </Grid>
                        </Grid>
                    </Grid>
                </Container>
            </FooterWrapper>
            <FooterSubWrapper>
                <Container>
                    <Grid container alignItems="center" spacing={gridSpacing}>
                        <Grid item>
                            <FooterLink href="/cgu" target="_blank" underline="hover">
                                CGU
                            </FooterLink>
                        </Grid>
                        <Grid item>
                            <FooterLink href="/privacy-policy" target="_blank" underline="hover">
                                Politique de confidentialité
                            </FooterLink>
                        </Grid>
                    </Grid>
                </Container>
            </FooterSubWrapper>
        </>
    );
};

export default FooterPage;
