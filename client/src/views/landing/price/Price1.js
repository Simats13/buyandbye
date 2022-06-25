import React from 'react';

// material-ui
import { useTheme } from '@mui/material/styles';
import { Box, Button, Container, Divider, Grid, List, ListItem, ListItemIcon, ListItemText, Typography } from '@mui/material';

// project imports
import MainCard from 'ui-component/cards/MainCard';
import { gridSpacing } from 'store/constant';

// assets
import CheckTwoToneIcon from '@mui/icons-material/CheckTwoTone';
import TwoWheelerTwoToneIcon from '@mui/icons-material/TwoWheelerTwoTone';
import AirportShuttleTwoToneIcon from '@mui/icons-material/AirportShuttleTwoTone';
import DirectionsBoatTwoToneIcon from '@mui/icons-material/DirectionsBoatTwoTone';

const plans = [
    {
        active: false,
        icon: <TwoWheelerTwoToneIcon fontSize="large" color="inherit" />,
        title: 'Basique',
        description:
            "Créer votre page entreprise facilement en deux trois clics via l'offre Basique, cette offre vous permet de découvrir l'application sans débourser le moindre centime !",
        price: 0,
        permission: [0, 1]
    },
    {
        active: true,
        icon: <AirportShuttleTwoToneIcon fontSize="large" />,
        title: 'Premium',
        description:
            "Créer votre page entreprise facilement en deux trois clics via l'offre Premium,cette offre vous permet de personnaliser votre page de manière significative, également vous ferez l'objet d'une mise en avant auprès des utilisateurs de l'application et tout un tas de fonctionnalités supplémentaires.",
        price: 20,
        permission: [0, 1, 2, 3, 4, 5, 6]
    }
];

const planList = [
    'Création de la page entreprise', // 0
    "Upload d'une bannière", // 1
    'Choix des couleurs plus poussées', // 2
    "Mise en avant sur l'application", // 3
    'Plus de personnalisation', // 4
    'Graphiques plus détaillés', // 5
    'Support amélioré'
];

// ===============================|| PRICING - PRICE 1 ||=============================== //

const Price1 = () => {
    const theme = useTheme();
    const priceListDisable = {
        opacity: '0.4',
        '& >div> svg': {
            fill: theme.palette.secondary.light
        }
    };
    return (
        <>
            <Container>
                <Grid container spacing={gridSpacing}>
                    <Grid item xs={12} lg={5} md={10}>
                        <Grid container spacing={2} sx={{ mb: 2 }}>
                            <Grid item xs={12}>
                                <Grid container spacing={1}>
                                    <Grid item>
                                        <Typography variant="h5" color="primary">
                                            Buy&Bye
                                        </Typography>
                                    </Grid>
                                </Grid>
                            </Grid>
                            <Grid item xs={12}>
                                <Typography variant="h2" component="div">
                                    Découvrir nos offres
                                </Typography>
                            </Grid>
                            <Grid item xs={12}>
                                <Typography variant="body2">Nous proposons divers offres qui sauront vous ravir !</Typography>
                            </Grid>
                        </Grid>
                    </Grid>
                </Grid>
            </Container>
            <Grid container spacing={gridSpacing} direction="row" alignItems="center" justifyContent="center">
                {plans.map((plan, index) => {
                    const darkBorder = theme.palette.mode === 'dark' ? theme.palette.background.default : theme.palette.primary[200] + 75;
                    return (
                        <Grid item justifyContent="center" xs={3} sm={3} md={3} key={index}>
                            <MainCard
                                boxShadow
                                sx={{
                                    margin: '0 auto',
                                    pt: 1.75,
                                    border: plan.active ? '2px solid' : '1px solid',
                                    borderColor: plan.active ? 'secondary.main' : darkBorder
                                }}
                            >
                                <Grid container textAlign="center" spacing={gridSpacing}>
                                    <Grid item xs={12}>
                                        <Box
                                            sx={{
                                                display: 'inline-flex',
                                                alignItems: 'center',
                                                justifyContent: 'center',
                                                borderRadius: '50%',
                                                width: 80,
                                                height: 80,
                                                background:
                                                    theme.palette.mode === 'dark' ? theme.palette.dark[800] : theme.palette.primary.light,
                                                color: theme.palette.primary.main,
                                                '& > svg': {
                                                    width: 35,
                                                    height: 35
                                                }
                                            }}
                                        >
                                            {plan.icon}
                                        </Box>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Typography
                                            variant="h6"
                                            sx={{
                                                fontSize: '1.5625rem',
                                                fontWeight: 500,
                                                position: 'relative',
                                                mb: 1.875,
                                                '&:after': {
                                                    content: '""',
                                                    position: 'absolute',
                                                    bottom: -15,
                                                    left: 'calc(50% - 25px)',
                                                    width: 50,
                                                    height: 4,
                                                    background: theme.palette.primary.main,
                                                    borderRadius: '3px'
                                                }
                                            }}
                                        >
                                            {plan.title}
                                        </Typography>
                                    </Grid>
                                    {/* <Grid item xs={12}>
                                    <Typography variant="body2">{plan.description}</Typography>
                                </Grid> */}
                                    <Grid item xs={12}>
                                        <Typography
                                            component="div"
                                            variant="body2"
                                            sx={{
                                                fontSize: '2.1875rem',
                                                fontWeight: 700,
                                                '& > span': {
                                                    fontSize: '1.25rem',
                                                    fontWeight: 500
                                                }
                                            }}
                                        >
                                            {plan.price}
                                            <sup>€</sup>
                                            <span>/mois</span>
                                        </Typography>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <List
                                            sx={{
                                                m: 0,
                                                p: 0,
                                                '&> li': {
                                                    px: 0,
                                                    py: 0.625,
                                                    '& svg': {
                                                        fill: theme.palette.success.dark
                                                    }
                                                }
                                            }}
                                            component="ul"
                                        >
                                            {planList.map((list, i) => (
                                                <React.Fragment key={i}>
                                                    <ListItem sx={!plan.permission.includes(i) ? priceListDisable : {}}>
                                                        <ListItemIcon>
                                                            <CheckTwoToneIcon sx={{ fontSize: '1.3rem' }} />
                                                        </ListItemIcon>
                                                        <ListItemText primary={list} />
                                                    </ListItem>
                                                    <Divider />
                                                </React.Fragment>
                                            ))}
                                        </List>
                                    </Grid>
                                    <Grid item xs={12}>
                                        <Button variant="outlined">Choisir cette option</Button>
                                    </Grid>
                                </Grid>
                            </MainCard>
                        </Grid>
                    );
                })}
            </Grid>
        </>
    );
};

export default Price1;
