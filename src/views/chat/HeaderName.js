import { Grid, Typography } from '@mui/material';
import useAuth from 'hooks/useAuth';
import Avatar from 'ui-component/extended/Avatar';
import AvatarStatus from './AvatarStatus';

const { useFirestoreDocumentData } = require('@react-query-firebase/firestore');
const { doc } = require('firebase/firestore');

const HeaderName = ({ lastOpen, userData }) => {
    console.log(userData);
    return (
        <Grid item>
            <Grid container spacing={2} alignItems="center" sx={{ flexWrap: 'nowrap' }}>
                <Grid item>
                    <Avatar alt={lastOpen} src={lastOpen} />
                </Grid>
                <Grid item sm zeroMinWidth>
                    <Grid container spacing={0} alignItems="center">
                        <Grid item xs={12}>
                            <Typography variant="h4" component="div">
                                {lastOpen}
                                {lastOpen && <AvatarStatus status={lastOpen} />}
                            </Typography>
                        </Grid>
                        {/* <Grid item xs={12}>
                    <Typography variant="subtitle2">Dernière connexion {data.lastMessage}</Typography>
                </Grid> */}
                    </Grid>
                </Grid>
            </Grid>
        </Grid>
    );
    // const { db } = useAuth();
    // console.log(lastOpen);
    // const ref = doc(db, 'users', lastOpen);
    // const userData = useFirestoreDocumentData(['users', lastOpen], ref);

    // return userData.isSuccess ? (
    //     <Grid item>
    //         <Grid container spacing={2} alignItems="center" sx={{ flexWrap: 'nowrap' }}>
    //             <Grid item>
    //                 <Avatar alt={userData.fname + userData.lname} src={userData.imgUrl} />
    //             </Grid>
    //             <Grid item sm zeroMinWidth>
    //                 <Grid container spacing={0} alignItems="center">
    //                     <Grid item xs={12}>
    //                         <Typography variant="h4" component="div">
    //                             {userData.fname} {userData.lname}
    //                             {userData.online_status && <AvatarStatus status={userData.online_status} />}
    //                         </Typography>
    //                     </Grid>
    //                     {/* <Grid item xs={12}>
    //                         <Typography variant="subtitle2">Dernière connexion {data.lastMessage}</Typography>
    //                     </Grid> */}
    //                 </Grid>
    //             </Grid>
    //         </Grid>
    //     </Grid>
    // ) : (
    //     <div>Chargement</div>
    // );
};
export default HeaderName;
