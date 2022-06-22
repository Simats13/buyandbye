// material-ui
import React, { useEffect, useState } from 'react';

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
    Typography,
    Autocomplete,
    CardMedia
} from '@mui/material';

// project imports
import MainCard from 'ui-component/cards/MainCard';
import InputLabel from 'ui-component/extended/Form/InputLabel';
import { gridSpacing } from 'store/constant';
import { openSnackbar } from 'store/slices/snackbar';
import AnimateButton from 'ui-component/extended/AnimateButton';
import { useDispatch, useSelector } from 'store';
import { getEnterprise, editEnterpriseInfo } from 'store/slices/enterprise';
// assets
import LockTwoToneIcon from '@mui/icons-material/LockTwoTone';
import LinkTwoToneIcon from '@mui/icons-material/LinkTwoTone';
import axios from '../../utils/axios';
import { useFormik } from 'formik';
import * as yup from 'yup';
import useAuth from 'hooks/useAuth';
import { CloudUploadOutlined } from '@mui/icons-material';
import { useTheme } from '@mui/styles';
import { TwitterPicker } from 'react-color';
import SubCard from 'ui-component/cards/SubCard';
import useConfig from 'hooks/useConfig';

// Schéma de validation des champs du formulaire

const validationSchema = yup.object({
    emailEnterprise: yup.string().email('Veuillez entrer une adresse mail valide').required('Veuillez entrer une adresse mail'),
    enterpriseAdress: yup.string().required('Veuillez entrer une adresse'),
    enterpriseName: yup.string().required('Veuillez entrer le nom de votre entreprise'),
    enterprisePhone: yup.string().required('Veuillez entrer un numéro de téléphone'),
    tvaNumber: yup.string().required('Veuillez entrer le numéro de TVA'),
    description: yup.string().required('Veuillez entrer une description'),
    siretNumber: yup.string().required('Veuillez entrer le numéro de SIRET')
});

// ==============================|| SAMPLE PAGE ||============================== //

const Enterprise = () => {
    const dispatch = useDispatch();
    const [data, setData] = React.useState([]);
    const [enterpriseUpdate, setEnterpriseUpdate] = React.useState([]);
    const { enterprise, infoEnterprise } = useSelector((state) => state.enterprise);
    const { user } = useAuth();
    const { borderRadius } = useConfig();
    const theme = useTheme();
    const tagsCompany = [];

    if (data.type === 'Magasin') {
        tagsCompany.push(
            'Electroménager',
            'Jeux-Vidéos',
            'Livres',
            'Vêtements',
            'Sport',
            'Vins & Spiritueux',
            'Téléphonie',
            'High-Tech',
            'Musique',
            'Loisirs',
            'Alimentation',
            'Montre & Bijoux',
            'Divertissement',
            'Autres'
        );
    } else if (data.type === 'Service') {
        console.log('Salon');
    }
    const twitterStyle = {
        default: {
            input: {
                display: 'none'
            },
            hash: {
                display: 'none'
            }
        }
    };

    React.useEffect(() => {
        setData(enterprise);
    }, [enterprise]);
    // Object.keys(data).map((key, index) => <React.Fragment key={index} />);

    React.useEffect(() => {
        dispatch(getEnterprise(user.id));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    // useEffect(() => {
    //     setEnterpriseUpdate(infoEnterprise);
    // }, [infoEnterprise]);
    if (enterpriseUpdate.status === 'success') {
        dispatch(
            openSnackbar({
                open: true,
                message: enterpriseUpdate.message,
                variant: 'alert',
                alert: {
                    color: 'success'
                },
                close: false
            })
        );
        dispatch(setEnterpriseUpdate());
    } else if (enterpriseUpdate.status === 'error') {
        dispatch(
            openSnackbar({
                open: true,
                message: enterpriseUpdate.message,
                variant: 'alert',
                alert: {
                    color: 'error'
                },
                close: false
            })
        );
    }
    // Object.keys(data).map((key, index) => <React.Fragment key={index} />);
    // console.log('infoEnterprise', infoEnterprise);
    // Object.keys(data).map((key, index) => <React.Fragment key={index} />);
    const [values, setValues] = useState('');
    React.useEffect(() => {
        setValues(data.mainCategorie || []);
    }, [data.mainCategorie]);

    const formik = useFormik({
        validationSchema,
        initialValues: {
            enterpriseName: data.name || '',
            enterpriseAdress: data.adresse || '',
            siretNumber: data.siretNumber || '',
            tvaNumber: data.tvaNumber || '',
            description: data.description || '',
            emailEnterprise: data.email || '',
            enterprisePhone: data.phone || '',
            clickAndCollect: data.ClickAndCollect || false,
            delivery: data.livraison || false,
            isPhoneVisible: data.isPhoneVisible || false,
            tagsEnterprise: values || []
        },
        enableReinitialize: true,
        onSubmit: () => {
            console.log(formik.values);
            dispatch(editEnterpriseInfo(user.id, formik.values));
            dispatch(setEnterpriseUpdate(infoEnterprise));
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
                                name="enterpriseName"
                                type="text"
                                placeholder="Nom de l'entreprise"
                                value={formik.values.enterpriseName}
                                onChange={formik.handleChange}
                                error={formik.touched.enterpriseName && Boolean(formik.errors.enterpriseName)}
                                helperText={formik.touched.enterpriseName && formik.errors.enterpriseName}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Adresse de l&apos;entreprise</InputLabel>
                            <TextField
                                fullWidth
                                id="enterpriseAdress"
                                name="enterpriseAdress"
                                placeholder="Adresse de l'entreprise"
                                value={formik.values.enterpriseAdress}
                                onChange={formik.handleChange}
                                error={formik.touched.enterpriseAdress && Boolean(formik.errors.enterpriseAdress)}
                                helperText={formik.touched.enterpriseAdress && formik.errors.enterpriseAdress}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Numéro de SIRET</InputLabel>
                            <TextField
                                fullWidth
                                id=""
                                name="siretNumber"
                                type="text"
                                placeholder="Numéro de SIRET"
                                value={formik.values.siretNumber}
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
                                value={formik.values.tvaNumber}
                                onChange={formik.handleChange}
                                error={formik.touched.tvaNumber && Boolean(formik.errors.tvaNumber)}
                                helperText={formik.touched.tvaNumber && formik.errors.tvaNumber}
                            />
                        </Grid>
                        <Grid item lg={12}>
                            <InputLabel>Description</InputLabel>
                            <TextField
                                fullWidth
                                id="description"
                                name="description"
                                type="textarea"
                                placeholder="Description"
                                multiline
                                rows={3}
                                value={formik.values.description}
                                onChange={formik.handleChange}
                                error={formik.touched.description && Boolean(formik.errors.description)}
                                helperText={formik.touched.description && formik.errors.description}
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
                                value={formik.values.emailEnterprise}
                                onChange={formik.handleChange}
                                error={formik.touched.emailEnterprise && Boolean(formik.errors.emailEnterprise)}
                                helperText={formik.touched.emailEnterprise && formik.errors.emailEnterprise}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Numéro de téléphone de l&apos;entreprise</InputLabel>
                            <TextField
                                fullWidth
                                id="enterprisePhone"
                                name="enterprisePhone"
                                type="phone"
                                placeholder="Numéro de téléphone de l'entreprise"
                                value={formik.values.enterprisePhone}
                                onChange={formik.handleChange}
                                error={formik.touched.enterprisePhone && Boolean(formik.errors.enterprisePhone)}
                                helperText={formik.touched.enterprisePhone && formik.errors.enterprisePhone}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <Grid item xs={12} lg={6}>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={formik.values.clickAndCollect || false}
                                            id="clickAndCollect"
                                            name="clickAndCollect"
                                            onChange={formik.handleChange}
                                            error={formik.values.toString()}
                                        />
                                    }
                                    label="Click & Collect"
                                />
                            </Grid>
                            <Grid item xs={12} lg={6}>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={formik.values.delivery || false}
                                            id="delivery"
                                            name="delivery"
                                            onChange={formik.handleChange}
                                            error={formik.values.toString()}
                                        />
                                    }
                                    label="Livraison à domicile"
                                />
                            </Grid>
                            <Grid item xs={12} lg={6}>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={formik.values.isPhoneVisible || false}
                                            id="isPhoneVisible"
                                            name="isPhoneVisible"
                                            onChange={formik.handleChange}
                                            error={formik.values.toString()}
                                        />
                                    }
                                    label="Afficher le numéro de téléphone aux clients"
                                />
                            </Grid>
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <InputLabel>Couleur de la boutique</InputLabel>
                            <TwitterPicker styles={twitterStyle} onChange={formik.handleChange} />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <Grid container direction="column" spacing={3}>
                                <Grid item>
                                    <InputLabel>Tags de l&apos;entreprise</InputLabel>
                                    <Autocomplete
                                        id="tagsEnterprise"
                                        name="tagsEnterprise"
                                        multiple
                                        options={tagsCompany}
                                        value={values}
                                        limitTags={3}
                                        isOptionEqualToValue={(option, value) => option === value}
                                        renderInput={(params) => <TextField {...params} />}
                                        onChange={(_, value) => setValues(value)}
                                    />
                                </Grid>
                            </Grid>
                        </Grid>
                        <Grid item lg={12}>
                            <InputLabel>Bannière de la boutique</InputLabel>
                            <TextField
                                type="file"
                                id="file-upload"
                                fullWidth
                                label="Enter SKU"
                                sx={{ display: 'none' }}
                                onChange={formik.handleChange}
                            />
                            <InputLabel
                                htmlFor="file-upload"
                                sx={{
                                    background: theme.palette.background.default,
                                    py: 3.75,
                                    px: 0,
                                    textAlign: 'center',
                                    borderRadius: '4px',
                                    cursor: 'pointer',
                                    mb: 3,
                                    '& > svg': {
                                        verticalAlign: 'sub',
                                        mr: 0.5
                                    }
                                }}
                            >
                                <MainCard content={false} border={false} boxShadow>
                                    <CardMedia
                                        component="img"
                                        image={data.imgUrl}
                                        height="150"
                                        style={{ filter: 'blur(5px)' }}
                                        title="Banniere Entreprise"
                                        sx={{ borderRadius: `${borderRadius}px`, overflow: 'hidden' }}
                                    />
                                    <Typography
                                        align="center"
                                        variant="h3"
                                        style={{
                                            display: 'flex',
                                            alignItems: 'center',
                                            justifyContent: 'center',
                                            position: 'absolute',
                                            top: '50%',
                                            width: '100%',
                                            textAlign: 'center',
                                            // color: 'linear-gradient(225deg, #FF7643 0%, #FF4B33 100%)',
                                            fontWeight: 'bold'
                                        }}
                                        gutterBottom
                                    >
                                        <CloudUploadOutlined
                                            fontSize="large"
                                            color="primary"
                                            sx={{ color: 'linear-gradient(225deg, #FF7643 0%, #FF4B33 100%)' }}
                                        />
                                    </Typography>
                                </MainCard>
                            </InputLabel>
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
