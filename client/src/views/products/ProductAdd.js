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

// project imports
import { gridSpacing } from 'store/constant';
import AnimateButton from 'ui-component/extended/AnimateButton';
import * as yup from 'yup';

// assets
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import CloseIcon from '@mui/icons-material/Close';
import { dispatch } from 'store';
import { addProducts } from 'store/slices/product';
import { useFormik } from 'formik';
import { openSnackbar } from 'store/slices/snackbar';
import { FileUploader } from 'react-drag-drop-files';

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

// product category options
const categories = [
    {
        value: '1',
        label: 'Iphone 12 Pro Max'
    },
    {
        value: '2',
        label: 'Iphone 11 Pro Max'
    },
    {
        value: '3',
        label: 'Nokia'
    },
    {
        value: '4',
        label: 'Samsung'
    }
];

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

const ProductAdd = ({ open, handleCloseDialog, tags, sellerID }) => {
    const theme = useTheme();
    // handle category change dropdown
    const [category, setCategory] = useState('');
    const fileTypes = ['JPG', 'PNG', 'JPEG'];

    // useEffect(() => {
    //     setCategory('Electroménager' || []);
    // }, [category]);

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
        productName: yup.string().required('Veuillez mettre un nom à votre produit'),
        productDescription: yup.string().required('Veuillez mettre une description à votre produit'),
        productPrice: yup.number().required('Veuillez mettre un prix à votre produit'),
        productCategory: yup.string().required('Veuillez mettre une catégorie à votre produit'),
        productReference: yup.string().required('Veuillez mettre une référence à votre produit'),
        productQuantity: yup.number().required('Veuillez mettre une quantité à votre produit'),
        productBrand: yup.string().required('Veuillez renseigner la marque de votre produit'),
        productWeight: yup.number().required('Veuillez mettre un poids à votre produit')
    });
    const formik = useFormik({
        validationSchema,
        initialValues: {
            productName: '',
            productDescription: '',
            productCategory: category || 'Electroménager',
            productReference: '',
            productPrice: '',
            productDiscount: '',
            productQuantity: '',
            productBrand: '',
            productWeight: '',
            productVisibility: false,
            productPhoto: null
        },
        enableReinitialize: true,
        onSubmit: () => {
            const formData = new FormData();
            formData.append('productPhoto', formik.values.productPhoto);
            formData.append('data', JSON.stringify(formik.values));
            console.log(formData);
            dispatch(addProducts(sellerID, formData));
            handleCloseDialog();
            dispatch(
                openSnackbar({
                    open: true,
                    message: 'Votre produit a bien été ajouté',
                    variant: 'alert',
                    alert: {
                        color: 'success'
                    },
                    close: false
                })
            );
            formik.resetForm();
        }
    });

    return (
        <Dialog
            open={open}
            TransitionComponent={Transition}
            keepMounted
            onClose={() => {
                handleCloseDialog();
                formik.resetForm();
            }}
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
                        <DialogTitle>Ajouter un Produit</DialogTitle>
                        <DialogContent>
                            <Grid container spacing={gridSpacing} sx={{ mt: 0.25 }}>
                                <Grid item xs={12}>
                                    <TextField
                                        fullWidth
                                        id="productName"
                                        label="Nom du produit*"
                                        multiline
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productName}
                                        placeholder="Ex : Iphone 11 Pro Max"
                                        error={formik.touched.productName && Boolean(formik.errors.productName)}
                                        helperText={formik.touched.productName && formik.errors.productName}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <TextField
                                        id="productDescription"
                                        fullWidth
                                        multiline
                                        rows={3}
                                        label="Description"
                                        placeholder="Ex : Voici la description de mon produit"
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productDescription}
                                        error={formik.touched.productDescription && Boolean(formik.errors.productDescription)}
                                        helperText={formik.touched.productDescription && formik.errors.productDescription}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <TextField
                                        id="productCategory"
                                        select
                                        value={formik.values.productCategory}
                                        label="Categorie du Produit*"
                                        fullWidth
                                        onChange={handleSelectChange}
                                        error={formik.touched.productCategory && Boolean(formik.errors.productCategory)}
                                        helperText={formik.touched.productCategory && formik.errors.productCategory}
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
                                        fullWidth
                                        id="productReference"
                                        label="Reference du produit*"
                                        multiline
                                        placeholder="Ex : FR103D"
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productReference}
                                        error={formik.touched.productReference && Boolean(formik.errors.productReference)}
                                        helperText={formik.touched.productReference && formik.errors.productReference}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        label="Prix*"
                                        id="productPrice"
                                        placeholder="Ex : 100"
                                        onChange={formik.handleChange}
                                        multiline
                                        defaultValue={formik.values.productPrice}
                                        error={formik.touched.productPrice && Boolean(formik.errors.productPrice)}
                                        helperText={formik.touched.productPrice && formik.errors.productPrice}
                                        InputProps={{ endAdornment: <InputAdornment position="start">€</InputAdornment> }}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        id="productDiscount"
                                        label="Réduction"
                                        multiline
                                        placeholder="Ex : 10"
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productDiscount}
                                        error={formik.touched.productDiscount && Boolean(formik.errors.productDiscount)}
                                        helperText={formik.touched.productDiscount && formik.errors.productDiscount}
                                        InputProps={{ endAdornment: <InputAdornment position="start">%</InputAdornment> }}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        placeholder="Ex : 15"
                                        id="productQuantity"
                                        multiline
                                        label="Quantité*"
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productQuantity}
                                        error={formik.touched.productQuantity && Boolean(formik.errors.productQuantity)}
                                        helperText={formik.touched.productQuantity && formik.errors.productQuantity}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        id="productBrand"
                                        label="Marque du produit*"
                                        multiline
                                        onChange={formik.handleChange}
                                        defaultValue={formik.values.productBrand}
                                        error={formik.touched.productBrand && Boolean(formik.errors.productBrand)}
                                        helperText={formik.touched.productBrand && formik.errors.productBrand}
                                        placeholder="Ex : Apple"
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <TextField
                                        id="productWeight"
                                        placeholder="Ex : 10"
                                        multiline
                                        defaultValue={formik.values.productWeight}
                                        onChange={formik.handleChange}
                                        label="Poids"
                                        InputProps={{ endAdornment: <InputAdornment position="end">kg</InputAdornment> }}
                                        error={formik.touched.productWeight && Boolean(formik.errors.productWeight)}
                                        helperText={formik.touched.productWeight && formik.errors.productWeight}
                                    />
                                </Grid>
                                <Grid item md={6} xs={12}>
                                    <FormControlLabel
                                        control={
                                            <Switch
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
                                                handleChange={(e) => formik.setFieldValue('productPhoto', e)}
                                                name="productPhoto"
                                                types={fileTypes}
                                                label="Ajouter/Remplacer la bannière"
                                                hoverTitle="Déposer l'image"
                                            />
                                        </Grid>
                                    </Grid>
                                </Grid>
                            </Grid>
                        </DialogContent>
                        <DialogActions>
                            <Button
                                variant="text"
                                color="error"
                                onClick={() => {
                                    handleCloseDialog();
                                    formik.resetForm();
                                }}
                            >
                                Fermer
                            </Button>
                            <AnimateButton>
                                <Button variant="contained" type="submit" style={{ color: 'white' }}>
                                    Ajouter
                                </Button>
                            </AnimateButton>
                        </DialogActions>
                    </form>
                </>
            )}
        </Dialog>
    );
};

ProductAdd.propTypes = {
    open: PropTypes.bool,
    handleCloseDialog: PropTypes.func
};

export default ProductAdd;
