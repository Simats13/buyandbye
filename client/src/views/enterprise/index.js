import { useDispatch } from 'store';
// material-ui
import React, { useState } from 'react';

import {
    Checkbox,
    Divider,
    Grid,
    InputAdornment,
    TextField,
    FormControlLabel,
    FormHelperText,
    RadioGroup,
    Radio,
    Stack,
    Button,
    Switch,
    Typography
} from '@mui/material';

// project imports
import MainCard from 'ui-component/cards/MainCard';
import InputLabel from 'ui-component/extended/Form/InputLabel';
import { gridSpacing } from 'store/constant';
import { openSnackbar } from 'store/slices/snackbar';
import AnimateButton from 'ui-component/extended/AnimateButton';
// assets
import LockTwoToneIcon from '@mui/icons-material/LockTwoTone';
import LinkTwoToneIcon from '@mui/icons-material/LinkTwoTone';

import { useFormik } from 'formik';
import * as yup from 'yup';
import useAuth from 'hooks/useAuth';

import axios from 'utils/axios';

// Schéma de validation des champs du formulaire

const validationSchema = yup.object({
    email: yup.string().email('Enter a valid email').required('Email is required'),
    password: yup.string().min(8, 'Password should be of minimum 8 characters length').required('Password is required'),
    enterpriseAdress: yup.string().required('Enterprise Adress is required')
});

// ==============================|| SAMPLE PAGE ||============================== //

const Enterprise = () => {
    const dispatch = useDispatch();

    const [data, setData] = React.useState([]);
    const { user } = useAuth();
    const getData = async () => {
        const res = await axios.get(`http://localhost:81/api/shops/${user.id}`).then((res, err) => {
            if (!res || err) {
                dispatch(openSnackbar('error', 'Error while fetching data'));
            }
            // console.log(res.data);
            return res;
        });

        return res.data;
    };

    React.useEffect(() => {
        getData().then((res) => setData(res));
    }, []);
    console.log('test');
    console.log(data);

    // Object.keys(data).map((key, index) => <React.Fragment key={index} />);

    const formik = useFormik({
        initialValues: {
            email: '',
            password: '',
            submit: null
        },
        onSubmit: () => {
            console.log('send');
            dispatch(
                openSnackbar({
                    open: true,
                    message: 'Vos modifications ont été enregistrées avec succès',
                    variant: 'alert',
                    alert: {
                        color: 'success'
                    },
                    close: false
                })
            );
        }
    });
    return (
        <MainCard title="Information de l'entreprise">
            <form onSubmit={formik.handleSubmit}>
                <Grid item xs={12}>
                    <Grid container spacing={2} alignItems="left">
                        <Grid item xs={12}>
                            <InputLabel>Type d&apos;entreprise : {data.type}</InputLabel>
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Nom de l&apos;entreprise</InputLabel>
                            <TextField
                                fullWidth
                                id="nameEnterprise"
                                name="nameEnterprise"
                                type="text"
                                placeholder="Nom de l'entreprise"
                                value={data.name}
                                onChange={formik.handleChange}
                                error={formik.touched.nameEnterprise && Boolean(formik.errors.nameEnterprise)}
                                helperText={formik.touched.nameEnterprise && formik.errors.nameEnterprise}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Adresse de l&apos;entreprise</InputLabel>
                            <TextField
                                fullWidth
                                id="enterpriseAdress"
                                name="enterpriseAdress"
                                placeholder="Adresse de l'entreprise"
                                value={data.adresse}
                                onChange={formik.handleChange}
                                error={formik.touched.enterpriseAdress && Boolean(formik.errors.enterpriseAdress)}
                                helperText={formik.touched.enterpriseAdress && formik.errors.enterpriseAdress}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Numéro de SIRET</InputLabel>
                            <TextField
                                fullWidth
                                id="siretNumber"
                                name="siretNumber"
                                type="text"
                                placeholder="Numéro de SIRET"
                                value={data.siretNumber}
                                onChange={formik.handleChange}
                                error={formik.touched.siretNumber && Boolean(formik.errors.siretNumber)}
                                helperText={formik.touched.siretNumber && formik.errors.siretNumber}
                                InputProps={{
                                    endAdornment: (
                                        <InputAdornment position="end">
                                            <LockTwoToneIcon />
                                        </InputAdornment>
                                    )
                                }}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Numéro de TVA</InputLabel>
                            <TextField
                                fullWidth
                                id="tvaNumber"
                                name="tvaNumber"
                                type="text"
                                placeholder="Numéro de TVA"
                                value={data.tvaNumber}
                                onChange={formik.handleChange}
                                error={formik.touched.tvaNumber && Boolean(formik.errors.tvaNumber)}
                                helperText={formik.touched.tvaNumber && formik.errors.tvaNumber}
                            />
                        </Grid>
                        <Grid item lg={12}>
                            <InputLabel>Description</InputLabel>
                            <TextField
                                fullWidth
                                id="desc"
                                name="desc"
                                type="textarea"
                                placeholder="Description"
                                value={data.description}
                                onChange={formik.handleChange}
                                error={formik.touched.desc && Boolean(formik.errors.desc)}
                                helperText={formik.touched.desc && formik.errors.desc}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Adresse Email de l&apos;entreprise</InputLabel>
                            <TextField
                                fullWidth
                                id="emailEnterprise"
                                name="emailEnterprise"
                                type="email"
                                placeholder="Adresse Email de l'entreprise"
                                value={data.email}
                                onChange={formik.handleChange}
                                error={formik.touched.emailEnterprise && Boolean(formik.errors.emailEnterprise)}
                                helperText={formik.touched.emailEnterprise && formik.errors.emailEnterprise}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Numéro de téléphone de l&apos;entreprise</InputLabel>
                            <TextField
                                fullWidth
                                id="phoneEnterprise"
                                name="phoneEnterprise"
                                type="phone"
                                placeholder="Numéro de téléphone de l'entreprise"
                                value={data.phone}
                                onChange={formik.handleChange}
                                error={formik.touched.phoneEnterprise && Boolean(formik.errors.phoneEnterprise)}
                                helperText={formik.touched.phoneEnterprise && formik.errors.phoneEnterprise}
                            />
                        </Grid>
                        <Grid container spacing={2}>
                            <Grid item>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={data.ClickAndCollect}
                                            id="clickAndCollect"
                                            name="clickAndCollect"
                                            onChange={formik.handleChange}
                                            error={formik.touched.clickAndCollect && Boolean(formik.errors.clickAndCollect)}
                                            helperText={formik.touched.clickAndCollect && formik.errors.clickAndCollect}
                                        />
                                    }
                                    label="Click & Collect"
                                />
                            </Grid>
                            <Grid item>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={data.livraison}
                                            id="delivery"
                                            name="delivery"
                                            onChange={formik.handleChange}
                                            error={formik.touched.delivery && Boolean(formik.errors.delivery)}
                                            helperText={formik.touched.delivery && formik.errors.delivery}
                                        />
                                    }
                                    label="Lirvaison à domicile"
                                />
                            </Grid>
                            <Grid item>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={data.isPhoneVisible}
                                            id="isPhoneVisible"
                                            name="isPhoneVisible"
                                            onChange={formik.handleChange}
                                            error={formik.touched.isPhoneVisible && Boolean(formik.errors.isPhoneVisible)}
                                            helperText={formik.touched.isPhoneVisible && formik.errors.isPhoneVisible}
                                        />
                                    }
                                    label="Afficher le numéro de téléphone aux clients"
                                />
                            </Grid>
                        </Grid>
                        <Grid item xs={12}>
                            <Stack direction="row" justifyContent="flex-end">
                                <AnimateButton>
                                    <Button variant="contained" type="submit">
                                        Modifier
                                    </Button>
                                </AnimateButton>
                            </Stack>
                        </Grid>
                    </Grid>
                </Grid>
            </form>
        </MainCard>
    );
};

export default Enterprise;
