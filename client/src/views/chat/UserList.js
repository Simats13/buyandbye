import PropTypes from 'prop-types';
import React, { useEffect, useState, Fragment } from 'react';

// material-ui
import { Chip, Divider, Grid, List, ListItemButton, ListItemAvatar, ListItemText, Typography } from '@mui/material';

import { query, collection, where, limit, QuerySnapshot, doc, orderBy } from 'firebase/firestore';
import { useFirestoreDocument, useFirestoreQuery, useFirestoreQueryData } from '@react-query-firebase/firestore';
// project imports
import UserAvatar from './UserAvatar';

import { useDispatch, useSelector } from 'store';
import { getUsers, getAllUserChats, getUserWithID } from 'store/slices/chat';
import useAuth from 'hooks/useAuth';

// ==============================|| CHAT USER LIST ||============================== //

const UserList = ({ setUserData, sellerID }) => {
    const dispatch = useDispatch();
    const [client, setClient] = useState([]);
    const [userInfo, setUserInfo] = useState([]);
    const { users } = useSelector((state) => state.chat);
    const { db, user } = useAuth();
    const ref = query(collection(db, 'commonData'), where('users', 'array-contains', sellerID), orderBy('timestamp', 'desc'));

    const queryClient = useFirestoreQueryData(['commonData'], ref, { subscribe: true });

    useEffect(() => {
        dispatch(getUsers(sellerID));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    // useEffect(() => {
    //     setUserInfo(users);
    // }, [users]);

    // console.log(userTestInfo);
    useEffect(() => {
        setClient(queryClient);
    }, []);

    if (queryClient.isLoading) {
        return <div>Loading...</div>;
    }
    queryClient.data.map((data) => setUserInfo(doc(db, 'users', data.users[1])));
    if (queryClient.isLoading) {
        return <div>Loading...</div>;
    }
    console.log(userInfo);

    // eslint-disable-next-line no-unused-expressions
    return (
        <List component="nav">
            {queryClient.data.map((userSelect) => (
                <Fragment key={sellerID + userSelect.id}>
                    <ListItemButton
                        onClick={() => {
                            dispatch(getAllUserChats(sellerID + userSelect.users[1]));
                            dispatch(getUserWithID(userSelect.users[1]));
                        }}
                    >
                        <ListItemAvatar>
                            <UserAvatar user={userSelect} />
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
                                            {`${user.name}`}
                                        </Typography>
                                    </Grid>
                                    <Grid item component="span">
                                        <Typography component="span" variant="subtitle2">
                                            {
                                                // eslint-disable-next-line no-underscore-dangle
                                                new Date(userSelect.timestamp.seconds * 1000).toLocaleString()
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
                                            {userSelect.lastMessage}
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
                    </ListItemButton>
                    <Divider />
                </Fragment>
            ))}
        </List>
    );
};

UserList.propTypes = {
    setUserData: PropTypes.func
};

export default UserList;
