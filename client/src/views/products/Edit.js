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
    DialogTitle,
    Fab,
    FormControlLabel,
    Grid,
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

import * as yup from 'yup';
// project imports
import { gridSpacing } from 'store/constant';
import AnimateButton from 'ui-component/extended/AnimateButton';

// assets
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import CloseIcon from '@mui/icons-material/Close';
import { Form, Formik, useFormik } from 'formik';
import { dispatch } from 'store';
import { editProducts } from 'store/slices/product';
import { openSnackbar } from 'store/slices/snackbar';

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

// tags list & style
const tagNames = ['Html', 'Scss', 'Js', 'React', 'Ionic', 'Angular', 'css', 'Php', 'View'];

function getStyles(name, personName, theme) {
    return {
        fontWeight: personName.indexOf(name) === -1 ? theme.typography.fontWeightRegular : theme.typography.fontWeightMedium
    };
}

// ==============================|| PRODUCT ADD DIALOG ||============================== //

const ProductEdit = ({ open, handleCloseDialog, data, tags, sellerID }) => {
    const theme = useTheme();
    // handle category change dropdown
    const [category, setCategory] = useState('2');

    useEffect(() => {
        setCategory(data.categorie || []);
    }, [data.categorie]);

    const handleSelectChange = (event) => {
        setCategory(event?.target.value);
    };
    // set image upload progress
    const [progress, setProgress] = useState(0);
    const progressRef = useRef(() => {});
    useEffect(() => {
        progressRef.current = () => {
            if (progress > 100) {
                setProgress(0);
            } else {
                const diff = Math.random() * 10;
                setProgress(progress + diff);
            }
        };
    });

    useEffect(() => {
        const timer = setInterval(() => {
            progressRef.current();
        }, 500);

        return () => {
            clearInterval(timer);
        };
    }, []);

    // handle tag select
    const [personName, setPersonName] = useState([]);
    const handleTagSelectChange = (event) => {
        setPersonName(event?.target.value);
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
    const formik = useFormik({
        // validationSchema,
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
            productVisibility: data.visible || 0
        },
        enableReinitialize: true,
        onSubmit: () => {
            dispatch(editProducts(sellerID, data.id, formik.values));
            handleCloseDialog();
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
        <Dialog
            open={open}
            TransitionComponent={Transition}
            keepMounted
            onClose={handleCloseDialog}
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
                        <DialogTitle>Editer un Produit</DialogTitle>
                        <DialogContent>
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
                                            <MenuItem value={name}>{name}</MenuItem>
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
                                            <div>
                                                <TextField
                                                    type="file"
                                                    id="file-upload"
                                                    fullWidth
                                                    label="Enter SKU"
                                                    sx={{ display: 'none' }}
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
                                                    <CloudUploadIcon /> Déposer vos images
                                                </InputLabel>
                                            </div>
                                        </Grid>
                                    </Grid>
                                </Grid>
                            </Grid>
                        </DialogContent>
                        <DialogActions>
                            <Button variant="text" color="error" onClick={handleCloseDialog}>
                                Fermer
                            </Button>
                            <AnimateButton>
                                <Button variant="contained" type="submit" style={{ color: 'white' }}>
                                    Modifier
                                </Button>
                            </AnimateButton>
                        </DialogActions>
                    </form>
                </>
            )}
        </Dialog>
    );
};

ProductEdit.propTypes = {
    open: PropTypes.bool,
    handleCloseDialog: PropTypes.func
};

export default ProductEdit;
