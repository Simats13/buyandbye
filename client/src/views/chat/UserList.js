import PropTypes from 'prop-types';
import React, { useEffect, useState, Fragment } from 'react';

// material-ui
import { Chip, Divider, Grid, List, ListItemButton, ListItemAvatar, ListItemText, Typography } from '@mui/material';

import { query, collection, where, limit, QuerySnapshot, doc, orderBy } from 'firebase/firestore';
import { useFirestoreDocumentData, useFirestoreQuery, useFirestoreQueryData } from '@react-query-firebase/firestore';
// project imports
import UserAvatar from './UserAvatar';

import { useDispatch, useSelector } from 'store';
import { getUsers, getAllUserChats, getUserWithID } from 'store/slices/chat';
import useAuth from 'hooks/useAuth';

// ==============================|| CHAT USER LIST ||============================== //

const UserList = ({ setUserData, userInfo, data, sellerID, setLastOpen }) => {
    const dispatch = useDispatch();
    const [client, setClient] = useState([]);

    const { db } = useAuth();

    const Test = ({ userID, messageData }) => {
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
                                        new Date(messageData.timestamp.seconds * 1000).toLocaleString()
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

    // eslint-disable-next-line no-unused-expressions
    return (
        <List component="nav">
            {data.map((userSelect, index) => (
                <>
                    <Fragment key={sellerID + userSelect.users[1]}>
                        <ListItemButton
                            onClick={() => {
                                setLastOpen(userSelect.users[1]);
                            }}
                        >
                            <Test userID={userSelect.users[1]} messageData={userSelect} />
                        </ListItemButton>
                        <Divider />
                    </Fragment>
                </>
            ))}
        </List>
    );
};

UserList.propTypes = {
    setUserData: PropTypes.func
};

export default UserList;
