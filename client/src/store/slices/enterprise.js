// third-party
import { createSlice } from '@reduxjs/toolkit';

// project imports
import axios from 'utils/axios';
import { dispatch } from '../index';

// ----------------------------------------------------------------------

const initialState = {
    error: null,
    enterprise: [],
    infoEnterprise: {}
};

const slice = createSlice({
    name: 'enterprise',
    initialState,
    reducers: {
        // HAS ERROR
        hasError(state, action) {
            state.error = action.payload;
        },

        // GET ENTERPRISE INFOS
        getEnterpriseSuccess(state, action) {
            state.enterprise = action.payload;
        },

        editEnterpriseInfoSuccess(state, action) {
            state.infoEnterprise = action.payload;
        }
    }
});

// Reducer
export default slice.reducer;

// ----------------------------------------------------------------------

export function getEnterprise(id) {
    return async () => {
        try {
            const response = await axios.get(`${process.env.REACT_APP_API_URL}/api/shops/${id}/`);
            dispatch(slice.actions.getEnterpriseSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}

export function editEnterpriseInfo(id, data, formData) {
    return async () => {
        try {
            const response = await axios.post(`${process.env.REACT_APP_API_URL}/api/shops/${id}/`, formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            dispatch(slice.actions.editEnterpriseInfoSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}
