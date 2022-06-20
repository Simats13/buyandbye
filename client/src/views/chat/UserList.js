import PropTypes from 'prop-types';
import { useEffect, useState, Fragment } from 'react';

// material-ui
import { Chip, Divider, Grid, List, ListItemButton, ListItemAvatar, ListItemText, Typography } from '@mui/material';

// project imports
import UserAvatar from './UserAvatar';

import { useDispatch, useSelector } from 'store';
import { getUsers } from 'store/slices/chat';

// ==============================|| CHAT USER LIST ||============================== //

const UserList = ({ setUser, conversations }) => {
    const dispatch = useDispatch();
    const [data, setData] = useState([]);
    const { users } = useSelector((state) => state.chat);
    const usersAndMessages = [];

    useEffect(() => {
        dispatch(getUsers(setUser));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    useEffect(() => {
        setData(users);
    }, [users]);

    // eslint-disable-next-line no-unused-expressions
    console.log(!!data.includes('KkyhBb5pD2WBNkbw98U98rGOdCt2'));

    return (
        <List component="nav">
            {conversations.map((user) => (
                <Fragment key={user.id}>
                    <ListItemButton
                        onClick={() => {
                            setUser(user);
                        }}
                    >
                        <ListItemAvatar>
                            <UserAvatar user={user} />
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
                                            {`${user.fname} ${user.lname}`}
                                        </Typography>
                                    </Grid>
                                    <Grid item component="span">
                                        <Typography component="span" variant="subtitle2">
                                            {user.lastMessage}
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
                                            {user.lastMessage}
                                        </Typography>
                                    </Grid>
                                    <Grid item component="span">
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
                                    </Grid>
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
    setUser: PropTypes.func,
    conversations: PropTypes.array
};

export default UserList;
