import MainCard from 'ui-component/cards/MainCard';
// material-ui
import { Box, Grid, Typography } from '@mui/material';

const Commands = ({ ...others }) => (
    <MainCard>
        <Grid item xs={12} container alignItems="center" justifyContent="center">
            <Box sx={{ mb: 2 }}>
                <Typography variant="subtitle1">Gestion des commandes</Typography>
            </Box>
        </Grid>
    </MainCard>
);

export default Commands;
