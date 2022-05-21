import MainCard from 'ui-component/cards/MainCard';
// material-ui
import { Box, Grid, Typography } from '@mui/material';

const Chat = ({ ...others }) => (
    <MainCard>
        <Grid item xs={12} container alignItems="center" justifyContent="center">
            <Box sx={{ mb: 2 }}>
                <Typography variant="subtitle1">Messagerie</Typography>
            </Box>
        </Grid>
    </MainCard>
);

export default Chat;
