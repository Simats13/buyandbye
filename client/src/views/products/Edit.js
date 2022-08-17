import PropTypes from 'prop-types';
import { forwardRef, useEffect, useRef, useState } from 'react';

// material-ui
import { useTheme, styled } from '@mui/material/styles';
import {
    Button,
    CardMedia,
    Chip,
    CircularProgress,
    Dialog,
    DialogActions,
    DialogContent,
    DialogContentText,
    DialogTitle,
    Fab,
    FormControlLabel,
    Grid,
    IconButton,
    Input,
    InputAdornment,
    InputLabel,
    MenuItem,
    Select,
    Slide,
    Switch,
    TextField,
    Typography
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import { dispatch } from 'store';
import { deleteProducts, editProducts } from 'store/slices/product';
import { getProducts } from 'store/slices/customer';
import { openSnackbar } from 'store/slices/snackbar';
import * as yup from 'yup';
import { useFormik } from 'formik';
import { FileUploader } from 'react-drag-drop-files';
import { gridSpacing } from 'store/constant';
import EditIcon from '@mui/icons-material/Edit';
// ===============================|| UI DIALOG - SWEET ALERT ||=============================== //
// styles
const ImageWrapper = styled('div')(({ theme }) => ({
    position: 'relative',
    overflow: 'hidden',
    borderRadius: '4px',
    cursor: 'pointer',
    width: 55,
    height: 55,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: theme.palette.background.default,
    '& > svg': {
        verticalAlign: 'sub',
        marginRight: 6
    }
}));

// animation
const Transition = forwardRef((props, ref) => <Slide direction="left" ref={ref} {...props} />);

const ITEM_HEIGHT = 48;
const ITEM_PADDING_TOP = 8;
const MenuProps = {
    PaperProps: {
        style: {
            maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
            width: 250
        }
    },
    chip: {
        margin: 2
    }
};
export default function EditDialog({ idProduct, idSeller, data, tags, sellerID, handleCloseDialog }) {
    const theme = useTheme();
    console.log('data', data);
    const [open, setOpen] = useState(false);
    const [category, setCategory] = useState('2');
    const handleClickOpen = () => {
        setOpen(true);
    };

    const handleClose = () => {
        setOpen(false);
    };

    const handleDelete = () => {
        // dispatch(deleteProducts(idSeller, idProduct));
        setOpen(false);
    };

    useEffect(() => {
        setCategory(data.categorie || []);
    }, [data.categorie]);

    const handleSelectChange = (event) => {
        setCategory(event?.target.value);
    };

    const validationSchema = yup.object({
        productName: yup.string().required('Product name is required'),
        productDescription: yup.string().required('Product description is required'),
        productPrice: yup.number().required('Product price is required'),
        productCategory: yup.string().required('Product category is required'),
        productReference: yup.string().required('Product reference is required'),
        productDiscount: yup.number().required('Product discount is required'),
        productQuantity: yup.number().required('Product quantity is required'),
        productBrand: yup.string().required('Product brand is required'),
        productWeight: yup.number().required('Product weight is required')
    });

    const fileTypes = ['JPG', 'PNG', 'JPEG'];
    const formik = useFormik({
        validationSchema,
        initialValues: {
            productName: data.nom || '',
            productDescription: data.description || '',
            productCategory: category || '',
            productReference: data.reference || 0,
            productPrice: data.prix || 0,
            productDiscount: data.discount || 0,
            productQuantity: data.quantite || 0,
            productBrand: data.brand || '',
            productWeight: data.weight || 0,
            productVisibility: data.visible || false,
            productPhoto: data.images[0] || [],
            newPhotoProduct: null
        },
        enableReinitialize: true,
        onSubmit: () => {
            const formData = new FormData();
            console.log('formik.values', formik.values);
            formData.append('newPhotoProduct', formik.values.newPhotoProduct);
            formData.append('data', JSON.stringify(formik.values));
            dispatch(editProducts(sellerID, data.id, formData));
            handleClose();
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
        <>
            <IconButton onClick={handleClickOpen} color="primary" size="large">
                <EditIcon sx={{ fontSize: '1.3rem' }} />
            </IconButton>
            <Dialog
                open={open}
                onClose={handleClose}
                TransitionComponent={Transition}
                keepMounted
                aria-labelledby="alert-dialog-title"
                aria-describedby="alert-dialog-description"
                // sx={{ p: 3 }}
                sx={{
                    '&>div:nth-of-type(3)': {
                        justifyContent: 'flex-end',
                        '&>div': {
                            m: 0,
                            borderRadius: '0px',
                            maxWidth: 450,
                            maxHeight: '100%'
                        }
                    }
                }}
            >
                {open && (
                    <>
                        <form onSubmit={formik.handleSubmit}>
                            <DialogTitle id="alert-dialog-title">Editer un Produit</DialogTitle>
                            <DialogContent>
                                <DialogContentText id="alert-dialog-description">
                                    <Grid container spacing={gridSpacing} sx={{ mt: 0.25 }}>
                                        <Grid item xs={12}>
                                            <TextField
                                                id="productName"
                                                fullWidth
                                                multiline
                                                label="Nom du Produit*"
                                                onChange={formik.handleChange}
                                                value={formik.values.productName}
                                            />
                                        </Grid>
                                        <Grid item xs={12}>
                                            <TextField
                                                id="productDescription"
                                                fullWidth
                                                multiline
                                                rows={3}
                                                label="Description"
                                                onChange={formik.handleChange}
                                                defaultValue={formik.values.productDescription}
                                            />
                                        </Grid>
                                        <Grid item xs={12}>
                                            <TextField
                                                id="productCategory"
                                                select
                                                label="Categorie du Produit*"
                                                value={formik.values.productCategory}
                                                fullWidth
                                                onChange={handleSelectChange}
                                            >
                                                {tags.map((name) => (
                                                    <MenuItem key={name} value={name}>
                                                        {name}
                                                    </MenuItem>
                                                ))}
                                            </TextField>
                                        </Grid>
                                        <Grid item xs={12}>
                                            <TextField
                                                id="productReference"
                                                fullWidth
                                                label="Reférence*"
                                                multiline
                                                onChange={formik.handleChange}
                                                value={formik.values.productReference}
                                            />
                                        </Grid>
                                        <Grid item md={6} xs={12}>
                                            <TextField
                                                label="Prix*"
                                                id="productPrice"
                                                onChange={formik.handleChange}
                                                multiline
                                                defaultValue={formik.values.productPrice}
                                                InputProps={{ endAdornment: <InputAdornment position="start">€</InputAdornment> }}
                                            />
                                        </Grid>
                                        <Grid item md={6} xs={12}>
                                            <TextField
                                                label="Réduction"
                                                id="productDiscount"
                                                multiline
                                                onChange={formik.handleChange}
                                                defaultValue={formik.values.productDiscount}
                                                InputProps={{ endAdornment: <InputAdornment position="start">%</InputAdornment> }}
                                            />
                                        </Grid>
                                        <Grid item md={6} xs={12}>
                                            <TextField
                                                id="productQuantity"
                                                multiline
                                                label="Quantité*"
                                                onChange={formik.handleChange}
                                                defaultValue={formik.values.productQuantity}
                                            />
                                        </Grid>
                                        <Grid item md={6} xs={12}>
                                            <TextField
                                                id="productBrand"
                                                name="productBrand"
                                                label="Marque du produit*"
                                                multiline
                                                onChange={formik.handleChange}
                                                defaultValue={formik.values.productBrand}
                                                placeholder="Ex : Apple"
                                            />
                                        </Grid>
                                        <Grid item md={6} xs={12}>
                                            <TextField
                                                id="productWeight"
                                                multiline
                                                defaultValue={formik.values.productWeight}
                                                onChange={formik.handleChange}
                                                label="Poids"
                                                InputProps={{ endAdornment: <InputAdornment position="end">kg</InputAdornment> }}
                                            />
                                        </Grid>
                                        <Grid item md={6} xs={12}>
                                            <FormControlLabel
                                                control={
                                                    <Switch
                                                        checked={formik.values.productVisibility}
                                                        id="productVisibility"
                                                        onChange={formik.handleChange}
                                                        error={formik.values.toString()}
                                                    />
                                                }
                                                label="Visibilité du produit"
                                            />
                                        </Grid>
                                        <Grid item xs={12}>
                                            <Grid container spacing={1}>
                                                <Grid item xs={12}>
                                                    <Typography variant="subtitle1" align="left">
                                                        Images du Produit*
                                                    </Typography>
                                                </Grid>
                                                <Grid item xs={12}>
                                                    <FileUploader
                                                        handleChange={(e) => formik.setFieldValue('newPhotoProduct', e)}
                                                        name="newPhotoProduct"
                                                        types={fileTypes}
                                                        label="Ajouter/Remplacer les images"
                                                        hoverTitle="Déposer l'image"
                                                    />
                                                </Grid>
                                            </Grid>
                                        </Grid>
                                    </Grid>
                                </DialogContentText>
                            </DialogContent>
                            <DialogActions sx={{ pr: 2.5 }}>
                                <Button
                                    sx={{ color: theme.palette.error.dark, borderColor: theme.palette.error.dark }}
                                    onClick={handleClose}
                                    color="secondary"
                                >
                                    Fermer
                                </Button>
                                <Button variant="contained" size="small" type="submit" style={{ color: 'white' }} autoFocus>
                                    Modifier
                                </Button>
                            </DialogActions>
                        </form>
                    </>
                )}
            </Dialog>
        </>
    );
}
