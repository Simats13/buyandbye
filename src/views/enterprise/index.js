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
    CardMedia,
    Box
} from '@mui/material';

// project imports
import MainCard from 'ui-component/cards/MainCard';
import InputLabel from 'ui-component/extended/Form/InputLabel';
import { openSnackbar } from 'store/slices/snackbar';
import AnimateButton from 'ui-component/extended/AnimateButton';
import { useDispatch, useSelector } from 'store';
import { getEnterprise, editEnterpriseInfo } from 'store/slices/enterprise';
// assets
import LocationOnIcon from '@mui/icons-material/LocationOn';
import { useFormik } from 'formik';
import * as yup from 'yup';
import useAuth from 'hooks/useAuth';
import { CloudUploadOutlined } from '@mui/icons-material';
import { useTheme } from '@mui/styles';
import { CirclePicker } from 'react-color';
import useConfig from 'hooks/useConfig';
import throttle from 'lodash/throttle';
import parse from 'autosuggest-highlight/parse';
import PreviewImage from './PreviewImage';
import { FileUploader } from 'react-drag-drop-files';

const fileTypes = ['JPG', 'PNG', 'JPEG'];

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

const autocompleteService = { current: null };

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

    const [value, setValue] = React.useState(null);
    const [values, setValues] = useState('');
    const [color, setColor] = useState('');
    const [inputValue, setInputValue] = React.useState('');
    const [options, setOptions] = React.useState([]);

    const [file, setFile] = useState(null);
    const handleChange = (file) => {
        setFile(file);
    };

    const fetch = React.useMemo(
        () =>
            throttle((request, callback) => {
                autocompleteService.current.getPlacePredictions(request, callback);
            }, 200),
        []
    );

    React.useEffect(() => {
        let active = true;

        if (!autocompleteService.current && window.google) {
            autocompleteService.current = new window.google.maps.places.AutocompleteService();
        }
        if (!autocompleteService.current) {
            return undefined;
        }

        if (inputValue === '') {
            setOptions(value ? [value] : []);
            return undefined;
        }

        fetch({ input: inputValue }, (results) => {
            if (active) {
                let newOptions = [];

                if (value) {
                    newOptions = [value];
                }

                if (results) {
                    newOptions = [...newOptions, ...results];
                }

                setOptions(newOptions);
            }
        });

        return () => {
            active = false;
        };
    }, [value, inputValue, fetch]);

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

    React.useEffect(() => {
        setData(enterprise);
    }, [enterprise]);
    // Object.keys(data).map((key, index) => <React.Fragment key={index} />);

    React.useEffect(() => {
        dispatch(getEnterprise(user.id));
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);
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

    React.useEffect(() => {
        setValues(data.mainCategorie || []);
    }, [data.mainCategorie]);

    React.useEffect(() => {
        setValue(data.adresse || '');
    }, [data.adresse]);

    React.useEffect(() => {
        setColor(data.colorStore || '');
    }, [data.colorStore]);

    const formik = useFormik({
        validationSchema,
        initialValues: {
            enterpriseName: data.name || '',
            enterpriseAdress: value || '',
            siretNumber: data.siretNumber || '',
            tvaNumber: data.tvaNumber || '',
            description: data.description || '',
            emailEnterprise: data.email || '',
            enterprisePhone: data.phone || '',
            clickAndCollect: data.ClickAndCollect || false,
            delivery: data.livraison || false,
            isPhoneVisible: data.isPhoneVisible || false,
            tagsEnterprise: values || [],
            colorEnterprise: color || '',
            oldPhotoEnterprise: data.imgUrl || '',
            newPhotoEnterprise: null
        },
        enableReinitialize: true,
        onSubmit: () => {
            const formData = new FormData();
            formData.append('newPhotoEnterprise', formik.values.newPhotoEnterprise);
            formData.append('data', JSON.stringify(formik.values));
            dispatch(editEnterpriseInfo(user.id, formik.values, formData));
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
            <form method="post" onSubmit={formik.handleSubmit} encType="multipart/form-data">
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
                            <Autocomplete
                                id="enterpriseAdress"
                                // sx={{ width: 300 }}
                                getOptionLabel={(option) => (typeof option === 'string' ? option : option.description)}
                                noOptionsText="Aucune adresse trouvée"
                                filterOptions={(x) => x}
                                options={options}
                                autoComplete
                                includeInputInList
                                filterSelectedOptions
                                value={value}
                                onChange={(event, newValue) => {
                                    setOptions(newValue ? [newValue, ...options] : options);
                                    if (newValue) {
                                        setValue(newValue.description);
                                    }
                                    // console.log(newValue.description);
                                }}
                                onInputChange={(event, newInputValue) => {
                                    setInputValue(newInputValue);
                                }}
                                renderInput={(params) => <TextField {...params} fullWidth />}
                                renderOption={(props, option) => {
                                    const matches = option.structured_formatting.main_text_matched_substrings;
                                    const parts = parse(
                                        option.structured_formatting.main_text,
                                        matches.map((match) => [match.offset, match.offset + match.length])
                                    );

                                    return (
                                        <li {...props}>
                                            <Grid container alignItems="center">
                                                <Grid item>
                                                    <Box component={LocationOnIcon} sx={{ color: 'text.secondary', mr: 2 }} />
                                                </Grid>
                                                <Grid item xs>
                                                    {parts.map((part, index) => (
                                                        <span
                                                            key={index}
                                                            style={{
                                                                fontWeight: part.highlight ? 700 : 400
                                                            }}
                                                        >
                                                            {part.text}
                                                        </span>
                                                    ))}

                                                    <Typography variant="body2" color="text.secondary">
                                                        {option.structured_formatting.secondary_text}
                                                    </Typography>
                                                </Grid>
                                            </Grid>
                                        </li>
                                    );
                                }}
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
                        <Grid item lg={12} md={12} sm={12} xs={12}>
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
                            <CirclePicker
                                id="colorEnterprise"
                                name="colorEnterprise"
                                color={`#${color}`}
                                // onChangeComplete={color}
                                onChangeComplete={(colors) => {
                                    setColor(colors.hex.substring(1));
                                }}
                                // onChange={(colorChoose) => {
                                //     setColor(colorChoose.hex);
                                // }}
                                // onChange={formik.handleChange}
                            />
                        </Grid>
                        <Grid item xs={12} lg={6}>
                            <Grid container direction="column" spacing={3}>
                                <Grid item>
                                    <InputLabel>Tags de l&apos;entreprise</InputLabel>
                                    <Autocomplete
                                        id="tagsEnterprise"
                                        name="tagsEnterprise"
                                        // eslint-disable-next-line react/jsx-boolean-value
                                        multiple={true}
                                        options={tagsCompany}
                                        value={values}
                                        limitTags={2}
                                        getOptionDisabled={(option) => values.length >= 3}
                                        isOptionEqualToValue={(option, value) => option === value}
                                        renderInput={(params) => <TextField {...params} />}
                                        onChange={(_, value) => setValues(value)}
                                    />
                                </Grid>
                            </Grid>
                        </Grid>
                        <Grid item lg={12} md={12} sm={12} xs={12}>
                            <InputLabel>Bannière de la boutique</InputLabel>

                            <FileUploader
                                handleChange={(e) => formik.setFieldValue('newPhotoEnterprise', e)}
                                name="newPhotoEnterprise"
                                types={fileTypes}
                                label="Ajouter/Remplacer la bannière"
                                hoverTitle="Déposer l'image"
                                classes="hello"
                                // eslint-disable-next-line react/no-children-prop
                                children={
                                    <>
                                        {formik.values.newPhotoEnterprise === null ? (
                                            <MainCard content={false} border={false} boxShadow style={{ cursor: 'pointer' }}>
                                                <CardMedia
                                                    component="img"
                                                    image={formik.values.oldPhotoEnterprise}
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
                                        ) : null}
                                        {formik.values.newPhotoEnterprise && <PreviewImage files={formik.values.newPhotoEnterprise} />}
                                    </>
                                }
                            />
                        </Grid>
                        <Grid item xs={12}>
                            <Stack direction="row" justifyContent="flex-end">
                                <AnimateButton>
                                    <Button variant="contained" type="submit" style={{ color: 'white' }}>
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
