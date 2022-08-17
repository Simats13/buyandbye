// material-ui
import { Avatar, Button, Grid, Stack, TextField, Typography } from '@mui/material';

// project imports
import useAuth from 'hooks/useAuth';
import SubCard from 'ui-component/cards/SubCard';
import AnimateButton from 'ui-component/extended/AnimateButton';
import { gridSpacing } from 'store/constant';

// assets
// import Avatar1 from 'assets/images/users/avatar-1.png';
import Avatar1 from 'assets/images/users/avatar-1.png';

// ==============================|| PROFILE 3 - PROFILE ||============================== //

const Profile = () => {
    const { user } = useAuth();

    return (
        <Grid container spacing={gridSpacing}>
            <Grid item sm={6} md={4}>
                <SubCard title="Image de profil" contentSX={{ textAlign: 'center' }}>
                    <Grid container spacing={2}>
                        <Grid item xs={12}>
                            <Avatar alt="User 1" src={Avatar1} sx={{ width: 100, height: 100, margin: '0 auto' }} />
                        </Grid>
                        <Grid item xs={12}>
                            <Typography variant="subtitle2" align="center">
                                Changer la photo de profil
                            </Typography>
                        </Grid>
                        <Grid item xs={12}>
                            <AnimateButton>
                                <Button variant="contained" size="small">
                                    Téléverser une image
                                </Button>
                            </AnimateButton>
                        </Grid>
                    </Grid>
                </SubCard>
            </Grid>
            <Grid item sm={6} md={8}>
                <SubCard title="Changer les informations du compte">
                    <Grid container spacing={gridSpacing}>
                        <Grid item xs={12}>
                            <TextField id="outlined-basic1" fullWidth label="Nom" defaultValue={user?.name} helperText="Helper text" />
                        </Grid>
                        <Grid item xs={12}>
                            <TextField id="outlined-basic6" fullWidth label="Adresse Email" defaultValue={user?.email} />
                        </Grid>
                        <Grid item md={6} xs={12}>
                            <TextField id="outlined-basic4" fullWidth label="Entreprise" defaultValue="Buy&Bye" />
                        </Grid>
                        <Grid item md={6} xs={12}>
                            <TextField id="outlined-basic5" fullWidth label="Pays" defaultValue="FR" />
                        </Grid>
                        <Grid item md={6} xs={12}>
                            <TextField id="outlined-basic7" fullWidth label="Numéro de téléphone" defaultValue="0606060606 " />
                        </Grid>
                        <Grid item md={6} xs={12}>
                            <TextField id="outlined-basic8" fullWidth label="Anniversaire" defaultValue="31/01/2001" />
                        </Grid>
                        <Grid item xs={12}>
                            <Stack direction="row">
                                <AnimateButton>
                                    <Button variant="contained">Changer les informations</Button>
                                </AnimateButton>
                            </Stack>
                        </Grid>
                    </Grid>
                </SubCard>
            </Grid>
        </Grid>
    );
};

export default Profile;
