import React from 'react';
import { Link } from 'react-router-dom';

// material-ui
import { useTheme } from '@mui/material/styles';
import {
    Button,
    Card,
    CardContent,
    Container,
    FormControl,
    Grid,
    InputLabel,
    MenuItem,
    OutlinedInput,
    TextField,
    Typography
} from '@mui/material';

// third-party
import NumberFormat from 'react-number-format';

// project imports
import AnimateButton from 'ui-component/extended/AnimateButton';
import { gridSpacing } from 'store/constant';

// assets
import mailImg from 'assets/images/landing/img-contact-mail.svg';

// ===========================|| CONTACT CARD - FORMS ||=========================== //

const ContactCard = () => {
    const theme = useTheme();

    return (
        <Container>
            <Grid container justifyContent="center" spacing={gridSpacing}>
                <Grid item sm={10} md={7} sx={{ mt: { md: 12.5, xs: 2.5 }, mb: { md: 12.5, xs: 2.5 } }}>
                    <Grid container spacing={gridSpacing}>
                        <Grid item xs={12}>
                            <Typography
                                variant="h1"
                                color="white"
                                component="div"
                                sx={{
                                    fontSize: '3.5rem',
                                    fontWeight: 900,
                                    lineHeight: 1.4,
                                    [theme.breakpoints.down('md')]: { fontSize: '1.8125rem', marginTop: '80px' }
                                }}
                            >
                                Contactez-nous !
                            </Typography>
                        </Grid>
                        <Grid item xs={12}>
                            <Typography
                                variant="h4"
                                component="div"
                                sx={{ fontWeight: 400, lineHeight: 1.4, [theme.breakpoints.up('md')]: { my: 0, mx: 12.5 } }}
                                color="white"
                            >
                                Vous hésitez à nous rejoindre ? N&apos;hésitez pas alors à nous contacter pour en savoir davantage !
                            </Typography>
                        </Grid>
                    </Grid>
                </Grid>
                <Grid item xs={12} sx={{ position: 'relative', display: { xs: 'none', lg: 'block' } }}>
                    <img
                        src={mailImg}
                        alt="Berry"
                        style={{
                            marginBottom: -0.625,
                            position: 'absolute',
                            bottom: -90,
                            right: '0',
                            width: 400,
                            maxWidth: '100%',
                            animation: '5s wings ease-in-out infinite'
                        }}
                    />
                </Grid>
                <Grid item xs={10} sx={{ mb: -37.5 }}>
                    <Card sx={{ mb: 6.25 }} elevation={4}>
                        <CardContent sx={{ p: 4 }}>
                            <Grid container spacing={gridSpacing}>
                                <Grid item xs={12} sm={6}>
                                    <FormControl fullWidth>
                                        <InputLabel>Nom</InputLabel>
                                        <OutlinedInput type="text" label="Name" />
                                    </FormControl>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <FormControl fullWidth>
                                        <InputLabel>Nom de l&apos;entreprise</InputLabel>
                                        <OutlinedInput type="text" label="Company Name" />
                                    </FormControl>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <FormControl fullWidth>
                                        <InputLabel>Adresse Email</InputLabel>
                                        <OutlinedInput type="text" label="Email Address" />
                                    </FormControl>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <FormControl fullWidth>
                                        <NumberFormat
                                            format="+1 (###) ###-####"
                                            mask="_"
                                            fullWidth
                                            customInput={TextField}
                                            label="Numéro de téléphone"
                                        />
                                    </FormControl>
                                </Grid>
                                {/* <Grid item xs={12} sm={6}>
                                    <FormControl fullWidth sx={{ textAlign: 'left' }}>
                                        <TextField
                                            id="outlined-select-Size"
                                            select
                                            fullWidth
                                            label="Company Size"
                                            value={size}
                                            onChange={handleChange1}
                                        >
                                            {sizes.map((option, index) => (
                                                <MenuItem key={index} value={option.value}>
                                                    {option.label}
                                                </MenuItem>
                                            ))}
                                        </TextField>
                                    </FormControl>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                    <FormControl fullWidth sx={{ textAlign: 'left' }}>
                                        <TextField
                                            id="outlined-select-budget"
                                            select
                                            fullWidth
                                            label="Project Budget"
                                            value={budget}
                                            onChange={handleChange}
                                        >
                                            {currencies.map((option, index) => (
                                                <MenuItem key={index} value={option.value}>
                                                    {option.label}
                                                </MenuItem>
                                            ))}
                                        </TextField>
                                    </FormControl>
                                </Grid> */}
                                <Grid item xs={12}>
                                    <FormControl fullWidth>
                                        <TextField
                                            id="outlined-multiline-static1"
                                            placeholder="Message"
                                            multiline
                                            fullWidth
                                            rows={4}
                                            defaultValue=""
                                        />
                                    </FormControl>
                                </Grid>
                                <Grid item xs={12}>
                                    <Grid container spacing={gridSpacing}>
                                        <Grid item sm zeroMinWidth>
                                            <Typography align="left" variant="body2">
                                                En envoyant ce formulaire, vous acceptez par défaut notre
                                                <Typography variant="subtitle1" component={Link} to="#" color="primary" sx={{ mx: 0.5 }}>
                                                    Politique de Confidentialité
                                                </Typography>
                                                ainsi que la manière de traiter
                                                <Typography variant="subtitle1" component={Link} to="#" color="primary" sx={{ ml: 0.5 }}>
                                                    vos données personnelles.
                                                </Typography>
                                            </Typography>
                                        </Grid>
                                        <Grid item>
                                            <AnimateButton>
                                                <Button variant="contained" color="secondary">
                                                    Envoyer
                                                </Button>
                                            </AnimateButton>
                                        </Grid>
                                    </Grid>
                                </Grid>
                            </Grid>
                        </CardContent>
                    </Card>
                </Grid>
            </Grid>
        </Container>
    );
};

export default ContactCard;
