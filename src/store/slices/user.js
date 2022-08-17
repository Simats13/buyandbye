// third-party
import { createSlice } from '@reduxjs/toolkit';

// project imports
import axios from 'utils/axios';
import { dispatch } from '../index';

// ----------------------------------------------------------------------

const initialState = {
    error: null,
    userWithID: []
};

const slice = createSlice({
    name: 'user',
    initialState,
    reducers: {
        // HAS ERROR
        hasError(state, action) {
            state.error = action.payload;
        },

        // GET USER VIA ID
        getUserViaIDSuccess(state, action) {
            state.userWithID = action.payload;
        }
    }
});

// Reducer
export default slice.reducer;

// ----------------------------------------------------------------------

export function getUserWithID(id) {
    return async () => {
        try {
            const response = await axios.get(`${process.env.REACT_APP_API_URL}/api/users/${id}`);
            dispatch(slice.actions.getUserViaIDSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}
