// third-party
import { createSlice } from '@reduxjs/toolkit';

// project imports
import axios from 'utils/axios';
import { dispatch } from '../index';

// ----------------------------------------------------------------------

const initialState = {
    error: null,
    chats: [],
    users: [],
    userInfo: []
};

const slice = createSlice({
    name: 'chat',
    initialState,
    reducers: {
        // HAS ERROR
        hasError(state, action) {
            state.error = action.payload;
        },

        // GET USER
        getUsersSuccess(state, action) {
            state.users = action.payload;
        },

        // GET USER CHATS
        getUserChatsSuccess(state, action) {
            state.chats = action.payload;
        },

        // GET USER
        getUserSuccess(state, action) {
            state.userInfo = action.payload;
        }
    }
});

// Reducer
export default slice.reducer;

// ----------------------------------------------------------------------

export function getUsers(id) {
    return async () => {
        try {
            const response = await axios.get(`/api/chat/user/${id}/users`);
            dispatch(slice.actions.getUsersSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}

export function getUserWithID(id) {
    return async () => {
        try {
            const response = await axios.get(`/api/users/${id}/`);
            dispatch(slice.actions.getUserSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}

export function getAllUserChats(id) {
    return async () => {
        try {
            const response = await axios.get(`/api/chat/user/${id}/messages`);
            dispatch(slice.actions.getUserChatsSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}

export function getLatestChat(id) {
    return async () => {
        try {
            const response = await axios.get(`/api/chat/user/${id}/messages/latest`);
            dispatch(slice.actions.getUserChatsSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}
export function insertChat(chat, idConv) {
    return async () => {
        try {
            await axios.post(`/api/chat/${idConv}`, chat);
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}
