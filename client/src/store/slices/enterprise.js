// third-party
import { createSlice } from '@reduxjs/toolkit';

// project imports
import axios from 'utils/axios';
import { dispatch } from '../index';

// ----------------------------------------------------------------------

const initialState = {
    error: null,
    enterprise: []
};

const slice = createSlice({
    name: 'enterprise',
    initialState,
    reducers: {
        // HAS ERROR
        hasError(state, action) {
            state.error = action.payload;
        },

        // GET PRODUCTS
        getEnterpriseSuccess(state, action) {
            state.enterprise = action.payload;
        }
    }
});

// Reducer
export default slice.reducer;

// ----------------------------------------------------------------------

export function getEnterprise(id) {
    return async () => {
        try {
            const response = await axios.get(`/api/shops/${id}/`);
            dispatch(slice.actions.getEnterpriseSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}
