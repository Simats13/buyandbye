// third-party
import { createSlice } from '@reduxjs/toolkit';

// project imports
import axios from 'utils/axios';
import { dispatch } from '../index';

// ----------------------------------------------------------------------

const initialState = {
    error: null,
    products: [],
    product: null,
    delete: null,
    add: null,
    edit: null
};

const slice = createSlice({
    name: 'product',
    initialState,
    reducers: {
        // HAS ERROR
        hasError(state, action) {
            state.error = action.payload;
        },

        getDeleteSuccess(state, action) {
            state.delete = action.payload;
        },

        getAddSuccess(state, action) {
            state.add = action.payload;
        },

        getEditSuccess(state, action) {
            state.edit = action.payload;
        }
    }
});

// Reducer
export default slice.reducer;

// ----------------------------------------------------------------------

export function getProducts(id) {
    return async () => {
        try {
            const response = await axios.get(`${process.env.REACT_APP_API_URL}/api/shops/${id}/products`);
            dispatch(slice.actions.getProductsSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}

export function deleteProducts(id, idProduct) {
    return async () => {
        try {
            const response = await axios.delete(`${process.env.REACT_APP_API_URL}/api/shops/${id}/products/${idProduct}`);
            dispatch(slice.actions.getDeleteSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}

export function addProducts(id, data) {
    return async () => {
        try {
            const response = await axios.post(`${process.env.REACT_APP_API_URL}/api/shops/${id}/products`, data, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            dispatch(slice.actions.getAddSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}

export function editProducts(id, idProduct, data) {
    return async () => {
        try {
            const response = await axios.patch(`${process.env.REACT_APP_API_URL}/api/shops/${id}/products/${idProduct}`, data, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            dispatch(slice.actions.getEditSuccess(response.data));
        } catch (error) {
            dispatch(slice.actions.hasError(error));
        }
    };
}
