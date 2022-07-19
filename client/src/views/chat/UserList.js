import PropTypes from 'prop-types';
import { Fragment } from 'react';

// material-ui
import { Divider, Grid, List, ListItemButton, ListItemAvatar, ListItemText, Typography } from '@mui/material';

import { doc } from 'firebase/firestore';
import { useFirestoreDocumentData } from '@react-query-firebase/firestore';
// project imports
import UserAvatar from './UserAvatar';

// import { useDispatch, useSelector } from 'store';
// import { getUsers, getAllUserChats, getUserWithID } from 'store/slices/chat';
import useAuth from 'hooks/useAuth';

// ==============================|| CHAT USER LIST ||============================== //

const UserList = ({ data, sellerID, setLastOpen }) => {
    const { db } = useAuth();

    const UserListInfo = ({ userID, messageData }) => {
        const ref = doc(db, 'users', userID);
        const userInfos = useFirestoreDocumentData(['users', userID], ref);
        return userInfos.isSuccess ? (
            <>
                <ListItemAvatar>
                    <UserAvatar user={userInfos.data} />
                </ListItemAvatar>
                <ListItemText
                    primary={
                        <Grid container alignItems="center" spacing={1} component="span">
                            <Grid item xs zeroMinWidth component="span">
                                <Typography
                                    variant="h5"
                                    color="inherit"
                                    component="span"
                                    sx={{
                                        overflow: 'hidden',
                                        textOverflow: 'ellipsis',
                                        whiteSpace: 'nowrap',
                                        display: 'block'
                                    }}
                                >
                                    {`${userInfos.data.fname} ${userInfos.data.lname}`}
                                </Typography>
                            </Grid>
                            <Grid item component="span">
                                <Typography component="span" variant="subtitle2">
                                    {
                                        // eslint-disable-next-line no-underscore-dangle
                                        new Date(messageData.timestamp.seconds * 1000).toLocaleTimeString(navigator.language, {
                                            hour: '2-digit',
                                            minute: '2-digit',
                                            day: '2-digit',
                                            month: '2-digit'
                                        })
                                    }
                                </Typography>
                            </Grid>
                        </Grid>
                    }
                    secondary={
                        <Grid container alignItems="center" spacing={1} component="span">
                            <Grid item xs zeroMinWidth component="span">
                                <Typography
                                    variant="caption"
                                    component="span"
                                    sx={{
                                        overflow: 'hidden',
                                        textOverflow: 'ellipsis',
                                        whiteSpace: 'nowrap',
                                        display: 'block'
                                    }}
                                >
                                    {messageData.lastMessage}
                                </Typography>
                            </Grid>
                            {/* <Grid item component="span">
            {user.unReadChatCount !== 0 && (
                <Chip
                    label={user.unReadChatCount}
                    component="span"
                    color="secondary"
                    sx={{
                        width: 20,
                        height: 20,
                        '& .MuiChip-label': {
                            px: 0.5
                        }
                    }}
                />
            )}
        </Grid> */}
                        </Grid>
                    }
                />
            </>
        ) : (
            <div>Chargement des utilisateurs</div>
        );
    };

    UserListInfo.propTypes = {
        userID: PropTypes.string.isRequired,
        messageData: PropTypes.object.isRequired
    };

    // eslint-disable-next-line no-unused-expressions
    return (
        <List component="nav">
            {data.map((userSelect, index) => (
                <>
                    <ListItemButton
                        key={index + 1}
                        onClick={() => {
                            setLastOpen(userSelect.users[1]);
                        }}
                    >
                        <UserListInfo key={index} userID={userSelect.users[1]} messageData={userSelect} />
                    </ListItemButton>
                    <Divider />
                </>
            ))}
        </List>
    );
};

UserList.propTypes = {
    data: PropTypes.array,
    sellerID: PropTypes.string,
    setLastOpen: PropTypes.func
};

export default UserList;
